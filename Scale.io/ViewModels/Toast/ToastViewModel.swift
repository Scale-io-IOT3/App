internal import Combine
import Foundation

nonisolated enum ToastKey {
    static let global = "global"
    static let main = "main"
    static let add = "add:toasts"
    static let dashboard = "dashboard:toasts"
    static let scale = "scale:toasts"

    nonisolated static func tab(_ rawValue: String) -> String {
        "\(rawValue):toasts"
    }
}

@MainActor
class ToastViewModel: ObservableObject {
    struct Presentation: Equatable {
        let state: ToastState
        let persist: Bool
        let timeout: TimeInterval
    }

    @Published private var storage: [String: Presentation] = [:]

    func toast(for key: String) -> Presentation? {
        storage[key]
    }

    func show(
        _ state: ToastState,
        _ key: String = ToastKey.global,
        persist: Bool = false,
        timeout: TimeInterval = 3
    ) {
        storage[key] = Presentation(
            state: state,
            persist: persist,
            timeout: timeout
        )
    }

    func clear(_ key: String = ToastKey.global) {
        storage.removeValue(forKey: key)
    }

    func clearAll() {
        storage.removeAll()
    }
}
