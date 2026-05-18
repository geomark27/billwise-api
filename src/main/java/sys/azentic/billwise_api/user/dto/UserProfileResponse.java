package sys.azentic.billwise_api.user.dto;

import sys.azentic.billwise_api.user.model.ExperienceLevel;
import sys.azentic.billwise_api.user.model.MarketTarget;

import java.math.BigDecimal;
import java.util.UUID;

public record UserProfileResponse(
        UUID id,
        String name,
        String email,
        ExperienceLevel experienceLevel,
        BigDecimal hourlyRate,
        MarketTarget marketTarget
) {
}
