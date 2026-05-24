import Foundation
import Network

protocol NetworkMonitoring: Sendable {
    var isReachable: Bool { get async }
}

actor NetworkMonitor: NetworkMonitoring {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "CommunitySurvey.NetworkMonitor")
    private var reachable = true

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { await self?.setReachable(path.status == .satisfied) }
        }
        monitor.start(queue: queue)
    }

    var isReachable: Bool { reachable }

    private func setReachable(_ value: Bool) {
        reachable = value
    }
}
