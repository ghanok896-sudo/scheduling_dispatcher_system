package com.schedulingdispatch.service.impl;

import java.time.LocalDateTime;
import java.util.List;
import java.util.regex.Pattern;

import org.hibernate.Session;

import com.schedulingdispatch.dao.EmployeeDAO;
import com.schedulingdispatch.dao.impl.EmployeeDAOImpl;
import com.schedulingdispatch.model.Employee;
import com.schedulingdispatch.model.User;
import com.schedulingdispatch.service.EmployeeService;
import com.schedulingdispatch.util.HibernateUtil;

public class EmployeeServiceImpl implements EmployeeService {

    private final EmployeeDAO employeeDAO;

    private static final Pattern EMAIL_PATTERN =
            Pattern.compile(
                    "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$"
            );

    private static final Pattern PHONE_PATTERN =
            Pattern.compile(
                    "^[0-9+()\\- ]{7,20}$"
            );

    private static final Pattern EMPLOYEE_CODE_PATTERN =
            Pattern.compile(
                    "^[A-Za-z0-9_-]+$"
            );

    public EmployeeServiceImpl() {
        this.employeeDAO = new EmployeeDAOImpl();
    }

    @Override
    public List<Employee> findAll() {
        return employeeDAO.findAll();
    }

    @Override
    public List<Employee> search(String keyword) {
        return employeeDAO.search(keyword);
    }

    @Override
    public Employee findById(Long id) {

        if (id == null) {
            return null;
        }

        return employeeDAO.findById(id);
    }

    @Override
    public void createEmployee(Employee employee) {

        if (employee == null) {
            throw new IllegalArgumentException(
                    "Employee information is required."
            );
        }

        validateEmployee(employee);

        /*
         * User is required for every new Employee.
         * The selected users.id will be stored in employees.user_id.
         */
        if (employee.getUserId() == null) {
            throw new IllegalArgumentException(
                    "Please select a login user."
            );
        }

        /*
         * Verify that the selected User exists.
         */
        validateUserExists(employee.getUserId());

        /*
         * Prevent one User from being assigned to
         * more than one Employee.
         */
        Employee existingUserEmployee =
                employeeDAO.findByUserId(employee.getUserId());

        if (existingUserEmployee != null) {
            throw new IllegalArgumentException(
                    "The selected user is already assigned to Employee "
                    + existingUserEmployee.getEmployeeCode() + "."
            );
        }

        /*
         * Employee code must be unique.
         */
        Employee existingEmployee =
                employeeDAO.findByEmployeeCode(
                        employee.getEmployeeCode()
                );

        if (existingEmployee != null) {
            throw new IllegalArgumentException(
                    "Employee code already exists."
            );
        }

        /*
         * Default values.
         */
        if (employee.getAvailabilityStatus() == null
                || employee.getAvailabilityStatus().trim().isEmpty()) {

            employee.setAvailabilityStatus("AVAILABLE");
        }

        if (employee.getStatus() == null
                || employee.getStatus().trim().isEmpty()) {

            employee.setStatus("ACTIVE");
        }

        if (employee.getCreatedAt() == null) {
            employee.setCreatedAt(LocalDateTime.now());
        }

        employeeDAO.save(employee);
    }

    @Override
    public void updateEmployee(Employee employee) {

        if (employee == null || employee.getId() == null) {
            throw new IllegalArgumentException(
                    "Employee information is required."
            );
        }

        validateEmployee(employee);

        /*
         * User is required for an Employee.
         */
        if (employee.getUserId() == null) {
            throw new IllegalArgumentException(
                    "Please select a login user."
            );
        }

        /*
         * Verify that the selected User exists.
         */
        validateUserExists(employee.getUserId());

        /*
         * Check whether the selected User is already assigned
         * to another Employee.
         */
        Employee existingUserEmployee =
                employeeDAO.findByUserId(employee.getUserId());

        if (existingUserEmployee != null
                && !existingUserEmployee.getId().equals(employee.getId())) {

            throw new IllegalArgumentException(
                    "The selected user is already assigned to Employee "
                    + existingUserEmployee.getEmployeeCode() + "."
            );
        }

        /*
         * Check duplicate employee code.
         */
        Employee existingEmployee =
                employeeDAO.findByEmployeeCode(
                        employee.getEmployeeCode()
                );

        if (existingEmployee != null
                && !existingEmployee.getId().equals(employee.getId())) {

            throw new IllegalArgumentException(
                    "Employee code already exists."
            );
        }

        /*
         * Preserve created date if it already exists.
         */
        Employee currentEmployee =
                employeeDAO.findById(employee.getId());

        if (currentEmployee != null) {

            if (employee.getCreatedAt() == null) {
                employee.setCreatedAt(
                        currentEmployee.getCreatedAt()
                );
            }

            /*
             * Preserve default values if required.
             */
            if (employee.getAvailabilityStatus() == null
                    || employee.getAvailabilityStatus()
                    .trim().isEmpty()) {

                employee.setAvailabilityStatus(
                        currentEmployee.getAvailabilityStatus()
                );
            }

            if (employee.getStatus() == null
                    || employee.getStatus().trim().isEmpty()) {

                employee.setStatus(
                        currentEmployee.getStatus()
                );
            }
        }

        employeeDAO.update(employee);
    }

    @Override
    public void changeStatus(Long id, String status) {

        if (id == null) {
            throw new IllegalArgumentException(
                    "Employee ID is required."
            );
        }

        if (status == null
                || status.trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Employee status is required."
            );
        }

        String normalizedStatus =
                status.trim().toUpperCase();

        if (!normalizedStatus.equals("ACTIVE")
                && !normalizedStatus.equals("INACTIVE")) {

            throw new IllegalArgumentException(
                    "Invalid employee status."
            );
        }

        Employee employee =
                employeeDAO.findById(id);

        if (employee == null) {
            throw new IllegalArgumentException(
                    "Employee not found."
            );
        }

        employee.setStatus(normalizedStatus);

        employeeDAO.update(employee);
    }

    @Override
    public void changeAvailabilityStatus(
            Long id,
            String availabilityStatus) {

        if (id == null) {
            throw new IllegalArgumentException(
                    "Employee ID is required."
            );
        }

        if (availabilityStatus == null
                || availabilityStatus.trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Availability status is required."
            );
        }

        String normalizedAvailability =
                availabilityStatus.trim().toUpperCase();

        if (!normalizedAvailability.equals("AVAILABLE")
                && !normalizedAvailability.equals("UNAVAILABLE")
                && !normalizedAvailability.equals("ON_LEAVE")) {

            throw new IllegalArgumentException(
                    "Invalid availability status."
            );
        }

        Employee employee =
                employeeDAO.findById(id);

        if (employee == null) {
            throw new IllegalArgumentException(
                    "Employee not found."
            );
        }

        employee.setAvailabilityStatus(
                normalizedAvailability
        );

        employeeDAO.update(employee);
    }

    private void validateEmployee(Employee employee) {

        String employeeCode =
                employee.getEmployeeCode();

        if (employeeCode == null
                || employeeCode.trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Employee code is required."
            );
        }

        employeeCode = employeeCode.trim();

        if (employeeCode.length() > 50) {
            throw new IllegalArgumentException(
                    "Employee code must not exceed 50 characters."
            );
        }

        if (!EMPLOYEE_CODE_PATTERN.matcher(employeeCode).matches()) {
            throw new IllegalArgumentException(
                    "Employee code can contain only letters, numbers, "
                    + "underscore and hyphen."
            );
        }

        employee.setEmployeeCode(employeeCode);

        String name = employee.getName();

        if (name == null
                || name.trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Employee name is required."
            );
        }

        name = name.trim();

        if (name.length() > 100) {
            throw new IllegalArgumentException(
                    "Employee name must not exceed 100 characters."
            );
        }

        employee.setName(name);

        String email = employee.getEmail();

        if (email != null
                && !email.trim().isEmpty()) {

            email = email.trim();

            if (email.length() > 100) {
                throw new IllegalArgumentException(
                        "Email must not exceed 100 characters."
                );
            }

            if (!EMAIL_PATTERN.matcher(email).matches()) {
                throw new IllegalArgumentException(
                        "Please enter a valid email address."
                );
            }

            employee.setEmail(email);

        } else {
            employee.setEmail(null);
        }

        String phone = employee.getPhone();

        if (phone != null
                && !phone.trim().isEmpty()) {

            phone = phone.trim();

            if (!PHONE_PATTERN.matcher(phone).matches()) {
                throw new IllegalArgumentException(
                        "Please enter a valid phone number."
                );
            }

            employee.setPhone(phone);

        } else {
            employee.setPhone(null);
        }

        String designation =
                employee.getDesignation();

        if (designation != null
                && !designation.trim().isEmpty()) {

            designation = designation.trim();

            if (designation.length() > 100) {
                throw new IllegalArgumentException(
                        "Designation must not exceed 100 characters."
                );
            }

            employee.setDesignation(designation);

        } else {
            employee.setDesignation(null);
        }

        String availability =
                employee.getAvailabilityStatus();

        if (availability != null
                && !availability.trim().isEmpty()) {

            availability =
                    availability.trim().toUpperCase();

            if (!availability.equals("AVAILABLE")
                    && !availability.equals("UNAVAILABLE")
                    && !availability.equals("ON_LEAVE")) {

                throw new IllegalArgumentException(
                        "Invalid availability status."
                );
            }

            employee.setAvailabilityStatus(
                    availability
            );
        }

        String status = employee.getStatus();

        if (status != null
                && !status.trim().isEmpty()) {

            status = status.trim().toUpperCase();

            if (!status.equals("ACTIVE")
                    && !status.equals("INACTIVE")) {

                throw new IllegalArgumentException(
                        "Invalid employee status."
                );
            }

            employee.setStatus(status);
        }
    }

    private void validateUserExists(Long userId) {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            User user =
                    session.get(User.class, userId);

            if (user == null) {
                throw new IllegalArgumentException(
                        "Selected login user was not found."
                );
            }
        }
    }
}