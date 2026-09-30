package com.schedulingdispatch.controller;

import com.schedulingdispatch.model.Dispatch;
import com.schedulingdispatch.model.Employee;
import com.schedulingdispatch.model.Schedule;
import com.schedulingdispatch.model.User;
import com.schedulingdispatch.service.DispatchService;
import com.schedulingdispatch.service.impl.DispatchServiceImpl;
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
import java.util.List;

@WebServlet("/dispatch-management")
public class DispatchManagementServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private DispatchService dispatchService;

    private static final DateTimeFormatter DATE_TIME_FORMATTER =
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    @Override
    public void init() throws ServletException {
        dispatchService = new DispatchServiceImpl();
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
                    request.getContextPath()
                            + "/login"
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

        try {

            String keyword =
                    request.getParameter("keyword");

            String editId =
                    request.getParameter("editId");

            List<Dispatch> dispatches;

            if (keyword == null
                    || keyword.trim().isEmpty()) {

                dispatches =
                        dispatchService.findAll();

            } else {

                dispatches =
                        dispatchService.search(keyword);
            }

            request.setAttribute(
                    "dispatches",
                    dispatches
            );

            request.setAttribute(
                    "keyword",
                    keyword
            );

            if (editId != null
                    && !editId.trim().isEmpty()) {

                try {

                    Long id =
                            Long.parseLong(editId);

                    Dispatch editDispatch =
                            dispatchService.findById(id);

                    if (editDispatch != null) {

                        request.setAttribute(
                                "editDispatch",
                                editDispatch
                        );

                    } else {

                        request.setAttribute(
                                "error",
                                "Dispatch not found."
                        );
                    }

                } catch (NumberFormatException exception) {

                    request.setAttribute(
                            "error",
                            "Invalid dispatch ID."
                    );
                }
            }

            loadSchedules(request);
            loadEmployees(request);

            request.getRequestDispatcher(
                    "/dispatch-management.jsp"
            ).forward(request, response);

        } catch (Exception exception) {

            exception.printStackTrace();

            request.setAttribute(
                    "error",
                    "Unable to load dispatch management data."
            );

            loadSchedules(request);
            loadEmployees(request);

            request.getRequestDispatcher(
                    "/dispatch-management.jsp"
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
                    request.getContextPath()
                            + "/login"
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

                createDispatch(request);

                response.sendRedirect(
                        request.getContextPath()
                                + "/dispatch-management?success="
                                + "Dispatch created successfully."
                );

                return;
            }

            if ("update".equalsIgnoreCase(action)) {

                updateDispatch(request);

                response.sendRedirect(
                        request.getContextPath()
                                + "/dispatch-management?success="
                                + "Dispatch updated successfully."
                );

                return;
            }

            if ("status".equalsIgnoreCase(action)) {

                changeStatus(request);

                response.sendRedirect(
                        request.getContextPath()
                                + "/dispatch-management?success="
                                + "Dispatch status updated successfully."
                );

                return;
            }

            if ("delete".equalsIgnoreCase(action)) {

                deleteDispatch(request);

                response.sendRedirect(
                        request.getContextPath()
                                + "/dispatch-management?success="
                                + "Dispatch deleted successfully."
                );

                return;
            }

            response.sendRedirect(
                    request.getContextPath()
                            + "/dispatch-management?error="
                            + "Invalid action."
            );

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
                    "Unable to process the dispatch request. Please try again."
            );

            doGet(request, response);
        }
    }

    private void createDispatch(
            HttpServletRequest request) {

        Long scheduleId =
                parseId(
                        request.getParameter("scheduleId")
                );

        Long employeeId =
                parseId(
                        request.getParameter("employeeId")
                );

        String status =
                request.getParameter("dispatchStatus");

        String remarks =
                request.getParameter("remarks");

        Dispatch dispatch =
                new Dispatch();

        dispatch.setScheduleId(scheduleId);
        dispatch.setEmployeeId(employeeId);
        dispatch.setDispatchStatus(status);
        dispatch.setRemarks(remarks);

        dispatchService.createDispatch(dispatch);
    }

    private void updateDispatch(
            HttpServletRequest request) {

        Long id =
                parseId(
                        request.getParameter("id")
                );

        Long scheduleId =
                parseId(
                        request.getParameter("scheduleId")
                );

        Long employeeId =
                parseId(
                        request.getParameter("employeeId")
                );

        String status =
                request.getParameter("dispatchStatus");

        String remarks =
                request.getParameter("remarks");

        Dispatch dispatch =
                dispatchService.findById(id);

        if (dispatch == null) {
            throw new IllegalArgumentException(
                    "Dispatch not found."
            );
        }

        dispatch.setScheduleId(scheduleId);
        dispatch.setEmployeeId(employeeId);
        dispatch.setDispatchStatus(status);
        dispatch.setRemarks(remarks);

        dispatchService.updateDispatch(dispatch);
    }

    private void changeStatus(
            HttpServletRequest request) {

        Long id =
                parseId(
                        request.getParameter("id")
                );

        String status =
                request.getParameter("status");

        if (status == null
                || status.trim().isEmpty()) {

            status =
                    request.getParameter(
                            "dispatchStatus"
                    );
        }

        dispatchService.changeStatus(
                id,
                status
        );
    }

    private void deleteDispatch(
            HttpServletRequest request) {

        Long id =
                parseId(
                        request.getParameter("id")
                );

        dispatchService.deleteDispatch(id);
    }

    private void loadSchedules(
            HttpServletRequest request) {

        try (Session session =
                     HibernateUtil.getSessionFactory()
                             .openSession()) {

            List<Schedule> schedules =
                    session.createQuery(
                            """
                            FROM Schedule s
                            WHERE UPPER(s.status) <> 'CANCELLED'
                            ORDER BY s.scheduledStart ASC
                            """,
                            Schedule.class
                    ).getResultList();

            request.setAttribute(
                    "schedules",
                    schedules
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

    private Long parseId(String value) {

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
                    "Invalid ID value."
            );
        }
    }

    private LocalDateTime parseDateTime(
            String value) {

        if (value == null
                || value.trim().isEmpty()) {

            return null;
        }

        try {

            return LocalDateTime.parse(
                    value.trim(),
                    DATE_TIME_FORMATTER
            );

        } catch (Exception exception) {

            throw new IllegalArgumentException(
                    "Invalid date and time."
            );
        }
    }

    private User getLoggedInUser(
            HttpSession session) {

        if (session == null) {
            return null;
        }

        Object user =
                session.getAttribute(
                        "loggedInUser"
                );

        if (user instanceof User) {
            return (User) user;
        }

        return null;
    }
}