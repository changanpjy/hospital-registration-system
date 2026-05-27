package com.hospital.backend.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

@Data
public class RegisterRequest {
    @NotBlank(message = "不能为空")
    private String username;
    private String phone;
    private String email;
    @NotBlank(message = "不能为空")
    private String password;
}
