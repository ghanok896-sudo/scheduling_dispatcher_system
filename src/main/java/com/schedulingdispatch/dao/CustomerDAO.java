package com.schedulingdispatch.dao;

import com.schedulingdispatch.model.Customer;

import java.util.List;

public interface CustomerDAO {

    List<Customer> findAll();

    List<Customer> search(String keyword);

    Customer findById(Long id);

    void save(Customer customer);

    void update(Customer customer);

    void delete(Customer customer);
}