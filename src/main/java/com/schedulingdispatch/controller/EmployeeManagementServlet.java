package com.schedulingdispatch.controller;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

import org.hibernate.Session;

import com.schedulingdispatch.model.Employee;
import com.schedulingdispatch.model.User;
import com.schedulingdispatch.service.EmployeeService;
import com.schedulingdispatch.service.impl.EmployeeServiceImpl;
import com.schedulingdispatch.util.HibernateUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class EmployeeManagementServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private EmployeeService employeeService;

    @Override
    public void init() throws ServletException {
        employeeService = new EmployeeServiceImpl();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        User loggedInUser =
                getLoggedInUser(session);

        if (loggedInUser == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        if (!"ADMIN".equalsIgnoreCase(
                loggedInUser.getRole())) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied."
            );
            return;
        }

        String keyword =
                request.getParameter("keyword");

        String editId =
                request.getParameter("editId");

        try {

            List<Employee> employees;

            if (keyword == null
                    || keyword.trim().isEmpty()) {

                employees =
                        employeeService.findAll();

            } else {

                employees =
                        employeeService.search(
                                keyword.trim()
                        );
            }

            List<User> availableUsers =
                    loadAvailableUsers();

            request.setAttribute(
                    "employees",
                    employees
            );

            request.setAttribute(
                    "availableUsers",
                    availableUsers
            );

            request.setAttribute(
                    "keyword",
                    keyword
            );

            if (editId != null
                    && !editId.trim().isEmpty()) {

                try {

                    Long id =
                            Long.parseLong(
                                    editId.trim()
                            );

                    Employee editEmployee =
                            employeeService.findById(id);

                    if (editEmployee == null) {

                        request.setAttribute(
                                "error",
                                "Employee not found."
                        );

                    } else {

                        request.setAttribute(
                                "editEmployee",
                                editEmployee
                        );
                    }

                } catch (NumberFormatException exception) {

                    request.setAttribute(
                            "error",
                            "Invalid employee ID."
                    );
                }
            }

            request.getRequestDispatcher(
                    "/employee-management.jsp"
            ).forward(request, response);

        } catch (Exception exception) {

            exception.printStackTrace();

            request.setAttribute(
                    "employees",
                    Collections.emptyList()
            );

            request.setAttribute(
                    "availableUsers",
                    Collections.emptyList()
            );

            request.setAttribute(
                    "error",
                    "Unable to load employee management data."
            );

            request.getRequestDispatcher(
                    "/employee-management.jsp"
            ).forward(request, response);
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session =
                request.getSession(false);

        User loggedInUser =
                getLoggedInUser(session);

        if (loggedInUser == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        if (!"ADMIN".equalsIgnoreCase(
                loggedInUser.getRole())) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied."
            );
            return;
        }

        String action =
                request.getParameter("action");

        try {

            if ("create".equalsIgnoreCase(action)) {

                createEmployee(request);

                response.sendRedirect(
                        request.getContextPath()
                                + "/employee-management?success="
                                + "Employee+created+successfully."
                );

                return;
            }

            if ("update".equalsIgnoreCase(action)) {

                updateEmployee(request);

                response.sendRedirect(
                        request.getContextPath()
                                + "/employee-management?success="
                                + "Employee+updated+successfully."
                );

                return;
            }

            if ("status".equalsIgnoreCase(action)) {

                changeEmployeeStatus(request);

                response.sendRedirect(
                        request.getContextPath()
                                + "/employee-management?success="
                                + "Employee+status+updated+successfully."
                );

                return;
            }

            if ("availability".equalsIgnoreCase(action)) {

                changeAvailabilityStatus(request);

                response.sendRedirect(
                        request.getContextPath()
                                + "/employee-management?success="
                                + "Employee+availability+updated+successfully."
                );

                return;
            }

            request.setAttribute(
                    "error",
                    "Invalid employee action."
            );

            doGet(request, response);

        } catch (IllegalArgumentException exception) {

            request.setAttribute(
                    "error",
                    exception.getMessage()
            );

            doGet(request, response);

        } catch (Exception exception) {

            exception.printStackTrace();

            request.setAttribute(
                    "error",
                    "An unexpected error occurred while processing the request."
            );

            doGet(request, response);
        }
    }

    private void createEmployee(
            HttpServletRequest request) {

        Long userId =
                parseOptionalId(
                        request.getParameter("userId")
                );

        Employee employee =
                new Employee();

        employee.setUserId(userId);

        employee.setEmployeeCode(
                request.getParameter("employeeCode")
        );

        employee.setName(
                request.getParameter("name")
        );

        employee.setEmail(
                request.getParameter("email")
        );

        employee.setPhone(
                request.getParameter("phone")
        );

        employee.setDesignation(
                request.getParameter("designation")
        );

        employee.setAvailabilityStatus(
                request.getParameter(
                        "availabilityStatus"
                )
        );

        employee.setStatus(
                request.getParameter("status")
        );

        employeeService.createEmployee(employee);
    }

    private void updateEmployee(
            HttpServletRequest request) {

        Long id =
                parseRequiredId(
                        request.getParameter("id"),
                        "Employee ID is required."
                );

        Employee employee =
                employeeService.findById(id);

        if (employee == null) {

            throw new IllegalArgumentException(
                    "Employee not found."
            );
        }

        Long userId =
                parseOptionalId(
                        request.getParameter("userId")
                );

        employee.setUserId(userId);

        employee.setEmployeeCode(
                request.getParameter("employeeCode")
        );

        employee.setName(
                request.getParameter("name")
        );

        employee.setEmail(
                request.getParameter("email")
        );

        employee.setPhone(
                request.getParameter("phone")
        );

        employee.setDesignation(
                request.getParameter("designation")
        );

        employee.setAvailabilityStatus(
                request.getParameter(
                        "availabilityStatus"
                )
        );

        employee.setStatus(
                request.getParameter("status")
        );

        employeeService.updateEmployee(employee);
    }

    private void changeEmployeeStatus(
            HttpServletRequest request) {

        Long id =
                parseRequiredId(
                        request.getParameter("id"),
                        "Employee ID is required."
                );

        String status =
                request.getParameter("status");

        employeeService.changeStatus(
                id,
                status
        );
    }

    private void changeAvailabilityStatus(
            HttpServletRequest request) {

        Long id =
                parseRequiredId(
                        request.getParameter("id"),
                        "Employee ID is required."
                );

        String availabilityStatus =
                request.getParameter(
                        "availabilityStatus"
                );

        employeeService.changeAvailabilityStatus(
                id,
                availabilityStatus
        );
    }

    private List<User> loadAvailableUsers() {

        try (Session session =
                     HibernateUtil
                             .getSessionFactory()
                             .openSession()) {

            return session.createQuery(
                    """
                    FROM User u
                    WHERE UPPER(u.role) = 'EMPLOYEE'
                    ORDER BY u.id ASC
                    """,
                    User.class
            ).getResultList();
        }
    }

    private Long parseOptionalId(
            String value) {

        if (value == null
                || value.trim().isEmpty()
                || "null".equalsIgnoreCase(
                        value.trim())) {

            return null;
        }

        try {

            return Long.parseLong(
                    value.trim()
            );

        } catch (NumberFormatException exception) {

            throw new IllegalArgumentException(
                    "Invalid ID value."
            );
        }
    }

    private Long parseRequiredId(
            String value,
            String message) {

        if (value == null
                || value.trim().isEmpty()) {

            throw new IllegalArgumentException(
                    message
            );
        }

        try {

            return Long.parseLong(
                    value.trim()
            );

        } catch (NumberFormatException exception) {

            throw new IllegalArgumentException(
                    message
            );
        }
    }

    private User getLoggedInUser(
            HttpSession session) {

        if (session == null) {
            return null;
        }

        Object userObject =
                session.getAttribute(
                        "loggedInUser"
                );

        if (userObject instanceof User) {

            return (User) userObject;
        }

        return null;
    }
}