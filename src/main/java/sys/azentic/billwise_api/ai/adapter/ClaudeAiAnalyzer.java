package sys.azentic.billwise_api.ai.adapter;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;
import sys.azentic.billwise_api.ai.port.AiAnalysisRequest;
import sys.azentic.billwise_api.ai.port.AiAnalysisResult;
import sys.azentic.billwise_api.ai.port.AiAnalyzer;

@Component
@ConditionalOnProperty(name = "billwise.ai.provider", havingValue = "claude")
public class ClaudeAiAnalyzer implements AiAnalyzer {

    @Override
    public AiAnalysisResult analyze(AiAnalysisRequest request) {
        throw new UnsupportedOperationException(
                "ClaudeAiAnalyzer aun no esta implementado. Pendiente de Sprint 3.");
    }
}
