package com.schedulingdispatch.controller;

import com.schedulingdispatch.model.User;
import com.schedulingdispatch.util.HibernateUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.hibernate.Session;

import java.io.IOException;
import java.util.List;

@WebServlet("/reports")
public class ReportManagementServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        User loggedInUser =
                (User) session.getAttribute("loggedInUser");

        if (loggedInUser == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        if (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied. Administrator access is required."
            );
            return;
        }

        try (Session dbSession =
                     HibernateUtil.getSessionFactory().openSession()) {

            Long totalUsers = getLongCount(
                    dbSession,
                    "SELECT COUNT(*) FROM users"
            );

            Long activeUsers = getLongCount(
                    dbSession,
                    "SELECT COUNT(*) FROM users WHERE UPPER(status) = 'ACTIVE'"
            );

            Long totalCustomers = getLongCount(
                    dbSession,
                    "SELECT COUNT(*) FROM customers"
            );

            Long activeCustomers = getLongCount(
                    dbSession,
                    "SELECT COUNT(*) FROM customers WHERE UPPER(status) = 'ACTIVE'"
            );

            Long totalEmployees = getLongCount(
                    dbSession,
                    "SELECT COUNT(*) FROM employees"
            );

            Long availableEmployees = getLongCount(
                    dbSession,
                    """
                    SELECT COUNT(*)
                    FROM employees
                    WHERE UPPER(status) = 'ACTIVE'
                      AND UPPER(availability_status) = 'AVAILABLE'
                    """
            );

            Long totalTasks = getLongCount(
                    dbSession,
                    "SELECT COUNT(*) FROM tasks"
            );

            Long pendingTasks = getLongCount(
                    dbSession,
                    """
                    SELECT COUNT(*)
                    FROM tasks
                    WHERE UPPER(status) = 'PENDING'
                    """
            );

            Long inProgressTasks = getLongCount(
                    dbSession,
                    """
                    SELECT COUNT(*)
                    FROM tasks
                    WHERE UPPER(status) = 'IN_PROGRESS'
                    """
            );

            Long completedTasks = getLongCount(
                    dbSession,
                    """
                    SELECT COUNT(*)
                    FROM tasks
                    WHERE UPPER(status) = 'COMPLETED'
                    """
            );

            Long cancelledTasks = getLongCount(
                    dbSession,
                    """
                    SELECT COUNT(*)
                    FROM tasks
                    WHERE UPPER(status) = 'CANCELLED'
                    """
            );

            Long totalSchedules = getLongCount(
                    dbSession,
                    "SELECT COUNT(*) FROM schedules"
            );

            Long scheduledSchedules = getLongCount(
                    dbSession,
                    """
                    SELECT COUNT(*)
                    FROM schedules
                    WHERE UPPER(status) = 'SCHEDULED'
                    """
            );

            Long activeSchedules = getLongCount(
                    dbSession,
                    """
                    SELECT COUNT(*)
                    FROM schedules
                    WHERE UPPER(status) = 'IN_PROGRESS'
                    """
            );

            Long completedSchedules = getLongCount(
                    dbSession,
                    """
                    SELECT COUNT(*)
                    FROM schedules
                    WHERE UPPER(status) = 'COMPLETED'
                    """
            );

            Long cancelledSchedules = getLongCount(
                    dbSession,
                    """
                    SELECT COUNT(*)
                    FROM schedules
                    WHERE UPPER(status) = 'CANCELLED'
                    """
            );

            Long totalDispatches = getLongCount(
                    dbSession,
                    "SELECT COUNT(*) FROM dispatches"
            );

            Long assignedDispatches = getLongCount(
                    dbSession,
                    """
                    SELECT COUNT(*)
                    FROM dispatches
                    WHERE UPPER(dispatch_status) = 'ASSIGNED'
                    """
            );

            Long dispatchedDispatches = getLongCount(
                    dbSession,
                    """
                    SELECT COUNT(*)
                    FROM dispatches
                    WHERE UPPER(dispatch_status) = 'DISPATCHED'
                    """
            );

            Long startedDispatches = getLongCount(
                    dbSession,
                    """
                    SELECT COUNT(*)
                    FROM dispatches
                    WHERE UPPER(dispatch_status) = 'STARTED'
                    """
            );

            Long completedDispatches = getLongCount(
                    dbSession,
                    """
                    SELECT COUNT(*)
                    FROM dispatches
                    WHERE UPPER(dispatch_status) = 'COMPLETED'
                    """
            );

            Long cancelledDispatches = getLongCount(
                    dbSession,
                    """
                    SELECT COUNT(*)
                    FROM dispatches
                    WHERE UPPER(dispatch_status) = 'CANCELLED'
                    """
            );

            List<Object[]> taskPrioritySummary =
                    dbSession.createNativeQuery(
                            """
                            SELECT
                                COALESCE(priority, 'UNKNOWN') AS priority,
                                COUNT(*) AS total
                            FROM tasks
                            GROUP BY priority
                            ORDER BY
                                CASE UPPER(priority)
                                    WHEN 'URGENT' THEN 1
                                    WHEN 'HIGH' THEN 2
                                    WHEN 'MEDIUM' THEN 3
                                    WHEN 'LOW' THEN 4
                                    ELSE 5
                                END
                            """
                    ).getResultList();

            List<Object[]> taskStatusSummary =
                    dbSession.createNativeQuery(
                            """
                            SELECT
                                COALESCE(status, 'UNKNOWN') AS status,
                                COUNT(*) AS total
                            FROM tasks
                            GROUP BY status
                            ORDER BY status
                            """
                    ).getResultList();

            List<Object[]> dispatchStatusSummary =
                    dbSession.createNativeQuery(
                            """
                            SELECT
                                COALESCE(dispatch_status, 'UNKNOWN') AS status,
                                COUNT(*) AS total
                            FROM dispatches
                            GROUP BY dispatch_status
                            ORDER BY dispatch_status
                            """
                    ).getResultList();

            List<Object[]> scheduleStatusSummary =
                    dbSession.createNativeQuery(
                            """
                            SELECT
                                COALESCE(status, 'UNKNOWN') AS status,
                                COUNT(*) AS total
                            FROM schedules
                            GROUP BY status
                            ORDER BY status
                            """
                    ).getResultList();

            request.setAttribute(
                    "totalUsers",
                    totalUsers
            );

            request.setAttribute(
                    "activeUsers",
                    activeUsers
            );

            request.setAttribute(
                    "totalCustomers",
                    totalCustomers
            );

            request.setAttribute(
                    "activeCustomers",
                    activeCustomers
            );

            request.setAttribute(
                    "totalEmployees",
                    totalEmployees
            );

            request.setAttribute(
                    "availableEmployees",
                    availableEmployees
            );

            request.setAttribute(
                    "totalTasks",
                    totalTasks
            );

            request.setAttribute(
                    "pendingTasks",
                    pendingTasks
            );

            request.setAttribute(
                    "inProgressTasks",
                    inProgressTasks
            );

            request.setAttribute(
                    "completedTasks",
                    completedTasks
            );

            request.setAttribute(
                    "cancelledTasks",
                    cancelledTasks
            );

            request.setAttribute(
                    "totalSchedules",
                    totalSchedules
            );

            request.setAttribute(
                    "scheduledSchedules",
                    scheduledSchedules
            );

            request.setAttribute(
                    "activeSchedules",
                    activeSchedules
            );

            request.setAttribute(
                    "completedSchedules",
                    completedSchedules
            );

            request.setAttribute(
                    "cancelledSchedules",
                    cancelledSchedules
            );

            request.setAttribute(
                    "totalDispatches",
                    totalDispatches
            );

            request.setAttribute(
                    "assignedDispatches",
                    assignedDispatches
            );

            request.setAttribute(
                    "dispatchedDispatches",
                    dispatchedDispatches
            );

            request.setAttribute(
                    "startedDispatches",
                    startedDispatches
            );

            request.setAttribute(
                    "completedDispatches",
                    completedDispatches
            );

            request.setAttribute(
                    "cancelledDispatches",
                    cancelledDispatches
            );

            request.setAttribute(
                    "taskPrioritySummary",
                    taskPrioritySummary
            );

            request.setAttribute(
                    "taskStatusSummary",
                    taskStatusSummary
            );

            request.setAttribute(
                    "dispatchStatusSummary",
                    dispatchStatusSummary
            );

            request.setAttribute(
                    "scheduleStatusSummary",
                    scheduleStatusSummary
            );

            request.setAttribute(
                    "user",
                    loggedInUser
            );

            request.getRequestDispatcher(
                    "/reports.jsp"
            ).forward(request, response);

        } catch (Exception exception) {

            exception.printStackTrace();

            request.setAttribute(
                    "error",
                    "Unable to load reports. Please check the database and try again."
            );

            request.setAttribute(
                    "user",
                    loggedInUser
            );

            request.getRequestDispatcher(
                    "/reports.jsp"
            ).forward(request, response);
        }
    }

    private Long getLongCount(
            Session session,
            String sql) {

        Object result =
                session.createNativeQuery(sql)
                        .getSingleResult();

        if (result == null) {
            return 0L;
        }

        if (result instanceof Number number) {
            return number.longValue();
        }

        return Long.parseLong(
                result.toString()
        );
    }
}