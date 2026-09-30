package com.schedulingdispatch.controller;

import com.schedulingdispatch.model.Customer;
import com.schedulingdispatch.model.Employee;
import com.schedulingdispatch.model.Task;
import com.schedulingdispatch.model.User;
import com.schedulingdispatch.service.TaskService;
import com.schedulingdispatch.service.impl.TaskServiceImpl;
import com.schedulingdispatch.util.HibernateUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.hibernate.Session;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;

@WebServlet("/task-management")
public class TaskManagementServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final DateTimeFormatter DATE_TIME_FORMATTER =
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    private TaskService taskService;

    @Override
    public void init() throws ServletException {
        taskService = new TaskServiceImpl();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        User loggedInUser = getLoggedInUser(session);

        if (loggedInUser == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        if (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied."
            );
            return;
        }

        try {

            String keyword = request.getParameter("keyword");
            String editId = request.getParameter("editId");

            List<Task> tasks;

            if (keyword == null || keyword.trim().isEmpty()) {
                tasks = taskService.findAll();
            } else {
                tasks = taskService.search(keyword);
            }

            request.setAttribute("tasks", tasks);
            request.setAttribute("keyword", keyword);

            if (editId != null && !editId.trim().isEmpty()) {

                try {

                    Long id = Long.parseLong(editId);

                    Task editTask = taskService.findById(id);

                    if (editTask != null) {
                        request.setAttribute(
                                "editTask",
                                editTask
                        );
                    } else {
                        request.setAttribute(
                                "error",
                                "Task not found."
                        );
                    }

                } catch (NumberFormatException e) {

                    request.setAttribute(
                            "error",
                            "Invalid task ID."
                    );
                }
            }

            loadCustomers(request);
            loadEmployees(request);

            request.getRequestDispatcher(
                    "/task-management.jsp"
            ).forward(request, response);

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                    "error",
                    "Unable to load task management data."
            );

            loadCustomers(request);
            loadEmployees(request);

            request.getRequestDispatcher(
                    "/task-management.jsp"
            ).forward(request, response);
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        User loggedInUser = getLoggedInUser(session);

        if (loggedInUser == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        if (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied."
            );
            return;
        }

        String action = request.getParameter("action");

        try {

            if ("create".equalsIgnoreCase(action)) {

                createTask(request, loggedInUser);

                response.sendRedirect(
                        request.getContextPath()
                                + "/task-management?success="
                                + "Task created successfully."
                );

            } else if ("update".equalsIgnoreCase(action)) {

                updateTask(request);

                response.sendRedirect(
                        request.getContextPath()
                                + "/task-management?success="
                                + "Task updated successfully."
                );

            } else if ("status".equalsIgnoreCase(action)) {

                changeStatus(request);

                response.sendRedirect(
                        request.getContextPath()
                                + "/task-management?success="
                                + "Task status updated successfully."
                );

            } else if ("delete".equalsIgnoreCase(action)) {

                deleteTask(request);

                response.sendRedirect(
                        request.getContextPath()
                                + "/task-management?success="
                                + "Task deleted successfully."
                );

            } else {

                response.sendRedirect(
                        request.getContextPath()
                                + "/task-management"
                );
            }

        } catch (IllegalArgumentException e) {

            request.setAttribute(
                    "error",
                    e.getMessage()
            );

            doGet(request, response);

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                    "error",
                    "An unexpected error occurred while processing the task."
            );

            doGet(request, response);
        }
    }

    private void createTask(
            HttpServletRequest request,
            User loggedInUser) {

        String title = request.getParameter("title");
        String description = request.getParameter("description");

        Long customerId = parseRequiredId(
                request.getParameter("customerId"),
                "Customer"
        );

        Long employeeId = parseOptionalId(
                request.getParameter("assignedEmployeeId")
        );

        String priority = request.getParameter("priority");
        String status = request.getParameter("status");

        LocalDateTime dueDate = parseDateTime(
                request.getParameter("dueDate")
        );

        Task task = new Task();

        task.setTitle(title);
        task.setDescription(description);
        task.setCustomerId(customerId);
        task.setAssignedEmployeeId(employeeId);
        task.setPriority(priority);
        task.setStatus(status);
        task.setDueDate(dueDate);
        task.setCreatedBy(loggedInUser.getId());

        taskService.createTask(task);
    }

    private void updateTask(HttpServletRequest request) {

        Long taskId = parseRequiredId(
                request.getParameter("taskId"),
                "Task"
        );

        String title = request.getParameter("title");
        String description = request.getParameter("description");

        Long customerId = parseRequiredId(
                request.getParameter("customerId"),
                "Customer"
        );

        Long employeeId = parseOptionalId(
                request.getParameter("assignedEmployeeId")
        );

        String priority = request.getParameter("priority");
        String status = request.getParameter("status");

        LocalDateTime dueDate = parseDateTime(
                request.getParameter("dueDate")
        );

        Task task = taskService.findById(taskId);

        if (task == null) {
            throw new IllegalArgumentException(
                    "Task not found."
            );
        }

        task.setTitle(title);
        task.setDescription(description);
        task.setCustomerId(customerId);
        task.setAssignedEmployeeId(employeeId);
        task.setPriority(priority);
        task.setStatus(status);
        task.setDueDate(dueDate);

        taskService.updateTask(task);
    }

    private void changeStatus(HttpServletRequest request) {

        Long taskId = parseRequiredId(
                request.getParameter("taskId"),
                "Task"
        );

        String status = request.getParameter("status");

        taskService.changeStatus(
                taskId,
                status
        );
    }

    private void deleteTask(HttpServletRequest request) {

        Long taskId = parseRequiredId(
                request.getParameter("taskId"),
                "Task"
        );

        taskService.deleteTask(taskId);
    }

    private void loadCustomers(
            HttpServletRequest request) {

        try (Session session =
                     HibernateUtil.getSessionFactory()
                             .openSession()) {

            List<Customer> customers =
                    session.createQuery(
                            """
                            FROM Customer c
                            WHERE UPPER(c.status) = 'ACTIVE'
                            ORDER BY c.name ASC
                            """,
                            Customer.class
                    ).getResultList();

            request.setAttribute(
                    "customers",
                    customers
            );
        }
    }

    private void loadEmployees(
            HttpServletRequest request) {

        try (Session session =
                     HibernateUtil.getSessionFactory()
                             .openSession()) {

            List<Employee> employees =
                    session.createQuery(
                            """
                            FROM Employee e
                            WHERE UPPER(e.status) = 'ACTIVE'
                              AND UPPER(e.availabilityStatus) = 'AVAILABLE'
                            ORDER BY e.name ASC
                            """,
                            Employee.class
                    ).getResultList();

            request.setAttribute(
                    "employees",
                    employees
            );
        }
    }

    private Long parseRequiredId(
            String value,
            String fieldName) {

        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(
                    fieldName + " is required."
            );
        }

        try {

            Long id = Long.parseLong(value.trim());

            if (id <= 0) {
                throw new IllegalArgumentException(
                        "Invalid " + fieldName + " ID."
                );
            }

            return id;

        } catch (NumberFormatException e) {

            throw new IllegalArgumentException(
                    "Invalid " + fieldName + " ID."
            );
        }
    }

    private Long parseOptionalId(String value) {

        if (value == null || value.trim().isEmpty()) {
            return null;
        }

        try {

            Long id = Long.parseLong(value.trim());

            if (id <= 0) {
                throw new IllegalArgumentException(
                        "Invalid employee ID."
                );
            }

            return id;

        } catch (NumberFormatException e) {

            throw new IllegalArgumentException(
                    "Invalid employee ID."
            );
        }
    }

    private LocalDateTime parseDateTime(String value) {

        if (value == null || value.trim().isEmpty()) {
            return null;
        }

        try {

            return LocalDateTime.parse(
                    value.trim(),
                    DATE_TIME_FORMATTER
            );

        } catch (DateTimeParseException e) {

            throw new IllegalArgumentException(
                    "Invalid due date format."
            );
        }
    }

    private User getLoggedInUser(
            HttpSession session) {

        if (session == null) {
            return null;
        }

        Object userObject =
                session.getAttribute("loggedInUser");

        if (userObject instanceof User) {
            return (User) userObject;
        }

        return null;
    }
}