package com.hospital.backend.service;

import com.hospital.backend.common.BusinessException;
import com.hospital.backend.dto.PatientRequest;
import com.hospital.backend.entity.Patient;
import com.hospital.backend.mapper.PatientMapper;
import com.hospital.backend.mapper.UserMapper;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PatientService {
    private final PatientMapper patientMapper;
    private final UserMapper userMapper;

    public PatientService(PatientMapper patientMapper, UserMapper userMapper) {
        this.patientMapper = patientMapper;
        this.userMapper = userMapper;
    }

    public List<Patient> list(Long userId) {
        return patientMapper.findByUserId(userId);
    }

    public Patient create(PatientRequest request) {
        if (userMapper.findById(request.getUserId()) == null) {
            throw new BusinessException("用户不存在");
        }
        Patient patient = new Patient();
        patient.setUserId(request.getUserId());
        patient.setName(request.getName());
        patient.setIdCard(request.getIdCard());
        patient.setPhone(request.getPhone());
        patient.setGender(request.getGender());
        patient.setBirthDate(request.getBirthDate());
        patientMapper.insert(patient);
        return patient;
    }
}
