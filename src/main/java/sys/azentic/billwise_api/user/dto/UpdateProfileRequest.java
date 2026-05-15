package sys.azentic.billwise_api.user.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import sys.azentic.billwise_api.user.model.ExperienceLevel;
import sys.azentic.billwise_api.user.model.MarketTarget;

import java.math.BigDecimal;

public record UpdateProfileRequest(
        String name,
        ExperienceLevel experienceLevel,
        @DecimalMin("0.0") @Digits(integer = 8, fraction = 2) BigDecimal hourlyRate,
        MarketTarget marketTarget
) { }
