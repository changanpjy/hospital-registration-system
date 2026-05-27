package com.hospital.backend.controller;

import com.hospital.backend.common.ApiResponse;
import com.hospital.backend.dto.ScheduleUpdateRequest;
import com.hospital.backend.service.AppointmentService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {
    private final AppointmentService appointmentService;

    public AdminController(AppointmentService appointmentService) {
        this.appointmentService = appointmentService;
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
}
