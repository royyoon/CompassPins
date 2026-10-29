import Foundation
import Combine

class APIService: ObservableObject {
    static let shared = APIService()

    // TODO: Replace with your deployed Apps Script web app URL
    private let baseURL = "https://script.google.com/macros/s/AKfycbw1bvmTADXkUpfTFydbFkEgTM1SCv09tApTy_JoA98RfvV0VEUSEI_W1qTklH45izvnwQ/exec"

    // Spreadsheet ID from the link you provided
    private let spreadsheetID = "1ilwaETjdCODIs6r-Buj4xsLAL8MK6dEfaoPdQrfzJ8I"

    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var idToken: String?
    private var isDemoMode = false

    private init() {}

    // MARK: - Authentication

    func setDemoMode(_ enabled: Bool) {
        isDemoMode = enabled
        UserDefaults.standard.set(enabled, forKey: "isDemoMode")

        if enabled {
            // Create mock user for demo
            let mockChild = Explorer(
                circle: "Vikings",
                lastName: "Demo",
                firstName: "Maverick",
                adventureName: "Thunderbolt"
            )
            let user = User(
                email: "example@royyoon.com",
                name: "Demo User",
                role: .parent,
                children: [mockChild]
            )
            currentUser = user

            // Cache the demo user
            cacheUser(user)
        }
    }

    func restoreDemoMode() {
        if UserDefaults.standard.bool(forKey: "isDemoMode") {
            isDemoMode = true

            // Restore cached user
            if let user = loadCachedUser() {
                currentUser = user
            }
        }
    }

    func setIDToken(_ token: String) {
        self.idToken = token
        UserDefaults.standard.set(token, forKey: "googleIDToken")
    }

    func getStoredToken() -> String? {
        return UserDefaults.standard.string(forKey: "googleIDToken")
    }

    func clearAuth() {
        idToken = nil
        currentUser = nil
        isDemoMode = false
        UserDefaults.standard.removeObject(forKey: "googleIDToken")
        UserDefaults.standard.removeObject(forKey: "cachedUser")
        UserDefaults.standard.removeObject(forKey: "isDemoMode")
        UserDefaults.standard.removeObject(forKey: "cachedProgress")
    }

    // MARK: - API Calls

    func getMe() async throws -> User {
        guard let token = idToken else {
            throw APIServiceError.noToken
        }

        // Check cache first
        if let cached = loadCachedUser() {
            // Refresh in background
            Task {
                try? await fetchMe(token: token)
            }
            return cached
        }

        // No cache, fetch from network
        return try await fetchMe(token: token)
    }

    private func fetchMe(token: String) async throws -> User {
        let url = URL(string: "\(baseURL)?action=me&token=\(token)")!
        let (data, response) = try await URLSession.shared.data(from: url)

        try checkResponse(response)

        let meResponse = try JSONDecoder().decode(MeResponse.self, from: data)
        let user = User(
            email: meResponse.email,
            name: meResponse.name,
            role: meResponse.role,
            children: meResponse.children
        )

        // Debug logging
        print("🔐 User role: \(user.role)")
        print("👶 Children count: \(user.children?.count ?? 0)")

        // Cache user
        cacheUser(user)

        DispatchQueue.main.async {
            self.currentUser = user
        }

        return user
    }

    func getCatalog() async throws -> [Pin] {
        guard let token = idToken else {
            throw APIServiceError.noToken
        }

        // Check cache
        if let cached = loadCachedCatalog() {
            return cached
        }

        let url = URL(string: "\(baseURL)?action=catalog&token=\(token)")!
        let (data, response) = try await URLSession.shared.data(from: url)

        try checkResponse(response)

        let catalogResponse = try JSONDecoder().decode(CatalogResponse.self, from: data)

        // Cache catalog
        cacheCatalog(catalogResponse.pins)

        return catalogResponse.pins
    }

    func getProgress(circle: String? = nil, forceRefresh: Bool = false) async throws -> [ExplorerProgress] {
        // Return demo data if in demo mode
        if isDemoMode {
            return try await getDemoProgress()
        }

        guard let token = idToken else {
            throw APIServiceError.noToken
        }

        // Return cached data immediately if available and not forcing refresh
        if !forceRefresh, let cached = loadCachedProgress() {
            print("📱 Returning cached progress (\(cached.count) explorers)")

            // Fetch fresh data in background
            Task {
                do {
                    let fresh = try await fetchProgressFromServer(circle: circle, token: token)
                    // Merge with cached data (additive only - never remove progress)
                    let merged = mergeProgress(cached: cached, fresh: fresh)
                    cacheProgress(merged)
                    print("🔄 Background refresh completed (merged)")
                } catch {
                    print("⚠️ Background refresh failed: \(error.localizedDescription)")
                }
            }

            return cached
        }

        // No cache or forcing refresh - fetch from server
        print("🌐 Fetching progress from server...")
        let progress = try await fetchProgressFromServer(circle: circle, token: token)

        // If we have cached data, merge additively
        if let cached = loadCachedProgress() {
            let merged = mergeProgress(cached: cached, fresh: progress)
            cacheProgress(merged)
            return merged
        }

        // Cache the result
        cacheProgress(progress)

        return progress
    }

    private func getDemoProgress() async throws -> [ExplorerProgress] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        guard let mockChild = currentUser?.children?.first else {
            throw APIServiceError.noToken
        }

        // Create random pin progress for demo
        let allPins = PinCatalog.all
        var pins: [String: PinStatus] = [:]

        // Randomly assign statuses to pins
        for pin in allPins {
            let random = Int.random(in: 0...10)
            if random < 2 {
                pins[pin.name] = .earned
            } else if random < 4 {
                pins[pin.name] = .submitted
            } else if random < 7 {
                pins[pin.name] = .open
            } else {
                pins[pin.name] = .notStarted
            }
        }

        // Ensure some specific pins are earned for demo
        pins["Names"] = .earned
        pins["Aims"] = .earned
        pins["Conduct"] = .earned
        pins["Hike"] = .open
        pins["Knife Safety"] = .open
        pins["Fire Safety"] = .submitted

        // Calculate rockers (need 3 pins per journey)
        var rockers: [Journey: Bool] = [:]
        for journey in Journey.allCases {
            let journeyPins = allPins.filter { $0.journey == journey }
            let earnedCount = journeyPins.filter { pins[$0.name] == .earned || pins[$0.name] == .issued }.count
            rockers[journey] = earnedCount >= 3
        }

        return [ExplorerProgress(
            explorer: mockChild,
            pins: pins,
            rockers: rockers,
            hasMedallion: false,
            submissions: []
        )]
    }

    // Merge progress additively - never lose progress
    private func mergeProgress(cached: [ExplorerProgress], fresh: [ExplorerProgress]) -> [ExplorerProgress] {
        var result: [ExplorerProgress] = []

        for freshExplorer in fresh {
            // Find matching cached explorer
            if let cachedExplorer = cached.first(where: { $0.explorer.id == freshExplorer.explorer.id }) {
                // Merge pins - take the higher status (never downgrade)
                var mergedPins: [String: PinStatus] = freshExplorer.pins

                for (pinName, cachedStatus) in cachedExplorer.pins {
                    let freshStatus = freshExplorer.pins[pinName] ?? .notStarted

                    // Priority: issued > earned > submitted > open > notStarted
                    let statusPriority: [PinStatus: Int] = [
                        .issued: 4,
                        .earned: 3,
                        .submitted: 2,
                        .open: 1,
                        .notStarted: 0
                    ]

                    let cachedPriority = statusPriority[cachedStatus] ?? 0
                    let freshPriority = statusPriority[freshStatus] ?? 0

                    // Keep the higher status
                    if cachedPriority > freshPriority {
                        mergedPins[pinName] = cachedStatus
                        print("  📌 Kept cached status for \(pinName): \(cachedStatus.rawValue) (was \(freshStatus.rawValue))")
                    }
                }

                // Create merged explorer
                result.append(ExplorerProgress(
                    explorer: freshExplorer.explorer,
                    pins: mergedPins,
                    rockers: freshExplorer.rockers, // Trust server for rockers
                    hasMedallion: freshExplorer.hasMedallion, // Trust server for medallion
                    submissions: freshExplorer.submissions // Trust server for submissions
                ))
            } else {
                // New explorer, add as-is
                result.append(freshExplorer)
            }
        }

        // Add any explorers that exist in cache but not in fresh (shouldn't happen, but be safe)
        for cachedExplorer in cached {
            if !result.contains(where: { $0.explorer.id == cachedExplorer.explorer.id }) {
                result.append(cachedExplorer)
            }
        }

        return result
    }

    private func fetchProgressFromServer(circle: String?, token: String) async throws -> [ExplorerProgress] {
        var urlString = "\(baseURL)?action=progress&token=\(token)"
        if let circle = circle {
            urlString += "&circle=\(circle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? circle)"
        }

        let url = URL(string: urlString)!

        // Create a custom URLSession with longer timeout
        var request = URLRequest(url: url)
        request.timeoutInterval = 30 // 30 seconds

        let (data, response) = try await URLSession.shared.data(for: request)

        try checkResponse(response)

        // Debug: Print raw JSON response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 Raw JSON response from getProgress:")
            print(jsonString)
        }

        let progressResponse = try JSONDecoder().decode(ProgressResponse.self, from: data)

        // Convert DTOs to ExplorerProgress
        var allExplorers: [ExplorerProgressDTO] = []

        if let circles = progressResponse.circles {
            for circle in circles {
                allExplorers.append(contentsOf: circle.explorers)
            }
        } else if let explorers = progressResponse.explorers {
            allExplorers = explorers
        }

        return allExplorers.map { dto in
            let explorer = Explorer(
                circle: dto.circle,
                lastName: dto.lastName,
                firstName: dto.firstName,
                adventureName: dto.adventureName
            )

            var pins: [String: PinStatus] = [:]
            for (name, status) in dto.pins {
                pins[name] = PinStatus(rawValue: status) ?? .notStarted
            }

            // TODO: Calculate rockers and medallion from pins
            let rockers: [Journey: Bool] = [:]
            let hasMedallion = false

            return ExplorerProgress(
                explorer: explorer,
                pins: pins,
                rockers: rockers,
                hasMedallion: hasMedallion,
                submissions: []
            )
        }
    }

    func submitPin(
        explorer: Explorer,
        pin: String,
        supervisingAdult: String,
        note: String?
    ) async throws {
        guard let token = idToken else {
            throw APIServiceError.noToken
        }

        let request = SubmitPinRequest(
            circle: explorer.circle,
            lastName: explorer.lastName,
            firstName: explorer.firstName,
            pin: pin,
            supervisingAdult: supervisingAdult,
            note: note,
            token: token
        )

        try await post(request: request)
    }

    func reviewSubmission(
        circle: String,
        lastName: String,
        firstName: String,
        pin: String,
        approve: Bool,
        note: String? = nil
    ) async throws {
        guard let token = idToken else {
            throw APIServiceError.noToken
        }

        let request = ReviewSubmissionRequest(
            circle: circle,
            lastName: lastName,
            firstName: firstName,
            pin: pin,
            reviewAction: approve ? "approve" : "sendBack",
            note: note,
            token: token
        )

        try await post(request: request)
    }

    func issuePins(pins: [PinToIssue]) async throws {
        guard let token = idToken else {
            throw APIServiceError.noToken
        }

        let request = IssuePinsRequest(pins: pins, token: token)
        try await post(request: request)
    }

    // MARK: - Private Helpers

    private func post<T: Encodable>(request: T) async throws {
        var urlRequest = URLRequest(url: URL(string: baseURL)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        try checkResponse(response)

        // Check for error response
        if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
            throw APIServiceError.serverError(apiError.error)
        }
    }

    private func checkResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIServiceError.httpError(httpResponse.statusCode)
        }
    }

    // MARK: - Caching

    private func cacheUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "cachedUser")
        }
    }

    private func loadCachedUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: "cachedUser"),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }

    private func cacheCatalog(_ pins: [Pin]) {
        if let encoded = try? JSONEncoder().encode(pins) {
            UserDefaults.standard.set(encoded, forKey: "cachedCatalog")
        }
    }

    private func loadCachedCatalog() -> [Pin]? {
        guard let data = UserDefaults.standard.data(forKey: "cachedCatalog"),
              let pins = try? JSONDecoder().decode([Pin].self, from: data) else {
            return nil
        }
        return pins
    }

    private func cacheProgress(_ progress: [ExplorerProgress]) {
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: "cachedProgress")
            UserDefaults.standard.set(Date(), forKey: "cachedProgressTimestamp")
        }
    }

    private func loadCachedProgress() -> [ExplorerProgress]? {
        guard let data = UserDefaults.standard.data(forKey: "cachedProgress"),
              let progress = try? JSONDecoder().decode([ExplorerProgress].self, from: data) else {
            return nil
        }
        return progress
    }

    private func getCachedProgressAge() -> TimeInterval? {
        guard let timestamp = UserDefaults.standard.object(forKey: "cachedProgressTimestamp") as? Date else {
            return nil
        }
        return Date().timeIntervalSince(timestamp)
    }
}

// MARK: - Errors

enum APIServiceError: LocalizedError {
    case noToken
    case invalidResponse
    case httpError(Int)
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .noToken:
            return "Not signed in. Please sign in with Google."
        case .invalidResponse:
            return "Invalid response from server."
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .serverError(let message):
            return message
        }
    }
}
