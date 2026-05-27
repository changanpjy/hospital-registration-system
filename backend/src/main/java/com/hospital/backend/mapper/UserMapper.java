package com.hospital.backend.mapper;

import com.hospital.backend.entity.User;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface UserMapper {
    @Select("select * from users where id = #{id}")
    User findById(Long id);

    @Select("select * from users where status = 1 and (username = #{account} or phone = #{account} or email = #{account}) limit 1")
    User findByAccount(String account);

    @Insert("insert into users(username, phone, email, password, role, status) " +
            "values(#{username}, #{phone}, #{email}, #{password}, #{role}, 1)")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(User user);

    @Select("select count(1) from users where username = #{username} " +
            "or (#{phone} is not null and phone = #{phone}) " +
            "or (#{email} is not null and email = #{email})")
    int countDuplicate(@Param("username") String username, @Param("phone") String phone, @Param("email") String email);
}
