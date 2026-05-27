package com.hospital.backend.service;

import com.hospital.backend.entity.Department;
import com.hospital.backend.entity.Doctor;
import com.hospital.backend.entity.Schedule;
import com.hospital.backend.mapper.DepartmentMapper;
import com.hospital.backend.mapper.DoctorMapper;
import com.hospital.backend.mapper.ScheduleMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class HospitalService {
    private final DepartmentMapper departmentMapper;
    private final DoctorMapper doctorMapper;
    private final ScheduleMapper scheduleMapper;

    public HospitalService(DepartmentMapper departmentMapper, DoctorMapper doctorMapper, ScheduleMapper scheduleMapper) {
        this.departmentMapper = departmentMapper;
        this.doctorMapper = doctorMapper;
        this.scheduleMapper = scheduleMapper;
    }

    public List<Department> departments(String keyword) {
        return departmentMapper.findAll(keyword);
    }

    public List<Doctor> doctors(Long departmentId) {
        return doctorMapper.findByDepartment(departmentId);
    }

    public List<Schedule> schedules(Long doctorId) {
        return scheduleMapper.findFutureByDoctor(doctorId);
    }

    public Map<String, Object> search(String keyword) {
        Map<String, Object> result = new HashMap<>();
        result.put("departments", departmentMapper.findAll(keyword));
        result.put("doctors", doctorMapper.search(keyword));
        return result;
    }
}
