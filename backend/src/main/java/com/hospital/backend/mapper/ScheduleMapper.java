package com.hospital.backend.mapper;

import com.hospital.backend.entity.Schedule;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface ScheduleMapper {
    @Select("select s.*, d.name as doctor_name, d.department_id, dep.name as department_name from schedule s " +
            "join doctor d on d.id = s.doctor_id " +
            "join department dep on dep.id = d.department_id " +
            "where s.id = #{id}")
    Schedule findById(Long id);

    @Select("select s.*, d.name as doctor_name, d.department_id, dep.name as department_name from schedule s " +
            "join doctor d on d.id = s.doctor_id " +
            "join department dep on dep.id = d.department_id " +
            "where s.doctor_id = #{doctorId} " +
            "and s.work_date >= curdate() and s.work_date <= date_add(curdate(), interval 7 day) " +
            "order by s.work_date, field(s.period, 'MORNING', 'AFTERNOON')")
    List<Schedule> findFutureByDoctor(Long doctorId);

    @Update("update schedule set available_count = available_count - 1, " +
            "status = case when available_count - 1 = 0 then 'FULL' else status end " +
            "where id = #{id} and status = 'AVAILABLE' and available_count > 0")
    int decreaseAvailable(Long id);

    @Update("update schedule set available_count = available_count + 1, " +
            "status = case when status = 'FULL' then 'AVAILABLE' else status end " +
            "where id = #{id} and status <> 'STOPPED' and available_count < total_count")
    int increaseAvailable(Long id);

    @Update("update schedule set total_count = #{totalCount}, available_count = #{availableCount}, status = #{status} " +
            "where id = #{id}")
    int updateAdmin(@Param("id") Long id,
                    @Param("totalCount") Integer totalCount,
                    @Param("availableCount") Integer availableCount,
                    @Param("status") String status);
}
