package com.schedulingdispatch.service;

import com.schedulingdispatch.model.Schedule;

import java.util.List;

public interface ScheduleService {

    List<Schedule> findAll();

    List<Schedule> search(String keyword);

    Schedule findById(Long id);

    void createSchedule(Schedule schedule);

    void updateSchedule(Schedule schedule);

    void deleteSchedule(Long id);

    void changeStatus(Long id, String status);
}