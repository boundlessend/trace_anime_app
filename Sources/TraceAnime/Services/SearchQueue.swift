actor SearchQueue {
    private let client: TraceMoeClient

    init(client: TraceMoeClient) {
        self.client = client
    }

    func search(input: SearchInput, options: SearchOptions) async throws -> TraceMoeSearchResponse {
        try await client.search(input: input, options: options)
    }
}
