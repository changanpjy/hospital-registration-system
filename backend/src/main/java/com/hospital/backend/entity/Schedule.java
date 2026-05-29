package com.hospital.backend.entity;

import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class Schedule {
    private Long id;
    private Long doctorId;
    private String doctorName;
    private Long departmentId;
    private String departmentName;
    private LocalDate workDate;
    private String period;
    private Integer totalCount;
    private Integer availableCount;
    private String status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
