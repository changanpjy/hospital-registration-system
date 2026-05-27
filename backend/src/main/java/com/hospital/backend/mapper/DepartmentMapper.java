package com.hospital.backend.mapper;

import com.hospital.backend.entity.Department;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface DepartmentMapper {
    @Select("<script>" +
            "select * from department where status = 1 " +
            "<if test='keyword != null and keyword != \"\"'>and name like concat('%', #{keyword}, '%')</if> " +
            "order by id" +
            "</script>")
    List<Department> findAll(@Param("keyword") String keyword);

    @Select("select * from department where id = #{id} and status = 1")
    Department findById(Long id);
}
