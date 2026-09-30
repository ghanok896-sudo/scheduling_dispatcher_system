package com.schedulingdispatch.dao;

import com.schedulingdispatch.model.Task;

import java.util.List;

public interface TaskDAO {

    List<Task> findAll();

    List<Task> search(String keyword);

    Task findById(Long id);

    void save(Task task);

    void update(Task task);

    void delete(Task task);
}