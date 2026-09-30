package com.schedulingdispatch.service.impl;

import com.schedulingdispatch.dao.TaskDAO;
import com.schedulingdispatch.dao.impl.TaskDAOImpl;
import com.schedulingdispatch.model.Task;
import com.schedulingdispatch.service.TaskService;
import com.schedulingdispatch.util.HibernateUtil;

import org.hibernate.Session;

import java.time.LocalDateTime;
import java.util.List;

public class TaskServiceImpl implements TaskService {

    private final TaskDAO taskDAO;

    public TaskServiceImpl() {
        this.taskDAO = new TaskDAOImpl();
    }

    @Override
    public List<Task> findAll() {

        return taskDAO.findAll();
    }

    @Override
    public List<Task> search(String keyword) {

        if (keyword == null || keyword.trim().isEmpty()) {
            return taskDAO.findAll();
        }

        return taskDAO.search(keyword.trim());
    }

    @Override
    public Task findById(Long id) {

        if (id == null || id <= 0) {
            return null;
        }

        return taskDAO.findById(id);
    }

    @Override
    public void createTask(Task task) {

        if (task == null) {
            throw new IllegalArgumentException(
                    "Task information is required."
            );
        }

        validateTask(task);

        if (task.getCreatedAt() == null) {
            task.setCreatedAt(LocalDateTime.now());
        }

        task.setUpdatedAt(LocalDateTime.now());

        if (isBlank(task.getPriority())) {
            task.setPriority("MEDIUM");
        }

        if (isBlank(task.getStatus())) {
            task.setStatus("PENDING");
        }

        task.setPriority(
                task.getPriority().trim().toUpperCase()
        );

        task.setStatus(
                task.getStatus().trim().toUpperCase()
        );

        validatePriority(task.getPriority());

        validateStatus(task.getStatus());

        validateCustomer(task.getCustomerId());

        if (task.getAssignedEmployeeId() != null) {
            validateEmployee(task.getAssignedEmployeeId());
        }

        taskDAO.save(task);
    }

    @Override
    public void updateTask(Task task) {

        if (task == null || task.getId() == null) {
            throw new IllegalArgumentException(
                    "Valid task information is required."
            );
        }

        Task existingTask =
                taskDAO.findById(task.getId());

        if (existingTask == null) {
            throw new IllegalArgumentException(
                    "Task not found."
            );
        }

        validateTask(task);

        if (isBlank(task.getPriority())) {
            task.setPriority(
                    existingTask.getPriority()
            );
        }

        if (isBlank(task.getStatus())) {
            task.setStatus(
                    existingTask.getStatus()
            );
        }

        task.setPriority(
                task.getPriority().trim().toUpperCase()
        );

        task.setStatus(
                task.getStatus().trim().toUpperCase()
        );

        validatePriority(task.getPriority());

        validateStatus(task.getStatus());

        validateCustomer(task.getCustomerId());

        if (task.getAssignedEmployeeId() != null) {
            validateEmployee(task.getAssignedEmployeeId());
        }

        task.setCreatedAt(
                existingTask.getCreatedAt()
        );

        task.setUpdatedAt(
                LocalDateTime.now()
        );

        taskDAO.update(task);
    }

    @Override
    public void deleteTask(Long id) {

        if (id == null || id <= 0) {
            throw new IllegalArgumentException(
                    "Invalid task ID."
            );
        }

        Task task = taskDAO.findById(id);

        if (task == null) {
            throw new IllegalArgumentException(
                    "Task not found."
            );
        }

        taskDAO.delete(task);
    }

    @Override
    public void changeStatus(
            Long id,
            String status) {

        if (id == null || id <= 0) {
            throw new IllegalArgumentException(
                    "Invalid task ID."
            );
        }

        if (isBlank(status)) {
            throw new IllegalArgumentException(
                    "Task status is required."
            );
        }

        String normalizedStatus =
                status.trim().toUpperCase();

        validateStatus(normalizedStatus);

        Task task = taskDAO.findById(id);

        if (task == null) {
            throw new IllegalArgumentException(
                    "Task not found."
            );
        }

        task.setStatus(normalizedStatus);

        task.setUpdatedAt(
                LocalDateTime.now()
        );

        taskDAO.update(task);
    }

    private void validateTask(Task task) {

        if (isBlank(task.getTitle())) {
            throw new IllegalArgumentException(
                    "Task title is required."
            );
        }

        if (task.getTitle().trim().length() > 150) {
            throw new IllegalArgumentException(
                    "Task title cannot exceed 150 characters."
            );
        }

        if (!isBlank(task.getDescription())
                && task.getDescription().trim().length() > 500) {

            throw new IllegalArgumentException(
                    "Task description cannot exceed 500 characters."
            );
        }

        if (task.getCustomerId() == null
                || task.getCustomerId() <= 0) {

            throw new IllegalArgumentException(
                    "Valid customer is required."
            );
        }

        if (task.getDueDate() != null
                && task.getDueDate()
                       .isBefore(LocalDateTime.now())) {

            throw new IllegalArgumentException(
                    "Due date cannot be in the past."
            );
        }
    }

    private void validateCustomer(Long customerId) {

        try (Session session =
                     HibernateUtil.getSessionFactory()
                             .openSession()) {

            Object customer = session.get(
                    com.schedulingdispatch.model.Customer.class,
                    customerId
            );

            if (customer == null) {
                throw new IllegalArgumentException(
                        "Selected customer does not exist."
                );
            }
        }
    }

    private void validateEmployee(Long employeeId) {

        try (Session session =
                     HibernateUtil.getSessionFactory()
                             .openSession()) {

            Object employee = session.get(
                    com.schedulingdispatch.model.Employee.class,
                    employeeId
            );

            if (employee == null) {
                throw new IllegalArgumentException(
                        "Selected employee does not exist."
                );
            }
        }
    }

    private void validatePriority(String priority) {

        String value =
                priority.trim().toUpperCase();

        if (!value.equals("LOW")
                && !value.equals("MEDIUM")
                && !value.equals("HIGH")
                && !value.equals("URGENT")) {

            throw new IllegalArgumentException(
                    "Invalid task priority."
            );
        }
    }

    private void validateStatus(String status) {

        String value =
                status.trim().toUpperCase();

        if (!value.equals("PENDING")
                && !value.equals("IN_PROGRESS")
                && !value.equals("COMPLETED")
                && !value.equals("CANCELLED")) {

            throw new IllegalArgumentException(
                    "Invalid task status."
            );
        }
    }

    private boolean isBlank(String value) {

        return value == null
                || value.trim().isEmpty();
    }
}