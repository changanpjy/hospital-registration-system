package com.hospital.backend.mapper;

import com.hospital.backend.entity.Appointment;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Mapper
public interface AppointmentMapper {
    @Insert("insert into appointment(appointment_no, user_id, patient_id, department_id, doctor_id, schedule_id, " +
            "visit_date, period, status, notice_sent) values(#{appointmentNo}, #{userId}, #{patientId}, " +
            "#{departmentId}, #{doctorId}, #{scheduleId}, #{visitDate}, #{period}, #{status}, #{noticeSent})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(Appointment appointment);

    @Select("select count(1) from appointment where patient_id = #{patientId} and department_id = #{departmentId} " +
            "and visit_date = #{visitDate}")
    int countPatientDepartmentDate(@Param("patientId") Long patientId,
                                   @Param("departmentId") Long departmentId,
                                   @Param("visitDate") LocalDate visitDate);

    @Select("select a.*, p.name as patient_name, dep.name as department_name, d.name as doctor_name from appointment a " +
            "join patient p on p.id = a.patient_id " +
            "join department dep on dep.id = a.department_id " +
            "join doctor d on d.id = a.doctor_id " +
            "where a.id = #{id}")
    Appointment findById(Long id);

    @Select("select a.*, p.name as patient_name, dep.name as department_name, d.name as doctor_name from appointment a " +
            "join patient p on p.id = a.patient_id " +
            "join department dep on dep.id = a.department_id " +
            "join doctor d on d.id = a.doctor_id " +
            "where a.user_id = #{userId} order by a.create_time desc")
    List<Appointment> findByUserId(Long userId);

    @Update("update appointment set status = 'CANCELLED', cancel_time = now() " +
            "where id = #{id} and user_id = #{userId} and status = 'WAITING' " +
            "and timestampdiff(minute, create_time, now()) <= 30")
    int cancelWithinRule(@Param("id") Long id, @Param("userId") Long userId);

    @Update("update appointment set status = 'COMPLETED' where visit_date < curdate() and status = 'WAITING'")
    int completeExpired();

    @Select("select date(visit_date) as visitDate, count(1) as total from appointment " +
            "where status <> 'CANCELLED' group by date(visit_date) order by visit_date")
    List<Map<String, Object>> countByDate();

    @Select("select dep.name as departmentName, count(1) as total from appointment a " +
            "join department dep on dep.id = a.department_id " +
            "where a.status <> 'CANCELLED' group by dep.id, dep.name order by total desc")
    List<Map<String, Object>> countByDepartment();
}
