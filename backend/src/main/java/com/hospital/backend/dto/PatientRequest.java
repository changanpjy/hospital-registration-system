package com.hospital.backend.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.time.LocalDate;

@Data
public class PatientRequest {
    @NotNull(message = "不能为空")
    private Long userId;
    @NotBlank(message = "不能为空")
    private String name;
    @NotBlank(message = "不能为空")
    private String idCard;
    @NotBlank(message = "不能为空")
    private String phone;
    private Integer gender;
    private LocalDate birthDate;
}
