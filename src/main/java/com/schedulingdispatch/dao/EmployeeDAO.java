package com.schedulingdispatch.dao;

import com.schedulingdispatch.model.Employee;

import java.util.List;

public interface EmployeeDAO {

    List<Employee> findAll();

    List<Employee> search(String keyword);

    Employee findById(Long id);

    Employee findByEmployeeCode(String employeeCode);

    Employee findByUserId(Long userId);

    void save(Employee employee);

    void update(Employee employee);

    void delete(Employee employee);
}