import Foundation

enum HTTPError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case serverError
    case statusCode(Int)
    case unknownError(Error)
}

enum AppErrorContext {
    case generic
    case auth
    case food
}

extension Error {
    func feedback(context: AppErrorContext = .generic) -> String {
        if let urlError = self as? URLError,
            let mapped = message(for: urlError)
        {
            return mapped
        }

        if let httpError = self as? HTTPError {
            return message(for: httpError, context: context)
        }

        let fallback = localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        if fallback.isEmpty || fallback.localizedCaseInsensitiveContains("couldn't be completed") {
            return defaultMessage(for: context)
        }
        return fallback
    }

    private func message(for urlError: URLError) -> String? {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return "No internet connection. Please check your network and try again."
        case .cannotConnectToHost, .cannotFindHost, .timedOut:
            return "Unable to reach the server right now. Please try again."
        default:
            return nil
        }
    }

    private func message(for httpError: HTTPError, context: AppErrorContext) -> String {
        switch context {
        case .auth:
            switch httpError {
            case .statusCode(401), .statusCode(403):
                return "Invalid credentials. Please check your username and password."
            case .statusCode(429):
                return "Too many attempts. Please wait a bit and try again."
            case .serverError, .statusCode(500...599), .invalidResponse, .invalidData:
                return "Something went wrong. Please try again in a moment."
            case .unknownError(let underlying):
                let detail = underlying.localizedDescription.trimmingCharacters(
                    in: .whitespacesAndNewlines)
                return detail.isEmpty ? defaultMessage(for: .auth) : detail
            default:
                return defaultMessage(for: .auth)
            }

        case .food:
            switch httpError {
            case .invalidURL:
                return "Invalid request URL. Check your API URL and scanned value."
            case .statusCode(400):
                return "Invalid barcode format."
            case .statusCode(401), .statusCode(403):
                return "Your session expired. Please sign in again."
            case .statusCode(404):
                return "No food found for this barcode."
            case .statusCode(429):
                return "Too many requests. Please wait a few seconds and try again."
            case .serverError, .statusCode(500...599):
                return "The server had an error. Please try again in a moment."
            case .invalidResponse, .invalidData:
                return "The server response could not be processed."
            case .unknownError(let underlying):
                let detail = underlying.localizedDescription.trimmingCharacters(
                    in: .whitespacesAndNewlines)
                return detail.isEmpty ? defaultMessage(for: .food) : detail
            default:
                return defaultMessage(for: .food)
            }

        case .generic:
            switch httpError {
            case .invalidURL:
                return "Invalid request URL."
            case .statusCode(401), .statusCode(403):
                return "You are not authorized. Please sign in again."
            case .statusCode(404):
                return "Requested resource was not found."
            case .statusCode(429):
                return "Too many requests. Please try again shortly."
            case .serverError, .statusCode(500...599):
                return "Server error. Please try again in a moment."
            case .invalidResponse, .invalidData:
                return "Unexpected server response."
            case .unknownError(let underlying):
                let detail = underlying.localizedDescription.trimmingCharacters(
                    in: .whitespacesAndNewlines)
                return detail.isEmpty ? defaultMessage(for: .generic) : detail
            default:
                return defaultMessage(for: .generic)
            }
        }
    }

    private func defaultMessage(for context: AppErrorContext) -> String {
        switch context {
        case .auth:
            return "Login failed. Please try again."
        case .food:
            return "Something went wrong while fetching food."
        case .generic:
            return "Something went wrong. Please try again."
        }
    }
}
