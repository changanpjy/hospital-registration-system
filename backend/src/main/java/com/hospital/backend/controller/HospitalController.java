package com.hospital.backend.controller;

import com.hospital.backend.common.ApiResponse;
import com.hospital.backend.entity.Department;
import com.hospital.backend.entity.Doctor;
import com.hospital.backend.entity.Schedule;
import com.hospital.backend.service.HospitalService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class HospitalController {
    private final HospitalService hospitalService;

    public HospitalController(HospitalService hospitalService) {
        this.hospitalService = hospitalService;
    }

    @GetMapping("/departments")
    public ApiResponse<List<Department>> departments(@RequestParam(required = false) String keyword) {
        return ApiResponse.ok(hospitalService.departments(keyword));
    }

    @GetMapping("/departments/{departmentId}/doctors")
    public ApiResponse<List<Doctor>> doctors(@PathVariable Long departmentId) {
        return ApiResponse.ok(hospitalService.doctors(departmentId));
    }

    @GetMapping("/doctors/{doctorId}/schedules")
    public ApiResponse<List<Schedule>> schedules(@PathVariable Long doctorId) {
        return ApiResponse.ok(hospitalService.schedules(doctorId));
    }

    @GetMapping("/search")
    public ApiResponse<Map<String, Object>> search(@RequestParam(required = false) String keyword) {
        return ApiResponse.ok(hospitalService.search(keyword));
    }
}
