package com.schedulingdispatch.controller;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Collections;
import java.util.List;

import org.hibernate.Session;

import com.schedulingdispatch.model.Customer;
import com.schedulingdispatch.model.Employee;
import com.schedulingdispatch.model.Schedule;
import com.schedulingdispatch.model.User;
import com.schedulingdispatch.service.ScheduleService;
import com.schedulingdispatch.service.impl.ScheduleServiceImpl;
import com.schedulingdispatch.util.HibernateUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/schedule-management")
public class ScheduleManagementServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private ScheduleService scheduleService;

    private static final DateTimeFormatter DATE_TIME_FORMATTER =
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    @Override
    public void init() throws ServletException {
        scheduleService = new ScheduleServiceImpl();
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

        String keyword = request.getParameter("keyword");
        String editId = request.getParameter("editId");

        try {

            List<Schedule> schedules;

            if (keyword == null || keyword.trim().isEmpty()) {
                schedules = scheduleService.findAll();
            } else {
                schedules = scheduleService.search(keyword);
            }

            List<Customer> customers = loadCustomers();
            List<Employee> employees = loadEmployees();

            request.setAttribute("schedules", schedules);
            request.setAttribute("customers", customers);
            request.setAttribute("employees", employees);
            request.setAttribute("keyword", keyword);

            if (editId != null && !editId.trim().isEmpty()) {

                try {

                    Long id = Long.parseLong(editId);

                    Schedule editSchedule =
                            scheduleService.findById(id);

                    if (editSchedule == null) {

                        request.setAttribute(
                                "error",
                                "Schedule not found."
                        );

                    } else {

                        request.setAttribute(
                                "editSchedule",
                                editSchedule
                        );
                    }

                } catch (NumberFormatException exception) {

                    request.setAttribute(
                            "error",
                            "Invalid schedule ID."
                    );
                }
            }

            request.getRequestDispatcher(
                    "/schedule-management.jsp"
            ).forward(request, response);

        } catch (Exception exception) {

            exception.printStackTrace();

            request.setAttribute(
                    "schedules",
                    Collections.emptyList()
            );

            request.setAttribute(
                    "customers",
                    Collections.emptyList()
            );

            request.setAttribute(
                    "employees",
                    Collections.emptyList()
            );

            request.setAttribute(
                    "error",
                    "Unable to load schedule management data."
            );

            request.getRequestDispatcher(
                    "/schedule-management.jsp"
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

                createSchedule(
                        request,
                        response,
                        loggedInUser
                );

                return;
            }

            if ("update".equalsIgnoreCase(action)) {

                updateSchedule(
                        request,
                        response
                );

                return;
            }

            if ("status".equalsIgnoreCase(action)) {

                changeStatus(
                        request,
                        response
                );

                return;
            }

            if ("delete".equalsIgnoreCase(action)) {

                deleteSchedule(
                        request,
                        response
                );

                return;
            }

            request.setAttribute(
                    "error",
                    "Invalid schedule action."
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
                    "An unexpected error occurred while processing the schedule."
            );

            doGet(request, response);
        }
    }

    private void createSchedule(
            HttpServletRequest request,
            HttpServletResponse response,
            User loggedInUser)
            throws IOException {

        Long taskId = parseId(
                request.getParameter("taskId"),
                "task"
        );

        Long customerId = parseId(
                request.getParameter("customerId"),
                "customer"
        );

        Long employeeId =
                parseOptionalId(
                        request.getParameter("employeeId")
                );

        LocalDateTime scheduledStart =
                parseDateTime(
                        request.getParameter("scheduledStart"),
                        "scheduled start"
                );

        LocalDateTime scheduledEnd =
                parseDateTime(
                        request.getParameter("scheduledEnd"),
                        "scheduled end"
                );

        Schedule schedule = new Schedule();

        schedule.setTaskId(taskId);
        schedule.setCustomerId(customerId);
        schedule.setEmployeeId(employeeId);
        schedule.setScheduledStart(scheduledStart);
        schedule.setScheduledEnd(scheduledEnd);

        schedule.setPriority(
                request.getParameter("priority")
        );

        schedule.setStatus(
                request.getParameter("status")
        );

        schedule.setNotes(
                request.getParameter("notes")
        );

        schedule.setCreatedBy(
                loggedInUser.getId()
        );

        scheduleService.createSchedule(schedule);

        response.sendRedirect(
                request.getContextPath()
                + "/schedule-management"
                + "?success=Schedule created successfully."
        );
    }

    private void updateSchedule(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        Long id = parseId(
                request.getParameter("id"),
                "schedule"
        );

        Long taskId = parseId(
                request.getParameter("taskId"),
                "task"
        );

        Long customerId = parseId(
                request.getParameter("customerId"),
                "customer"
        );

        Long employeeId =
                parseOptionalId(
                        request.getParameter("employeeId")
                );

        LocalDateTime scheduledStart =
                parseDateTime(
                        request.getParameter("scheduledStart"),
                        "scheduled start"
                );

        LocalDateTime scheduledEnd =
                parseDateTime(
                        request.getParameter("scheduledEnd"),
                        "scheduled end"
                );

        Schedule schedule =
                scheduleService.findById(id);

        if (schedule == null) {

            throw new IllegalArgumentException(
                    "Schedule not found."
            );
        }

        schedule.setTaskId(taskId);
        schedule.setCustomerId(customerId);
        schedule.setEmployeeId(employeeId);
        schedule.setScheduledStart(scheduledStart);
        schedule.setScheduledEnd(scheduledEnd);

        schedule.setPriority(
                request.getParameter("priority")
        );

        schedule.setStatus(
                request.getParameter("status")
        );

        schedule.setNotes(
                request.getParameter("notes")
        );

        scheduleService.updateSchedule(schedule);

        response.sendRedirect(
                request.getContextPath()
                + "/schedule-management"
                + "?success=Schedule updated successfully."
        );
    }

    private void changeStatus(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        Long id = parseId(
                request.getParameter("id"),
                "schedule"
        );

        String status =
                request.getParameter("status");

        scheduleService.changeStatus(
                id,
                status
        );

        response.sendRedirect(
                request.getContextPath()
                + "/schedule-management"
                + "?success=Schedule status updated successfully."
        );
    }

    private void deleteSchedule(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        Long id = parseId(
                request.getParameter("id"),
                "schedule"
        );

        scheduleService.deleteSchedule(id);

        response.sendRedirect(
                request.getContextPath()
                + "/schedule-management"
                + "?success=Schedule deleted successfully."
        );
    }

    private List<Customer> loadCustomers() {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                    """
                    FROM Customer c
                    WHERE UPPER(c.status) = 'ACTIVE'
                    ORDER BY c.name ASC
                    """,
                    Customer.class
            ).getResultList();
        }
    }

    private List<Employee> loadEmployees() {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                    """
                    FROM Employee e
                    WHERE UPPER(e.status) = 'ACTIVE'
                      AND UPPER(e.availabilityStatus) = 'AVAILABLE'
                    ORDER BY e.name ASC
                    """,
                    Employee.class
            ).getResultList();
        }
    }

    private Long parseId(
            String value,
            String fieldName) {

        if (value == null
                || value.trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Please select a valid "
                    + fieldName
                    + "."
            );
        }

        try {

            return Long.parseLong(
                    value.trim()
            );

        } catch (NumberFormatException exception) {

            throw new IllegalArgumentException(
                    "Invalid "
                    + fieldName
                    + " ID."
            );
        }
    }

    private Long parseOptionalId(String value) {

        if (value == null
                || value.trim().isEmpty()) {

            return null;
        }

        try {

            return Long.parseLong(
                    value.trim()
            );

        } catch (NumberFormatException exception) {

            throw new IllegalArgumentException(
                    "Invalid employee ID."
            );
        }
    }

    private LocalDateTime parseDateTime(
            String value,
            String fieldName) {

        if (value == null
                || value.trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Please enter the "
                    + fieldName
                    + " date and time."
            );
        }

        try {

            return LocalDateTime.parse(
                    value.trim(),
                    DATE_TIME_FORMATTER
            );

        } catch (DateTimeParseException exception) {

            throw new IllegalArgumentException(
                    "Invalid "
                    + fieldName
                    + " date and time."
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