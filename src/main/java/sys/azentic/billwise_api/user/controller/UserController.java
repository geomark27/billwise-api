package sys.azentic.billwise_api.user.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.hibernate.sql.Update;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import sys.azentic.billwise_api.user.dto.UpdateProfileRequest;
import sys.azentic.billwise_api.user.dto.UserProfileResponse;
import sys.azentic.billwise_api.user.model.User;
import sys.azentic.billwise_api.user.service.UserService;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public UserProfileResponse getProfile(@AuthenticationPrincipal User user) {
        return userService.getProfile(user);
    }

    @PatchMapping("/me")
    public UserProfileResponse updateProfile(@AuthenticationPrincipal User user,
                                             @Valid @RequestBody UpdateProfileRequest request){
        return userService.updateProfile(user, request);
    }

}
