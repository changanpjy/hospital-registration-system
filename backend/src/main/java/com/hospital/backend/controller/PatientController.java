package com.hospital.backend.controller;

import com.hospital.backend.common.ApiResponse;
import com.hospital.backend.dto.PatientRequest;
import com.hospital.backend.entity.Patient;
import com.hospital.backend.service.PatientService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/patients")
public class PatientController {
    private final PatientService patientService;

    public PatientController(PatientService patientService) {
        this.patientService = patientService;
    }

    @GetMapping
    public ApiResponse<List<Patient>> list(@RequestParam Long userId) {
        return ApiResponse.ok(patientService.list(userId));
    }

    @PostMapping
    public ApiResponse<Patient> create(@Validated @RequestBody PatientRequest request) {
        return ApiResponse.ok(patientService.create(request));
    }
}
