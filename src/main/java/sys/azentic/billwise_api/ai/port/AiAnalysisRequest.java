package sys.azentic.billwise_api.ai.port;

import sys.azentic.billwise_api.estimate.model.InputType;

public record AiAnalysisRequest(
        String rawInput,
        InputType inputType
) {}
