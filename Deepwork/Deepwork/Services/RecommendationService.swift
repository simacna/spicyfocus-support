import Foundation

enum RecommendationConfidence {
    case coldStart      // 0-4 sessions
    case emerging       // 5-14 sessions
    case established    // 15+ sessions
}

struct DurationRecommendation {
    let minutes: Int
    let confidence: RecommendationConfidence
    let reason: String
    let alternates: [Int]
}

final class RecommendationService: @unchecked Sendable {
    private let calendar = Calendar.current
    private let snapDurations = Constants.Recommendation.snapDurations

    init() {}

    func recommend(
        energy: EnergyLevel,
        label: String,
        currentHour: Int,
        sessions: [FocusSession],
        dailyGoalMinutes: Int,
        todayMinutesSoFar: Int
    ) -> DurationRecommendation {
        let confidence = resolveConfidence(sessionCount: sessions.count)

        // Cold start
        if sessions.count < Constants.Recommendation.coldStartThreshold {
            return coldStartRecommendation(energy: energy, confidence: confidence)
        }

        // Stage A: Completion-weighted candidate
        var candidate = completionWeightedCandidate(sessions: sessions)

        // Stage B: Contextual adjustments
        candidate = applyContextualAdjustments(
            candidate: candidate,
            energy: energy,
            currentHour: currentHour,
            label: label,
            sessions: sessions
        )

        // Stage C: Stretch / pullback
        let (adjusted, stretchReason) = applyStretchPullback(
            candidate: candidate,
            sessions: sessions
        )
        candidate = adjusted

        // Stage D: Snap + goal awareness
        let (snapped, goalReason) = snapAndApplyGoal(
            candidate: candidate,
            dailyGoalMinutes: dailyGoalMinutes,
            todayMinutesSoFar: todayMinutesSoFar
        )

        let reason = pickReason(
            goalReason: goalReason,
            stretchReason: stretchReason,
            energy: energy,
            label: label,
            sessions: sessions
        )

        let alternates = computeAlternates(for: snapped)

        return DurationRecommendation(
            minutes: snapped,
            confidence: confidence,
            reason: reason,
            alternates: alternates
        )
    }

    // MARK: - Confidence

    private func resolveConfidence(sessionCount: Int) -> RecommendationConfidence {
        if sessionCount < Constants.Recommendation.coldStartThreshold {
            return .coldStart
        } else if sessionCount < Constants.Recommendation.establishedThreshold {
            return .emerging
        } else {
            return .established
        }
    }

    // MARK: - Cold Start

    private func coldStartRecommendation(energy: EnergyLevel, confidence: RecommendationConfidence) -> DurationRecommendation {
        let minutes: Int
        let reason: String

        switch energy {
        case .low:
            minutes = 10
            reason = "A quick win to build momentum"
        case .medium:
            minutes = 15
            reason = "A solid starting point"
        case .high:
            minutes = 25
            reason = "You've got the energy — let's go"
        case .notRated:
            minutes = 15
            reason = "A solid starting point"
        }

        return DurationRecommendation(
            minutes: minutes,
            confidence: confidence,
            reason: reason,
            alternates: computeAlternates(for: minutes)
        )
    }

    // MARK: - Stage A: Completion-weighted candidate

    private func completionWeightedCandidate(sessions: [FocusSession]) -> Double {
        // Group sessions by planned duration in minutes
        let grouped = Dictionary(grouping: sessions) { $0.plannedMinutes }

        var bestScore = -1.0
        var bestDuration = 25.0

        for (duration, bucket) in grouped {
            guard duration > 0 else { continue }

            let weightedSessions = bucket.map { session -> (session: FocusSession, weight: Double) in
                let weight = recencyWeight(for: session.startTime)
                return (session, weight)
            }

            let totalWeight = weightedSessions.reduce(0.0) { $0 + $1.weight }
            guard totalWeight > 0 else { continue }

            // Completion rate (weighted)
            let completionRate = weightedSessions.reduce(0.0) { acc, pair in
                acc + (pair.session.wasCompleted ? pair.weight : 0)
            } / totalWeight

            // Intention completion rate (weighted)
            let sessionsWithIntention = weightedSessions.filter { !$0.session.intention.isEmpty }
            let intentionRate: Double
            if sessionsWithIntention.isEmpty {
                intentionRate = completionRate // fallback
            } else {
                let intentionWeight = sessionsWithIntention.reduce(0.0) { $0 + $1.weight }
                intentionRate = sessionsWithIntention.reduce(0.0) { acc, pair in
                    acc + (pair.session.intentionCompleted ? pair.weight : 0)
                } / intentionWeight
            }

            // Average completion percentage (weighted)
            let avgCompletionPct = weightedSessions.reduce(0.0) { acc, pair in
                acc + pair.session.completionPercentage * pair.weight
            } / totalWeight

            let score = completionRate * 0.6 + intentionRate * 0.2 + avgCompletionPct * 0.2

            if score > bestScore {
                bestScore = score
                bestDuration = Double(duration)
            }
        }

        return bestDuration
    }

    private func recencyWeight(for date: Date) -> Double {
        let daysAgo = calendar.dateComponents([.day], from: date, to: Date()).day ?? 0
        if daysAgo <= 14 { return 1.0 }
        if daysAgo <= 30 { return 0.7 }
        if daysAgo <= 60 { return 0.5 }
        return 0.3
    }

    // MARK: - Stage B: Contextual adjustments

    private func applyContextualAdjustments(
        candidate: Double,
        energy: EnergyLevel,
        currentHour: Int,
        label: String,
        sessions: [FocusSession]
    ) -> Double {
        var result = candidate

        // Energy adjustment
        if energy == .low {
            let lowEnergySessions = sessions.filter { $0.energy == .low && $0.wasCompleted }
            if !lowEnergySessions.isEmpty {
                let median = medianDuration(lowEnergySessions)
                result = min(result, median)
            }
        } else if energy == .high {
            let highEnergySessions = sessions.filter { $0.energy == .high && $0.wasCompleted }
            if !highEnergySessions.isEmpty {
                let median = medianDuration(highEnergySessions)
                result = max(result, median)
            }
        }

        // Time of day adjustment
        let bucket = timeBucket(for: currentHour)
        let bucketSessions = sessions.filter { timeBucket(for: calendar.component(.hour, from: $0.startTime)) == bucket && $0.wasCompleted }
        if bucketSessions.count >= 3 {
            let bucketMedian = medianDuration(bucketSessions)
            if bucketMedian < result * 0.8 {
                // Blend toward bucket median
                result = result * 0.7 + bucketMedian * 0.3
            }
        }

        // Label adjustment
        if !label.isEmpty {
            let labelSessions = sessions.filter { $0.label == label && $0.wasCompleted }
            if labelSessions.count >= 3 {
                let labelMedian = medianDuration(labelSessions)
                result = result * 0.7 + labelMedian * 0.3
            }
        }

        return result
    }

    private func medianDuration(_ sessions: [FocusSession]) -> Double {
        let sorted = sessions.map { Double($0.plannedMinutes) }.sorted()
        guard !sorted.isEmpty else { return 25 }
        let mid = sorted.count / 2
        if sorted.count.isMultiple(of: 2) {
            return (sorted[mid - 1] + sorted[mid]) / 2
        }
        return sorted[mid]
    }

    private enum TimeBucket {
        case morning, afternoon, evening, night
    }

    private func timeBucket(for hour: Int) -> TimeBucket {
        switch hour {
        case 5..<12: return .morning
        case 12..<17: return .afternoon
        case 17..<21: return .evening
        default: return .night
        }
    }

    // MARK: - Stage C: Stretch / pullback

    private func applyStretchPullback(candidate: Double, sessions: [FocusSession]) -> (Double, String?) {
        let recentCount = Constants.Recommendation.recentSessionWindow
        let recent = Array(sessions.prefix(recentCount)) // sessions are sorted reverse by startTime

        guard recent.count >= recentCount else {
            return (candidate, nil)
        }

        // Safety: check for abandoned sessions in last 5
        let lastFive = Array(sessions.prefix(5))
        let abandonedCount = lastFive.filter { $0.completionPercentage < 0.5 }.count
        let safeToStretch = abandonedCount < 2

        let completionRate = Double(recent.filter { $0.wasCompleted }.count) / Double(recent.count)

        if completionRate >= Constants.Recommendation.stretchThreshold && safeToStretch {
            let nudged = snapUp(from: candidate)
            return (nudged, "You've been crushing it — stretch?")
        } else if completionRate < Constants.Recommendation.pullbackThreshold {
            let nudged = snapDown(from: candidate)
            return (nudged, nil)
        }

        return (candidate, nil)
    }

    private func snapUp(from value: Double) -> Double {
        for snap in snapDurations where Double(snap) > value {
            return Double(snap)
        }
        return value
    }

    private func snapDown(from value: Double) -> Double {
        for snap in snapDurations.reversed() where Double(snap) < value {
            return Double(snap)
        }
        return value
    }

    // MARK: - Stage D: Snap + goal awareness

    private func snapAndApplyGoal(candidate: Double, dailyGoalMinutes: Int, todayMinutesSoFar: Int) -> (Int, String?) {
        let snapped = snapToNearest(candidate)

        // Check if remaining goal maps to a nearby snap duration
        let remaining = dailyGoalMinutes - todayMinutesSoFar
        guard remaining > 0 else { return (snapped, nil) }

        if let goalSnap = snapDurations.first(where: { $0 == remaining }),
           abs(goalSnap - snapped) <= snapStepDistance(snapped) {
            return (goalSnap, "\(goalSnap)m to hit your daily goal")
        }

        return (snapped, nil)
    }

    private func snapToNearest(_ value: Double) -> Int {
        var bestSnap = snapDurations[0]
        var bestDist = abs(value - Double(bestSnap))

        for snap in snapDurations.dropFirst() {
            let dist = abs(value - Double(snap))
            if dist < bestDist {
                bestDist = dist
                bestSnap = snap
            } else if dist == bestDist {
                // Ties prefer lower (conservative)
                bestSnap = min(bestSnap, snap)
            }
        }

        return bestSnap
    }

    private func snapStepDistance(_ snapped: Int) -> Int {
        guard let idx = snapDurations.firstIndex(of: snapped) else { return 5 }
        if idx + 1 < snapDurations.count {
            return snapDurations[idx + 1] - snapped
        }
        if idx > 0 {
            return snapped - snapDurations[idx - 1]
        }
        return 5
    }

    // MARK: - Reason

    private func pickReason(
        goalReason: String?,
        stretchReason: String?,
        energy: EnergyLevel,
        label: String,
        sessions: [FocusSession]
    ) -> String {
        if let goalReason { return goalReason }
        if let stretchReason { return stretchReason }

        if energy == .low {
            return "Your sweet spot when energy is low"
        }
        if energy == .high {
            return "Matched to your high energy"
        }

        if !label.isEmpty {
            let labelSessions = sessions.filter { $0.label == label && $0.wasCompleted }
            if labelSessions.count >= 3 {
                return "Your best \(label) session length"
            }
        }

        return "Based on your focus history"
    }

    // MARK: - Alternates

    private func computeAlternates(for minutes: Int) -> [Int] {
        guard let idx = snapDurations.firstIndex(of: minutes) else {
            return []
        }

        var alts: [Int] = []
        if idx > 0 {
            alts.append(snapDurations[idx - 1])
        }
        if idx + 1 < snapDurations.count {
            alts.append(snapDurations[idx + 1])
        }
        return alts
    }
}
