package com.hospital.backend.service;

import com.hospital.backend.common.BusinessException;
import com.hospital.backend.dto.UserStatusRequest;
import com.hospital.backend.dto.UserUpdateRequest;
import com.hospital.backend.entity.User;
import com.hospital.backend.mapper.UserMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
public class UserService {
    private final UserMapper userMapper;

    public UserService(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public User updateProfile(Long userId, UserUpdateRequest request) {
        User existing = userMapper.findById(userId);
        if (existing == null) {
            throw new BusinessException("用户不存在");
        }

        String username = trimToNull(request.getUsername());
        String phone = trimToNull(request.getPhone());
        String email = trimToNull(request.getEmail());
        String password = trimToNull(request.getPassword());

        if (!StringUtils.hasText(username)) {
            throw new BusinessException("请填写用户名");
        }
        if (!StringUtils.hasText(phone) && !StringUtils.hasText(email)) {
            throw new BusinessException("请至少保留手机号或邮箱");
        }
        if (userMapper.countDuplicateExceptId(userId, username, phone, email) > 0) {
            throw new BusinessException(409, "用户名、手机号或邮箱已被占用");
        }

        existing.setUsername(username);
        existing.setPhone(phone);
        existing.setEmail(email);
        if (StringUtils.hasText(password)) {
            existing.setPassword(password);
        }
        userMapper.updateProfile(existing);
        existing.setPassword(null);
        return existing;
    }

    public List<User> listUsers(Long adminId) {
        requireAdmin(adminId);
        List<User> users = userMapper.findAll();
        users.forEach(user -> user.setPassword(null));
        return users;
    }

    public void updateStatus(Long userId, UserStatusRequest request) {
        requireAdmin(request.getAdminId());
        if (request.getStatus() != 0 && request.getStatus() != 1) {
            throw new BusinessException("用户状态只能是启用或禁用");
        }
        if (request.getAdminId().equals(userId) && request.getStatus() == 0) {
            throw new BusinessException("不能禁用当前管理员账号");
        }
        if (userMapper.updateStatus(userId, request.getStatus()) == 0) {
            throw new BusinessException("用户不存在");
        }
    }

    private void requireAdmin(Long adminId) {
        User admin = userMapper.findById(adminId);
        if (admin == null || !"ADMIN".equals(admin.getRole())) {
            throw new BusinessException(403, "仅管理员可操作");
        }
    }

    private String trimToNull(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        return value.trim();
    }
}
