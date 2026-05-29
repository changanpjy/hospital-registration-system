package com.hospital.backend.entity;

import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class Patient {
    private Long id;
    private Long userId;
    private String name;
    private String idCard;
    private String phone;
    private Integer gender;
    private LocalDate birthDate;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
