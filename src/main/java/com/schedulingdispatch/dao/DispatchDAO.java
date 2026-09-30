package com.schedulingdispatch.dao;

import com.schedulingdispatch.model.Dispatch;

import java.util.List;

public interface DispatchDAO {

    List<Dispatch> findAll();

    List<Dispatch> search(String keyword);

    Dispatch findById(Long id);

    Dispatch findByScheduleId(Long scheduleId);

    boolean existsByScheduleId(Long scheduleId);

    void save(Dispatch dispatch);

    void update(Dispatch dispatch);

    void delete(Dispatch dispatch);
}