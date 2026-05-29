package com.hospital.backend.controller;

import com.hospital.backend.common.ApiResponse;
import com.hospital.backend.dto.ScheduleUpdateRequest;
import com.hospital.backend.dto.UserStatusRequest;
import com.hospital.backend.entity.User;
import com.hospital.backend.service.AppointmentService;
import com.hospital.backend.service.UserService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {
    private final AppointmentService appointmentService;
    private final UserService userService;

    public AdminController(AppointmentService appointmentService, UserService userService) {
        this.appointmentService = appointmentService;
        this.userService = userService;
    }

    @GetMapping("/statistics")
    public ApiResponse<Map<String, Object>> statistics() {
        return ApiResponse.ok(appointmentService.statistics());
    }

    @PutMapping("/schedules/{scheduleId}")
    public ApiResponse<Void> updateSchedule(@PathVariable Long scheduleId,
                                            @Validated @RequestBody ScheduleUpdateRequest request) {
        appointmentService.updateSchedule(scheduleId, request);
        return ApiResponse.ok(null);
    }

    @GetMapping("/users")
    public ApiResponse<List<User>> users(@RequestParam Long adminId) {
        return ApiResponse.ok(userService.listUsers(adminId));
    }

    @PutMapping("/users/{userId}/status")
    public ApiResponse<Void> updateUserStatus(@PathVariable Long userId,
                                              @Validated @RequestBody UserStatusRequest request) {
        userService.updateStatus(userId, request);
        return ApiResponse.ok(null);
    }
}
