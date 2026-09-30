package com.schedulingdispatch.service;

import com.schedulingdispatch.model.Customer;

import java.util.List;

public interface CustomerService {

    List<Customer> findAll();

    List<Customer> search(String keyword);

    Customer findById(Long id);

    void createCustomer(Customer customer);

    void updateCustomer(Customer customer);

    void changeStatus(Long id, String status);
}