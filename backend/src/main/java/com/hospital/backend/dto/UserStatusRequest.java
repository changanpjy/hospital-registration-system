package com.hospital.backend.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;

@Data
public class UserStatusRequest {
    @NotNull(message = "不能为空")
    private Long adminId;
    @NotNull(message = "不能为空")
    private Integer status;
}
