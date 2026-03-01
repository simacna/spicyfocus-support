import Foundation
import StoreKit

@MainActor
final class StoreService: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let productIDs = ["com.spicyfocus.pro"]
    private var transactionListener: Task<Void, Error>?

    static let shared = StoreService()

    init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    var isProUnlocked: Bool {
        purchasedProductIDs.contains("com.spicyfocus.pro")
    }

    var proProduct: Product? {
        products.first { $0.id == "com.spicyfocus.pro" }
    }

    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            products = try await Product.products(for: productIDs)
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func purchase(_ product: Product) async throws -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchasedProducts()
                await transaction.finish()
                isLoading = false
                return true

            case .userCancelled:
                isLoading = false
                return false

            case .pending:
                isLoading = false
                return false

            @unknown default:
                isLoading = false
                return false
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            isLoading = false
            throw error
        }
    }

    func restorePurchases() async {
        isLoading = true
        errorMessage = nil

        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                await self?.handleTransaction(result)
            }
        }
    }

    private func handleTransaction(_ result: VerificationResult<Transaction>) async {
        do {
            let transaction = try checkVerified(result)
            await updatePurchasedProducts()
            await transaction.finish()
        } catch {
            // Transaction verification failed
        }
    }

    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                purchased.insert(transaction.productID)
            } catch {
                // Skip unverified transactions
            }
        }

        purchasedProductIDs = purchased
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        }
    }
}
