package com.hospital.backend.mapper;

import com.hospital.backend.entity.Patient;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface PatientMapper {
    @Select("select * from patient where id = #{id}")
    Patient findById(Long id);

    @Select("select * from patient where user_id = #{userId} order by id desc")
    List<Patient> findByUserId(Long userId);

    @Select("select count(1) from patient where id = #{patientId} and user_id = #{userId}")
    int countByUser(@Param("patientId") Long patientId, @Param("userId") Long userId);

    @Insert("insert into patient(user_id, name, id_card, phone, gender, birth_date) " +
            "values(#{userId}, #{name}, #{idCard}, #{phone}, #{gender}, #{birthDate})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(Patient patient);
}
