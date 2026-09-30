package com.schedulingdispatch.service.impl;

import java.time.LocalDateTime;
import java.util.List;

import com.schedulingdispatch.dao.CustomerDAO;
import com.schedulingdispatch.dao.impl.CustomerDAOImpl;
import com.schedulingdispatch.model.Customer;
import com.schedulingdispatch.service.CustomerService;

public class CustomerServiceImpl implements CustomerService {

    private final CustomerDAO customerDAO;

    public CustomerServiceImpl() {
        this.customerDAO = new CustomerDAOImpl();
    }

    @Override
    public List<Customer> findAll() {
        return customerDAO.findAll();
    }

    @Override
    public List<Customer> search(String keyword) {
        return customerDAO.search(keyword);
    }

    @Override
    public Customer findById(Long id) {

        if (id == null) {
            return null;
        }

        return customerDAO.findById(id);
    }

    @Override
    public void createCustomer(Customer customer) {

        validateCustomer(customer);

        if (customer.getStatus() == null
                || customer.getStatus().trim().isEmpty()) {

            customer.setStatus("ACTIVE");
        }

        customer.setName(customer.getName().trim());

        if (customer.getEmail() != null) {
            customer.setEmail(customer.getEmail().trim());
        }

        customer.setPhone(customer.getPhone().trim());

        if (customer.getAddress() != null) {
            customer.setAddress(customer.getAddress().trim());
        }

        if (customer.getServiceDetails() != null) {
            customer.setServiceDetails(
                    customer.getServiceDetails().trim());
        }

        customer.setStatus(customer.getStatus().trim().toUpperCase());

        if (customer.getCreatedAt() == null) {
            customer.setCreatedAt(LocalDateTime.now());
        }

        customerDAO.save(customer);
    }

    @Override
    public void updateCustomer(Customer customer) {

        if (customer == null || customer.getId() == null) {
            throw new IllegalArgumentException(
                    "Customer ID is required.");
        }

        validateCustomer(customer);

        Customer existingCustomer =
                customerDAO.findById(customer.getId());

        if (existingCustomer == null) {
            throw new IllegalArgumentException(
                    "Customer not found.");
        }

        existingCustomer.setName(
                customer.getName().trim());

        if (customer.getEmail() != null) {
            existingCustomer.setEmail(
                    customer.getEmail().trim());
        } else {
            existingCustomer.setEmail(null);
        }

        existingCustomer.setPhone(
                customer.getPhone().trim());

        if (customer.getAddress() != null) {
            existingCustomer.setAddress(
                    customer.getAddress().trim());
        } else {
            existingCustomer.setAddress(null);
        }

        if (customer.getServiceDetails() != null) {
            existingCustomer.setServiceDetails(
                    customer.getServiceDetails().trim());
        } else {
            existingCustomer.setServiceDetails(null);
        }

        if (customer.getStatus() != null
                && !customer.getStatus().trim().isEmpty()) {

            existingCustomer.setStatus(
                    customer.getStatus()
                            .trim()
                            .toUpperCase());
        }

        customerDAO.update(existingCustomer);
    }

    @Override
    public void changeStatus(Long id, String status) {

        if (id == null) {
            throw new IllegalArgumentException(
                    "Customer ID is required.");
        }

        if (status == null || status.trim().isEmpty()) {
            throw new IllegalArgumentException(
                    "Customer status is required.");
        }

        String normalizedStatus =
                status.trim().toUpperCase();

        if (!"ACTIVE".equals(normalizedStatus)
                && !"INACTIVE".equals(normalizedStatus)) {

            throw new IllegalArgumentException(
                    "Invalid customer status.");
        }

        Customer customer = customerDAO.findById(id);

        if (customer == null) {
            throw new IllegalArgumentException(
                    "Customer not found.");
        }

        customer.setStatus(normalizedStatus);

        customerDAO.update(customer);
    }

    private void validateCustomer(Customer customer) {

        if (customer == null) {
            throw new IllegalArgumentException(
                    "Customer details are required.");
        }

        if (customer.getName() == null
                || customer.getName().trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Customer name is required.");
        }

        if (customer.getName().trim().length() > 100) {
            throw new IllegalArgumentException(
                    "Customer name cannot exceed 100 characters.");
        }

        if (customer.getEmail() != null
                && !customer.getEmail().trim().isEmpty()) {

            String email =
                    customer.getEmail().trim();

            if (email.length() > 100) {
                throw new IllegalArgumentException(
                        "Email cannot exceed 100 characters.");
            }

            if (!email.matches(
                    "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {

                throw new IllegalArgumentException(
                        "Please enter a valid email address.");
            }
        }

        if (customer.getPhone() == null
                || customer.getPhone().trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Phone number is required.");
        }

        String phone =
                customer.getPhone().trim();

        if (!phone.matches("^[0-9+()\\- ]{7,20}$")) {
            throw new IllegalArgumentException(
                    "Please enter a valid phone number.");
        }

        if (customer.getAddress() != null
                && customer.getAddress().length() > 255) {

            throw new IllegalArgumentException(
                    "Address cannot exceed 255 characters.");
        }

        if (customer.getServiceDetails() != null
                && customer.getServiceDetails().length() > 500) {

            throw new IllegalArgumentException(
                    "Service details cannot exceed 500 characters.");
        }
    }
}