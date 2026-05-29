package com.hospital.backend.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;
import java.time.LocalDate;

@Data
public class PatientRequest {
    @NotNull(message = "不能为空")
    private Long userId;
    @NotBlank(message = "不能为空")
    @Size(max = 50, message = "不能超过50个字符")
    private String name;
    @NotBlank(message = "不能为空")
    @Pattern(regexp = "^\\d{17}[\\dXx]$", message = "必须是18位身份证号")
    private String idCard;
    @NotBlank(message = "不能为空")
    @Pattern(regexp = "^1\\d{10}$", message = "必须是以1开头的11位手机号")
    private String phone;
    private Integer gender;
    private LocalDate birthDate;
}
