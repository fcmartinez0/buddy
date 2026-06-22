import Foundation
import CoreMotion

class PedometerManager: ObservableObject {
    private let pedometer = CMPedometer()

    static var isSupported: Bool {
        CMPedometer.isDistanceAvailable() && CMPedometer.isStepCountingAvailable()
    }

    // Query total distance walked since a given start date.
    // Calls back on the main thread with meters walked.
    func queryDistance(from startDate: Date, completion: @escaping (Double) -> Void) {
        guard Self.isSupported else { completion(0); return }
        pedometer.queryPedometerData(from: startDate, to: Date()) { data, error in
            let meters = data?.distance?.doubleValue ?? 0
            DispatchQueue.main.async { completion(meters) }
        }
    }

    // Start live updates. Each update fires with the cumulative distance
    // since startDate (same origin as queryDistance).
    func startUpdates(from startDate: Date, onUpdate: @escaping (Double) -> Void) {
        guard Self.isSupported else { return }
        pedometer.startUpdates(from: startDate) { data, error in
            guard let data, error == nil else { return }
            let meters = data.distance?.doubleValue ?? 0
            DispatchQueue.main.async { onUpdate(meters) }
        }
    }

    func stopUpdates() {
        pedometer.stopUpdates()
    }
}
