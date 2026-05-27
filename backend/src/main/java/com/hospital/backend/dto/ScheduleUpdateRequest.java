package com.hospital.backend.dto;

import lombok.Data;

import javax.validation.constraints.Min;
import javax.validation.constraints.NotNull;

@Data
public class ScheduleUpdateRequest {
    @NotNull(message = "不能为空")
    @Min(value = 0, message = "不能小于0")
    private Integer totalCount;
    @NotNull(message = "不能为空")
    @Min(value = 0, message = "不能小于0")
    private Integer availableCount;
    @NotNull(message = "不能为空")
    private String status;
}
