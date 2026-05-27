package com.hospital.backend.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

@Data
public class LoginRequest {
    @NotBlank(message = "不能为空")
    private String account;
    @NotBlank(message = "不能为空")
    private String password;
}
