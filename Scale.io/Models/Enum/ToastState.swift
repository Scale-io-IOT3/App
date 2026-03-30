import SwiftUI

enum ToastState {
    case loading(String)
    case error(String)
    case success(String)
    case info(String)
    case warning(String)
    case custom(
        message: String,
        icon: String? = nil,
        tint: Color = .secondary,
        showsProgress: Bool = false
    )

    var message: String {
        switch self {
        case .loading(let message),
            .error(let message),
            .success(let message),
            .info(let message),
            .warning(let message):
            return message
        case .custom(let message, _, _, _):
            return message
        }
    }

    var icon: String? {
        switch self {
        case .loading:
            return nil
        case .error:
            return "xmark.octagon.fill"
        case .success:
            return "checkmark.circle.fill"
        case .info:
            return "info.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .custom(_, let icon, _, _):
            return icon
        }
    }

    var tint: Color {
        switch self {
        case .loading:
            return .secondary
        case .error:
            return .red
        case .success:
            return .green
        case .info:
            return .secondary
        case .warning:
            return .orange
        case .custom(_, _, let tint, _):
            return tint
        }
    }

    var showsProgress: Bool {
        switch self {
        case .loading:
            return true
        case .custom(_, _, _, let showsProgress):
            return showsProgress
        default:
            return false
        }
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var signature: String {
        switch self {
        case .loading(let message):
            return "loading|\(message)"
        case .error(let message):
            return "error|\(message)"
        case .success(let message):
            return "success|\(message)"
        case .info(let message):
            return "info|\(message)"
        case .warning(let message):
            return "warning|\(message)"
        case .custom(let message, let icon, _, let showsProgress):
            return "custom|\(message)|\(icon ?? "nil")|\(showsProgress)"
        }
    }
}
