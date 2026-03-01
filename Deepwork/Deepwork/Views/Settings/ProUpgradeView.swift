import SwiftUI
import StoreKit

struct ProUpgradeView: View {
    @EnvironmentObject private var userSettings: UserSettings
    @StateObject private var storeService = StoreService.shared
    @Environment(\.dismiss) private var dismiss

    @State private var isPurchasing = false
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: Constants.Spacing.xl) {
                // Header
                VStack(spacing: Constants.Spacing.md) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(Constants.Colors.accent)

                    Text("Spicy Focus Pro")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Constants.Colors.primaryText)

                    Text("Built for your brain")
                        .font(Constants.Fonts.body)
                        .foregroundStyle(Constants.Colors.secondaryText)
                }
                .padding(.top, Constants.Spacing.xl)

                // Features
                VStack(alignment: .leading, spacing: Constants.Spacing.md) {
                    ProFeatureRow(
                        icon: "waveform",
                        title: "Ambient Sounds",
                        description: "Noise-assisted focus — research-backed for ADHD"
                    )

                    ProFeatureRow(
                        icon: "chart.xyaxis.line",
                        title: "Insights Dashboard",
                        description: "Find your brain's peak focus hours"
                    )

                    ProFeatureRow(
                        icon: "flame.fill",
                        title: "Focus Streaks",
                        description: "Immediate rewards for your dopamine system"
                    )

                    ProFeatureRow(
                        icon: "timer",
                        title: "Pomodoro Mode",
                        description: "Structured work/break cycles for sustained focus"
                    )

                    ProFeatureRow(
                        icon: "calendar",
                        title: "Focus Calendar",
                        description: "Visual history of your focus journey"
                    )

                    ProFeatureRow(
                        icon: "square.grid.2x2",
                        title: "Home Screen Widgets",
                        description: "External cues — right on your home screen"
                    )
                }
                .padding(Constants.Spacing.lg)
                .background(Constants.Colors.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Purchase Button
                VStack(spacing: Constants.Spacing.md) {
                    if let product = storeService.proProduct {
                        Button {
                            Task {
                                await purchasePro(product)
                            }
                        } label: {
                            HStack {
                                if isPurchasing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Unlock Pro - \(product.displayPrice)")
                                }
                            }
                            .font(Constants.Fonts.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(Constants.Spacing.md)
                            .background(Constants.Colors.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(isPurchasing)

                        Text("$4.99 lifetime — no subscriptions, ever.")
                            .font(Constants.Fonts.caption)
                            .foregroundStyle(Constants.Colors.secondaryText)
                    } else if storeService.isLoading {
                        ProgressView()
                    } else {
                        // Fallback when StoreKit product not available (dev/testing)
                        Button {
                            userSettings.isProUser = true
                            dismiss()
                        } label: {
                            Text("Unlock Pro - $4.99")
                                .font(Constants.Fonts.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(Constants.Spacing.md)
                                .background(Constants.Colors.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        Text("$4.99 lifetime — no subscriptions, ever.")
                            .font(Constants.Fonts.caption)
                            .foregroundStyle(Constants.Colors.secondaryText)

                        #if DEBUG
                        Text("(Debug: StoreKit not configured)")
                            .font(Constants.Fonts.caption)
                            .foregroundStyle(Constants.Colors.warning)
                        #endif
                    }

                    Button("Restore Purchases") {
                        Task {
                            await storeService.restorePurchases()
                            if storeService.isProUnlocked {
                                userSettings.isProUser = true
                                dismiss()
                            }
                        }
                    }
                    .font(Constants.Fonts.body)
                    .foregroundStyle(Constants.Colors.accent)
                }
                .padding(.top, Constants.Spacing.md)
            }
            .padding(Constants.Spacing.lg)
        }
        .navigationTitle("Upgrade")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Purchase Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onChange(of: storeService.isProUnlocked) { _, isUnlocked in
            if isUnlocked {
                userSettings.isProUser = true
                dismiss()
            }
        }
    }

    private func purchasePro(_ product: Product) async {
        isPurchasing = true
        do {
            let success = try await storeService.purchase(product)
            if success {
                userSettings.isProUser = true
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        isPurchasing = false
    }
}

struct ProFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: Constants.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(Constants.Colors.accent)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Constants.Fonts.headline)
                    .foregroundStyle(Constants.Colors.primaryText)

                Text(description)
                    .font(Constants.Fonts.caption)
                    .foregroundStyle(Constants.Colors.secondaryText)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProUpgradeView()
            .environmentObject(UserSettings())
    }
}
