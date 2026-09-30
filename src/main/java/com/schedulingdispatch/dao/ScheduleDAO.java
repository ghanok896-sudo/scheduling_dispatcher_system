package com.schedulingdispatch.dao;

import com.schedulingdispatch.model.Schedule;

import java.time.LocalDateTime;
import java.util.List;

public interface ScheduleDAO {

    List<Schedule> findAll();

    List<Schedule> search(String keyword);

    Schedule findById(Long id);

    void save(Schedule schedule);

    void update(Schedule schedule);

    void delete(Schedule schedule);

    boolean hasEmployeeOverlap(
            Long employeeId,
            LocalDateTime scheduledStart,
            LocalDateTime scheduledEnd,
            Long excludeScheduleId
    );
}