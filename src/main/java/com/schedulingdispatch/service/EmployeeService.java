package com.schedulingdispatch.service;

import com.schedulingdispatch.model.Employee;

import java.util.List;

public interface EmployeeService {

    List<Employee> findAll();

    List<Employee> search(String keyword);

    Employee findById(Long id);

    void createEmployee(Employee employee);

    void updateEmployee(Employee employee);

    void changeStatus(Long id, String status);

    void changeAvailabilityStatus(Long id, String availabilityStatus);
}