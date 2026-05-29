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
        String username = trimToNull(request.getUsername());
        String phone = trimToNull(request.getPhone());
        String email = trimToNull(request.getEmail());
        if (!StringUtils.hasText(username)) {
            throw new BusinessException("请填写用户名");
        }
        if (!StringUtils.hasText(phone) && !StringUtils.hasText(email)) {
            throw new BusinessException("请填写手机号或邮箱");
        }
        if (StringUtils.hasText(phone) && StringUtils.hasText(email)) {
            throw new BusinessException("手机号和邮箱请选择一种方式注册");
        }

        if (userMapper.countDuplicate(username, phone, email) > 0) {
            throw new BusinessException(409, "用户名、手机号或邮箱已被注册");
        }
        User user = new User();
        user.setUsername(username);
        user.setPhone(phone);
        user.setEmail(email);
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

    private String trimToNull(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        return value.trim();
    }
}
