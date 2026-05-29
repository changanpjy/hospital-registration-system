package com.hospital.backend.mapper;

import com.hospital.backend.entity.Doctor;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface DoctorMapper {
    @Select("select d.*, dep.name as department_name from doctor d " +
            "join department dep on dep.id = d.department_id " +
            "where d.department_id = #{departmentId} and d.status = 1 order by d.id")
    List<Doctor> findByDepartment(Long departmentId);

    @Select("select d.*, dep.name as department_name from doctor d " +
            "join department dep on dep.id = d.department_id " +
            "where d.id = #{id} and d.status = 1")
    Doctor findById(Long id);

    @Select("<script>" +
            "select d.*, dep.name as department_name from doctor d " +
            "join department dep on dep.id = d.department_id " +
            "where d.status = 1 and dep.status = 1 " +
            "<if test='keyword != null and keyword != \"\"'>" +
            "and (d.name like concat('%', #{keyword}, '%') or dep.name like concat('%', #{keyword}, '%'))" +
            "</if> order by dep.id, d.id" +
            "</script>")
    List<Doctor> search(@Param("keyword") String keyword);
}
