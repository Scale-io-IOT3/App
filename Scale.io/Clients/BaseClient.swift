import Foundation

enum HTTPError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case statusCode(Int)
    case unknownError(Error)
}

struct EmptyBody: Encodable {}


class BaseClient {
    private let baseURL = "http://localhost:5175/"
    static let shared = BaseClient()

    private init() {}

    func get<T: Decodable>(endpoint: String) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw HTTPError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)

        try validate(response: response)

        return try decode(data: data)
    }

    func post<T: Encodable, U: Decodable>(endpoint: String, request: T? = nil)async throws -> U {
        let urlString = baseURL + endpoint

        guard let url = URL(string: urlString) else {
            throw HTTPError.invalidURL
        }

        var _request = URLRequest(url: url)
        _request.httpMethod = "POST"
        _request.addToken()

        let body = try encode(body: request ?? EmptyBody() as! T)

        _request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: _request)

        try validate(response: response)

        return try decode(data: data)
    }

    private func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.invalidResponse
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            print("HTTP Error: \(httpResponse.statusCode)")
            throw HTTPError.statusCode(httpResponse.statusCode)
        }
    }

    private func decode<T: Decodable>(data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw HTTPError.invalidData
        }
    }

    private func encode<T: Encodable>(body: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        do {
            return try encoder.encode(body)
        } catch {
            throw HTTPError.invalidData
        }
    }
}

extension URLRequest {
    mutating func addToken() {
        let token = TokenHandler.shared.retrieveToken()
        addValue("application/json", forHTTPHeaderField: "Content-Type")
        addValue("Bearer \(String(describing: token))", forHTTPHeaderField: "Authorization")
    }
}
