package sys.azentic.billwise_api.ai.port;

import java.util.List;

public record AiAnalysisResult(
        List<ExtractedComponent> components,
        String model,
        int promptTokens,
        int completionTokens
) {
    public int totalTokens() {
        return promptTokens + completionTokens;
    }

    public static AiAnalysisResult empty(String model) {
        return new AiAnalysisResult(List.of(), model, 0, 0);
    }
}
