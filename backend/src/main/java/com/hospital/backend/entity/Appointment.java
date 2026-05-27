package com.hospital.backend.entity;

import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class Appointment {
    private Long id;
    private String appointmentNo;
    private Long userId;
    private Long patientId;
    private String patientName;
    private Long departmentId;
    private String departmentName;
    private Long doctorId;
    private String doctorName;
    private Long scheduleId;
    private LocalDate visitDate;
    private String period;
    private String status;
    private Integer noticeSent;
    private LocalDateTime cancelTime;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
