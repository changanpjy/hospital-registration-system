package com.hospital.backend.service;

import com.hospital.backend.common.BusinessException;
import com.hospital.backend.dto.LoginRequest;
import com.hospital.backend.dto.RegisterRequest;
import com.hospital.backend.entity.User;
import com.hospital.backend.mapper.UserMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class AuthService {
    private final UserMapper userMapper;

    public AuthService(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public User register(RegisterRequest request) {
        if (!StringUtils.hasText(request.getPhone()) && !StringUtils.hasText(request.getEmail())) {
            throw new BusinessException("手机号或邮箱至少填写一个");
        }
        if (userMapper.countDuplicate(request.getUsername(), request.getPhone(), request.getEmail()) > 0) {
            throw new BusinessException(409, "用户名、手机号或邮箱已被注册");
        }
        User user = new User();
        user.setUsername(request.getUsername());
        user.setPhone(request.getPhone());
        user.setEmail(request.getEmail());
        user.setPassword(request.getPassword());
        user.setRole("PATIENT");
        userMapper.insert(user);
        user.setPassword(null);
        return user;
    }

    public User login(LoginRequest request) {
        User user = userMapper.findByAccount(request.getAccount());
        if (user == null || !request.getPassword().equals(user.getPassword())) {
            throw new BusinessException(401, "账号或密码错误");
        }
        user.setPassword(null);
        return user;
    }
}
