package com.billwise.config;

import com.billwise.auth.User;
import com.billwise.auth.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class SuperAdminSeeder implements ApplicationRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${billwise.superadmin.email}")
    private String email;

    @Value("${billwise.superadmin.password}")
    private String password;

    @Value("${billwise.superadmin.name}")
    private String name;

    @Override
    public void run(ApplicationArguments args) {
        if (userRepository.existsByEmail(email)) {
            log.debug("Superadmin already exists, skipping seed.");
            return;
        }

        User superAdmin = User.builder()
                .email(email.toLowerCase().trim())
                .passwordHash(passwordEncoder.encode(password))
                .name(name)
                .role(User.Role.SUPERADMIN)
                .experienceLevel(User.ExperienceLevel.SENIOR)
                .marketTarget(User.MarketTarget.INTERNATIONAL)
                .build();

        userRepository.save(superAdmin);
        log.info("Superadmin created: {}", email);
    }
}
