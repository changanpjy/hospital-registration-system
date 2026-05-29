package com.hospital.backend.controller;

import com.hospital.backend.common.ApiResponse;
import com.hospital.backend.dto.UserUpdateRequest;
import com.hospital.backend.entity.User;
import com.hospital.backend.service.UserService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PutMapping("/{userId}")
    public ApiResponse<User> updateProfile(@PathVariable Long userId,
                                           @Validated @RequestBody UserUpdateRequest request) {
        return ApiResponse.ok(userService.updateProfile(userId, request));
    }
}
