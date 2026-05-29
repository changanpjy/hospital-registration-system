package com.hospital.backend.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;

@Data
public class UserUpdateRequest {
    @NotBlank(message = "不能为空")
    @Size(max = 50, message = "不能超过50个字符")
    private String username;
    @Pattern(regexp = "^1\\d{10}$", message = "必须是以1开头的11位手机号")
    private String phone;
    private String email;
    private String password;
}
