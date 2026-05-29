package com.hospital.backend.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;

@Data
public class AppointmentRequest {
    @NotNull(message = "不能为空")
    private Long userId;
    @NotNull(message = "不能为空")
    private Long patientId;
    @NotNull(message = "不能为空")
    private Long scheduleId;
}
