package sys.azentic.billwise_api.user.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sys.azentic.billwise_api.user.dto.UpdateProfileRequest;
import sys.azentic.billwise_api.user.dto.UserProfileResponse;
import sys.azentic.billwise_api.user.model.User;
import sys.azentic.billwise_api.user.repository.UserRepository;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;

    public UserProfileResponse getProfile(User user) {
        return toResponse(user);
    }

    @Transactional
    public UserProfileResponse updateProfile(User user, UpdateProfileRequest request) {
        if (request.name() != null) user.setName(request.name());
        if (request.experienceLevel() != null) user.setExperienceLevel(request.experienceLevel());
        if (request.hourlyRate() != null) user.setHourlyRate(request.hourlyRate());
        if (request.marketTarget() != null) user.setMarketTarget(request.marketTarget());
        return toResponse(userRepository.save(user));
    }

    private UserProfileResponse toResponse(User user) {
        return new UserProfileResponse(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getExperienceLevel(),
                user.getHourlyRate(),
                user.getMarketTarget()
        );
    }
}
