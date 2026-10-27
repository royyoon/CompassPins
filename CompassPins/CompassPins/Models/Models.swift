import Foundation

// MARK: - User & Authentication

struct User: Codable {
    let email: String
    let name: String
    let role: UserRole
    let children: [Explorer]?
}

enum UserRole: String, Codable {
    case parent
    case admin
    case unauthorized
}

// MARK: - Explorer

struct Explorer: Identifiable, Codable, Hashable {
    // ID is based on circle, lastName, firstName only (not adventureName)
    var id: String { "\(circle)-\(lastName)-\(firstName)" }
    let circle: String
    let lastName: String
    let firstName: String
    let adventureName: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(circle)
        hasher.combine(lastName)
        hasher.combine(firstName)
        // Don't include adventureName in hash
    }

    static func == (lhs: Explorer, rhs: Explorer) -> Bool {
        lhs.circle == rhs.circle &&
        lhs.lastName == rhs.lastName &&
        lhs.firstName == rhs.firstName
        // Don't compare adventureName - two explorers are the same person even if one has adventureName and one doesn't
    }

    var displayName: String {
        if let adventureName = adventureName, !adventureName.isEmpty {
            return adventureName
        }
        return firstName
    }
}

// MARK: - Pin

struct Pin: Identifiable, Codable {
    var id: String { name }
    let name: String
    let journey: Journey
    let supervision: String?
    let requirements: String?
    let examples: String?
    let imageURL: String?
    let imageURLs: [String]?
    var status: PinStatus = .notStarted

    enum CodingKeys: String, CodingKey {
        case name, journey, supervision, requirements, examples, imageURL, imageURLs
    }
}

enum Journey: String, Codable, CaseIterable {
    case north = "North"
    case east = "East"
    case south = "South"
    case west = "West"

    var displayName: String {
        switch self {
        case .north: return "Family"
        case .east: return "Nature"
        case .south: return "Community"
        case .west: return "Fun"
        }
    }

    var direction: String { rawValue }
}

enum PinStatus: String, Codable {
    case notStarted = "notStarted"
    case open = "O"
    case earned = "P"
    case issued = "X"
    case submitted = "Submitted"

    var displayName: String {
        switch self {
        case .notStarted: return "Not started"
        case .open: return "Not started"
        case .earned: return "Approved"
        case .issued: return "Issued"
        case .submitted: return "Submitted"
        }
    }
}

// MARK: - Progress

struct ExplorerProgress: Identifiable, Codable {
    var id: String { explorer.id }
    let explorer: Explorer
    var pins: [String: PinStatus] // pin name -> status
    var rockers: [Journey: Bool]
    var hasMedallion: Bool
    var submissions: [Submission]

    enum CodingKeys: String, CodingKey {
        case explorer, pins, rockers, hasMedallion, submissions
    }

    func pinStatus(for pinName: String) -> PinStatus {
        pins[pinName] ?? .notStarted
    }

    func journeyProgress(for journey: Journey, allPins: [Pin]) -> (earned: Int, total: Int) {
        let journeyPins = allPins.filter { $0.journey == journey }
        let earned = journeyPins.filter {
            let status = pinStatus(for: $0.name)
            return status == .earned || status == .issued
        }.count
        return (earned, journeyPins.count)
    }
}

// MARK: - Submission

struct Submission: Identifiable, Codable {
    var id: String { "\(timestamp.timeIntervalSince1970)" }
    let timestamp: Date
    let circle: String
    let lastName: String
    let firstName: String
    let pin: String
    let submittedBy: String
    let supervisingAdult: String
    let note: String?
    var status: SubmissionStatus
}

enum SubmissionStatus: String, Codable {
    case submitted = "Submitted"
    case needsMoreInfo = "Needs more info"
    case approved = "Approved"
    case withdrawn = "Withdrawn"
}

// MARK: - API Responses

struct MeResponse: Codable {
    let email: String
    let name: String
    let role: UserRole
    let children: [Explorer]?
}

struct CatalogResponse: Codable {
    let pins: [Pin]
}

struct ProgressResponse: Codable {
    let circle: String?
    let explorers: [ExplorerProgressDTO]?
    let circles: [CircleProgress]?
}

struct ExplorerProgressDTO: Codable {
    let circle: String
    let lastName: String
    let firstName: String
    let adventureName: String?
    let pins: [String: String] // pin name -> "O"|"P"|"X"
}

struct CircleProgress: Codable {
    let circle: String
    let explorers: [ExplorerProgressDTO]
}

// MARK: - API Requests

struct SubmitPinRequest: Codable {
    let action = "submit"
    let circle: String
    let lastName: String
    let firstName: String
    let pin: String
    let supervisingAdult: String
    let note: String?
    let token: String
}

struct ReviewSubmissionRequest: Codable {
    let action = "review"
    let circle: String
    let lastName: String
    let firstName: String
    let pin: String
    let reviewAction: String // "approve" or "sendBack"
    let note: String?
    let token: String

    enum CodingKeys: String, CodingKey {
        case circle, lastName, firstName, pin, note, token
        case reviewAction = "action"
    }
}

struct IssuePinsRequest: Codable {
    let action = "issue"
    let pins: [PinToIssue]
    let token: String
}

struct PinToIssue: Codable {
    let circle: String
    let lastName: String
    let firstName: String
    let pin: String
}

struct APIError: Codable {
    let error: String
    let code: Int?
}
