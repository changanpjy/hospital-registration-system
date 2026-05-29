package com.hospital.backend.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Pattern;

@Data
public class RegisterRequest {
    @NotBlank(message = "不能为空")
    private String username;
    @Pattern(regexp = "^1\\d{10}$", message = "必须是以1开头的11位手机号")
    private String phone;
    private String email;
    @NotBlank(message = "不能为空")
    private String password;
}
