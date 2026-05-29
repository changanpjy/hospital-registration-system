package com.hospital.backend.controller;

import com.hospital.backend.common.ApiResponse;
import com.hospital.backend.dto.AppointmentRequest;
import com.hospital.backend.entity.Appointment;
import com.hospital.backend.service.AppointmentService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/appointments")
public class AppointmentController {
    private final AppointmentService appointmentService;

    public AppointmentController(AppointmentService appointmentService) {
        this.appointmentService = appointmentService;
    }

    @PostMapping
    public ApiResponse<Appointment> create(@Validated @RequestBody AppointmentRequest request) {
        return ApiResponse.ok(appointmentService.create(request));
    }

    @GetMapping
    public ApiResponse<List<Appointment>> list(@RequestParam Long userId) {
        return ApiResponse.ok(appointmentService.list(userId));
    }

    @PostMapping("/{appointmentId}/cancel")
    public ApiResponse<Appointment> cancel(@PathVariable Long appointmentId, @RequestParam Long userId) {
        return ApiResponse.ok(appointmentService.cancel(appointmentId, userId));
    }
}
