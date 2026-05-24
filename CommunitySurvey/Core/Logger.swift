import OSLog

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "CommunitySurvey"

    static let app = Logger(subsystem: subsystem, category: "App")
    static let network = Logger(subsystem: subsystem, category: "Network")
    static let security = Logger(subsystem: subsystem, category: "Security")
    static let auth = Logger(subsystem: subsystem, category: "Authentication")
}
