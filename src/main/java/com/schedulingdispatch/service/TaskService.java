package com.schedulingdispatch.service;

import com.schedulingdispatch.model.Task;

import java.util.List;

public interface TaskService {

    List<Task> findAll();

    List<Task> search(String keyword);

    Task findById(Long id);

    void createTask(Task task);

    void updateTask(Task task);

    void deleteTask(Long id);

    void changeStatus(Long id, String status);
}