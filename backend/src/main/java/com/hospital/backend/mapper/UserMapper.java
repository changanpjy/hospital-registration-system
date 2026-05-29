package com.hospital.backend.mapper;

import com.hospital.backend.entity.User;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface UserMapper {
    @Select("select * from users where id = #{id}")
    User findById(Long id);

    @Select("select * from users where status = 1 and (username = #{account} or phone = #{account} or email = #{account}) limit 1")
    User findByAccount(String account);

    @Select("select * from users order by role, id")
    List<User> findAll();

    @Insert("insert into users(username, phone, email, password, role, status) " +
            "values(#{username}, #{phone}, #{email}, #{password}, #{role}, 1)")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(User user);

    @Select("select count(1) from users where username = #{username} " +
            "or (#{phone} is not null and phone = #{phone}) " +
            "or (#{email} is not null and email = #{email})")
    int countDuplicate(@Param("username") String username, @Param("phone") String phone, @Param("email") String email);

    @Select("select count(1) from users where id <> #{id} and (username = #{username} " +
            "or (#{phone} is not null and phone = #{phone}) " +
            "or (#{email} is not null and email = #{email}))")
    int countDuplicateExceptId(@Param("id") Long id,
                               @Param("username") String username,
                               @Param("phone") String phone,
                               @Param("email") String email);

    @Update("update users set username = #{username}, phone = #{phone}, email = #{email}, " +
            "password = #{password} where id = #{id}")
    int updateProfile(User user);

    @Update("update users set status = #{status} where id = #{id}")
    int updateStatus(@Param("id") Long id, @Param("status") Integer status);
}
