import Foundation

#if canImport(FoundationModels)
    import FoundationModels
#endif

actor FoodQualityAIRuntime: QualitySummaryResolver {
    private var cache: [String: String] = [:]
    private var isPermanentlyUnavailable = false

    func resolve(_ request: QualitySummaryRequest) async -> String? {
        if let cached = cache[request.key] {
            return cached
        }

        guard !isPermanentlyUnavailable else { return nil }

        let generated = await generate(from: request.prompt)
        let summary = generated.normalizedInlineText
        guard !summary.isEmpty else { return nil }

        cache[request.key] = summary
        return summary
    }

    private func generate(from prompt: String) async -> String? {
        #if canImport(FoundationModels)
            let model = SystemLanguageModel.default
            switch model.availability {
            case .available:
                break
            case .unavailable(let reason):
                if reason == .deviceNotEligible || reason == .appleIntelligenceNotEnabled {
                    isPermanentlyUnavailable = true
                }
                logDebug("Apple Intelligence unavailable: \(reason)")
                return nil
            }

            guard model.supportsLocale(Locale.current) else {
                logDebug("Locale not supported by Apple Intelligence: \(Locale.current.identifier)")
                return nil
            }

            do {
                let session = LanguageModelSession(
                    model: model,
                    instructions: FoodQualityAIInstructions.systemPrompt
                )
                let options = GenerationOptions(maximumResponseTokens: 90)
                let response = try await session.respond(
                    to: prompt,
                    options: options
                )
                return response.content
            } catch let error as LanguageModelSession.GenerationError {
                switch error {
                case .unsupportedLanguageOrLocale:
                    logDebug("Generation failed: unsupported language or locale.")
                case .assetsUnavailable:
                    logDebug(
                        "Generation failed: model assets unavailable (possibly still downloading).")
                default:
                    logDebug("Generation failed with error: \(error.localizedDescription)")
                }
                return nil
            } catch {
                logDebug("Generation failed with unexpected error: \(error.localizedDescription)")
                return nil
            }
        #else
            return nil
        #endif
    }

    private func logDebug(_ message: String) {
        #if DEBUG
            print("[FoodQualityAI] \(message)")
        #endif
    }
}

private struct FoodQualityAIInstructions {
    nonisolated static let systemPrompt = """
        You are a wellness assistant that writes short food summaries.

        Output contract:
        - 1 or 2 sentences only
        - 45 words maximum
        - Sentence 1: brief neutral description of the food
        - Sentence 2: exactly one practical serving or preparation tip
        - If only 1 sentence is used, it must still include exactly one tip

        Rules:
        - Do not mention grades, nutrient values, or concern labels explicitly
        - Use nutrition signals only to guide tone and overall framing
        - For less balanced foods, you may suggest enjoying them occasionally or in moderation
        - For more balanced foods, you may suggest they fit more easily into a regular routine
        - Do not give strict intake rules, medical advice, treatment advice, or disease-prevention claims
        - Plain text only
        - Friendly, neutral, informal tone
        - Return only the summary
        """
}
