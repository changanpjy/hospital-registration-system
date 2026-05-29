package com.hospital.backend.entity;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class Doctor {
    private Long id;
    private Long departmentId;
    private String departmentName;
    private String name;
    private String title;
    private String specialty;
    private String introduction;
    private Integer status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
