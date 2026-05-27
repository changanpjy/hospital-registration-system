package com.hospital.backend.service;

import com.hospital.backend.common.BusinessException;
import com.hospital.backend.dto.AppointmentRequest;
import com.hospital.backend.dto.ScheduleUpdateRequest;
import com.hospital.backend.entity.Appointment;
import com.hospital.backend.entity.Schedule;
import com.hospital.backend.mapper.AppointmentMapper;
import com.hospital.backend.mapper.PatientMapper;
import com.hospital.backend.mapper.ScheduleMapper;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class AppointmentService {
    private final AppointmentMapper appointmentMapper;
    private final ScheduleMapper scheduleMapper;
    private final PatientMapper patientMapper;

    public AppointmentService(AppointmentMapper appointmentMapper,
                              ScheduleMapper scheduleMapper,
                              PatientMapper patientMapper) {
        this.appointmentMapper = appointmentMapper;
        this.scheduleMapper = scheduleMapper;
        this.patientMapper = patientMapper;
    }

    @Transactional
    public Appointment create(AppointmentRequest request) {
        if (patientMapper.countByUser(request.getPatientId(), request.getUserId()) == 0) {
            throw new BusinessException("就诊人不存在或不属于当前用户");
        }
        Schedule schedule = scheduleMapper.findById(request.getScheduleId());
        if (schedule == null) {
            throw new BusinessException("号源不存在");
        }
        if (!"AVAILABLE".equals(schedule.getStatus()) || schedule.getAvailableCount() == null || schedule.getAvailableCount() <= 0) {
            throw new BusinessException("当前号源不可预约");
        }
        if (!isWithinBookableTime(schedule)) {
            throw new BusinessException("当前时间不可预约该号源");
        }
        if (appointmentMapper.countPatientDepartmentDate(
                request.getPatientId(), schedule.getDepartmentId(), schedule.getWorkDate()) > 0) {
            throw new BusinessException("同一就诊人同一科室同一天只能预约一次");
        }
        if (scheduleMapper.decreaseAvailable(schedule.getId()) == 0) {
            throw new BusinessException(409, "号源已被约满，请选择其他时段");
        }
        Appointment appointment = new Appointment();
        appointment.setAppointmentNo(createAppointmentNo());
        appointment.setUserId(request.getUserId());
        appointment.setPatientId(request.getPatientId());
        appointment.setDepartmentId(schedule.getDepartmentId());
        appointment.setDoctorId(schedule.getDoctorId());
        appointment.setScheduleId(schedule.getId());
        appointment.setVisitDate(schedule.getWorkDate());
        appointment.setPeriod(schedule.getPeriod());
        appointment.setStatus("WAITING");
        appointment.setNoticeSent(1);
        try {
            appointmentMapper.insert(appointment);
        } catch (DuplicateKeyException exception) {
            throw new BusinessException(409, "同一就诊人同一科室同一天只能预约一次");
        }
        return appointmentMapper.findById(appointment.getId());
    }

    public List<Appointment> list(Long userId) {
        appointmentMapper.completeExpired();
        return appointmentMapper.findByUserId(userId);
    }

    @Transactional
    public Appointment cancel(Long appointmentId, Long userId) {
        Appointment appointment = appointmentMapper.findById(appointmentId);
        if (appointment == null || !userId.equals(appointment.getUserId())) {
            throw new BusinessException("预约记录不存在");
        }
        if (!"WAITING".equals(appointment.getStatus())) {
            throw new BusinessException("当前预约状态不可取消");
        }
        if (appointment.getCreateTime().plusMinutes(30).isBefore(LocalDateTime.now())) {
            throw new BusinessException("预约超过30分钟，已不可取消");
        }
        int updated = appointmentMapper.cancelWithinRule(appointmentId, userId);
        if (updated == 0) {
            throw new BusinessException("预约超过30分钟或状态已变更，取消失败");
        }
        scheduleMapper.increaseAvailable(appointment.getScheduleId());
        return appointmentMapper.findById(appointmentId);
    }

    public Map<String, Object> statistics() {
        Map<String, Object> data = new HashMap<>();
        data.put("dailyAppointments", appointmentMapper.countByDate());
        data.put("popularDepartments", appointmentMapper.countByDepartment());
        return data;
    }

    public void updateSchedule(Long id, ScheduleUpdateRequest request) {
        if (request.getAvailableCount() > request.getTotalCount()) {
            throw new BusinessException("剩余号源不能大于总号源");
        }
        if (!"AVAILABLE".equals(request.getStatus()) && !"FULL".equals(request.getStatus()) && !"STOPPED".equals(request.getStatus())) {
            throw new BusinessException("号源状态不合法");
        }
        if (scheduleMapper.updateAdmin(id, request.getTotalCount(), request.getAvailableCount(), request.getStatus()) == 0) {
            throw new BusinessException("号源不存在");
        }
    }

    private String createAppointmentNo() {
        String date = DateTimeFormatter.ofPattern("yyyyMMddHHmmss").format(LocalDateTime.now());
        String random = UUID.randomUUID().toString().replace("-", "").substring(0, 6).toUpperCase();
        return "YYGH" + date + random;
    }

    private boolean isWithinBookableTime(Schedule schedule) {
        LocalDate today = LocalDate.now();
        if (schedule.getWorkDate().isBefore(today) || schedule.getWorkDate().isAfter(today.plusDays(6))) {
            return false;
        }
        if (!schedule.getWorkDate().isEqual(today)) {
            return true;
        }
        return "AFTERNOON".equals(schedule.getPeriod()) && LocalTime.now().isBefore(LocalTime.NOON);
    }
}
