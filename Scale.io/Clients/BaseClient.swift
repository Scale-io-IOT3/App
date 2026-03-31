import Foundation

struct EmptyBody: Encodable {}

class BaseClient {
    private let baseURL: String = Config.API
    static let shared = BaseClient()

    private init() {}

    func get<T: Decodable>(endpoint: String) async throws -> T {
        guard let url = makeURL(endpoint: endpoint) else {
            throw HTTPError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        await request.addToken()
        let (data, response) = try await URLSession.shared.data(for: request)

        try validate(response: response)

        return try decode(data: data)
    }

    func post<T: Encodable, U: Decodable>(
        endpoint: String,
        request: T? = nil,
        debug: Bool = false,
        withAuth: Bool = true
    )
        async throws -> U
    {
        guard let url = makeURL(endpoint: endpoint) else {
            throw HTTPError.invalidURL
        }

        var _request = URLRequest(url: url)
        _request.httpMethod = "POST"

        if withAuth {
            await _request.addToken()
        } else {
            _request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let body = try encode(body: request ?? EmptyBody() as! T)
        _request.httpBody = body

        if debug {
            self.debug(request: _request)
        }

        let (data, response) = try await URLSession.shared.data(for: _request)

        try validate(response: response)

        return try decode(data: data)
    }

    private func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            print("HTTP Error: \(httpResponse.statusCode)")
            if (500...599).contains(httpResponse.statusCode) {
                throw HTTPError.serverError
            }
            throw HTTPError.statusCode(httpResponse.statusCode)
        }
    }

    private func decode<T: Decodable>(data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

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

    private func debug(request: URLRequest) {
        if let json = String(data: request.httpBody ?? Data(), encoding: .utf8) {
            print("➡️ Headers: \(request.allHTTPHeaderFields ?? [:])")
            print("➡️ Body: \(json)")
        }
    }

    private func makeURL(endpoint: String) -> URL? {
        let normalizedBase = baseURL.hasSuffix("/") ? baseURL : "\(baseURL)/"
        let normalizedEndpoint = endpoint.hasPrefix("/") ? String(endpoint.dropFirst()) : endpoint
        return URL(string: normalizedBase + normalizedEndpoint)
    }
}

extension URLRequest {
    mutating func addToken() async {
        setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let token = await TokenHandler.shared.get() else {
            return
        }
        setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}
