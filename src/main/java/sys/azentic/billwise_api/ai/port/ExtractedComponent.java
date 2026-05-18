package sys.azentic.billwise_api.ai.port;

import sys.azentic.billwise_api.estimate.model.Complexity;

public record ExtractedComponent(
        String name,
        String description,
        String type,
        Complexity complexity,
        Complexity ambiguity
) {}
