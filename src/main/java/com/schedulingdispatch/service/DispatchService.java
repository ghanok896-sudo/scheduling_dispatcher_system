package com.schedulingdispatch.service;

import com.schedulingdispatch.model.Dispatch;

import java.util.List;

public interface DispatchService {

    List<Dispatch> findAll();

    List<Dispatch> search(String keyword);

    Dispatch findById(Long id);

    Dispatch findByScheduleId(Long scheduleId);

    void createDispatch(Dispatch dispatch);

    void updateDispatch(Dispatch dispatch);

    void changeStatus(Long id, String status);

    void deleteDispatch(Long id);
}