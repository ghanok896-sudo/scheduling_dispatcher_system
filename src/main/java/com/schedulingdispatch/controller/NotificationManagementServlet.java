package com.schedulingdispatch.controller;

import com.schedulingdispatch.model.Notification;
import com.schedulingdispatch.model.User;
import com.schedulingdispatch.service.NotificationService;
import com.schedulingdispatch.service.impl.NotificationServiceImpl;
import com.schedulingdispatch.service.UserService;
import com.schedulingdispatch.service.impl.UserServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/notification-management")
public class NotificationManagementServlet
        extends HttpServlet {

    private NotificationService notificationService;
    private UserService userService;

    @Override
    public void init() {

        notificationService =
                new NotificationServiceImpl();

        userService =
                new UserServiceImpl();
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

            List<Notification> notifications;

            if (keyword == null
                    || keyword.trim().isEmpty()) {

                notifications =
                        notificationService.findAll();

            } else {

                notifications =
                        notificationService.search(
                                keyword.trim()
                        );
            }

            request.setAttribute(
                    "notifications",
                    notifications
            );

            request.setAttribute(
                    "keyword",
                    keyword
            );

            request.setAttribute(
                    "users",
                    userService.findAll()
            );

            request.setAttribute(
                    "unreadCount",
                    countUnreadNotifications(
                            notifications
                    )
            );

            request.getRequestDispatcher(
                    "/notification-management.jsp"
            ).forward(request, response);

        } catch (Exception exception) {

            exception.printStackTrace();

            request.setAttribute(
                    "error",
                    "Unable to load notifications."
            );

            request.setAttribute(
                    "notifications",
                    List.of()
            );

            request.setAttribute(
                    "users",
                    userService.findAll()
            );

            request.getRequestDispatcher(
                    "/notification-management.jsp"
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

                createNotification(request);

                redirectWithMessage(
                        request,
                        response,
                        "Notification created successfully."
                );

                return;
            }

            if ("update".equalsIgnoreCase(action)) {

                updateNotification(request);

                redirectWithMessage(
                        request,
                        response,
                        "Notification updated successfully."
                );

                return;
            }

            if ("read".equalsIgnoreCase(action)) {

                Long id =
                        parseLong(
                                request.getParameter("id")
                        );

                notificationService.markAsRead(id);

                redirectWithMessage(
                        request,
                        response,
                        "Notification marked as read."
                );

                return;
            }

            if ("readAll".equalsIgnoreCase(action)) {

                Long userId =
                        parseLong(
                                request.getParameter("userId")
                        );

                notificationService.markAllAsRead(
                        userId
                );

                redirectWithMessage(
                        request,
                        response,
                        "Notifications marked as read."
                );

                return;
            }

            if ("delete".equalsIgnoreCase(action)) {

                Long id =
                        parseLong(
                                request.getParameter("id")
                        );

                notificationService.deleteNotification(
                        id
                );

                redirectWithMessage(
                        request,
                        response,
                        "Notification deleted successfully."
                );

                return;
            }

            response.sendRedirect(
                    request.getContextPath()
                            + "/notification-management"
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
                    "Unable to process notification request."
            );

            doGet(request, response);
        }
    }

    private void createNotification(
            HttpServletRequest request) {

        Long userId =
                parseNullableLong(
                        request.getParameter("userId")
                );

        Long scheduleId =
                parseNullableLong(
                        request.getParameter("scheduleId")
                );

        String title =
                trimToNull(
                        request.getParameter("title")
                );

        String message =
                trimToNull(
                        request.getParameter("message")
                );

        String notificationType =
                trimToNull(
                        request.getParameter(
                                "notificationType"
                        )
                );

        Notification notification =
                new Notification();

        notification.setUserId(userId);
        notification.setScheduleId(scheduleId);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setNotificationType(
                notificationType
        );
        notification.setRead(false);
        notification.setCreatedAt(
                LocalDateTime.now()
        );

        notificationService.createNotification(
                notification
        );
    }

    private void updateNotification(
            HttpServletRequest request) {

        Long id =
                parseLong(
                        request.getParameter("id")
                );

        Notification existing =
                notificationService.findById(id);

        if (existing == null) {

            throw new IllegalArgumentException(
                    "Notification not found."
            );
        }

        Long userId =
                parseNullableLong(
                        request.getParameter("userId")
                );

        Long scheduleId =
                parseNullableLong(
                        request.getParameter("scheduleId")
                );

        String title =
                trimToNull(
                        request.getParameter("title")
                );

        String message =
                trimToNull(
                        request.getParameter("message")
                );

        String notificationType =
                trimToNull(
                        request.getParameter(
                                "notificationType"
                        )
                );

        existing.setUserId(userId);
        existing.setScheduleId(scheduleId);
        existing.setTitle(title);
        existing.setMessage(message);
        existing.setNotificationType(
                notificationType
        );

        notificationService.updateNotification(
                existing
        );
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

    private Long parseLong(String value) {

        if (value == null
                || value.trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Valid ID is required."
            );
        }

        try {

            Long id =
                    Long.parseLong(
                            value.trim()
                    );

            if (id <= 0) {

                throw new IllegalArgumentException(
                        "Valid ID is required."
                );
            }

            return id;

        } catch (NumberFormatException exception) {

            throw new IllegalArgumentException(
                    "Invalid ID."
            );
        }
    }

    private Long parseNullableLong(String value) {

        if (value == null
                || value.trim().isEmpty()) {

            return null;
        }

        try {

            Long id =
                    Long.parseLong(
                            value.trim()
                    );

            if (id <= 0) {
                return null;
            }

            return id;

        } catch (NumberFormatException exception) {

            throw new IllegalArgumentException(
                    "Invalid numeric value."
            );
        }
    }

    private String trimToNull(String value) {

        if (value == null) {
            return null;
        }

        String trimmed =
                value.trim();

        return trimmed.isEmpty()
                ? null
                : trimmed;
    }

    private long countUnreadNotifications(
            List<Notification> notifications) {

        if (notifications == null) {
            return 0L;
        }

        return notifications.stream()
                .filter(notification ->
                        notification != null
                                && !notification.isRead())
                .count();
    }

    private void redirectWithMessage(
            HttpServletRequest request,
            HttpServletResponse response,
            String message)
            throws IOException {

        response.sendRedirect(
                request.getContextPath()
                        + "/notification-management?success="
                        + java.net.URLEncoder.encode(
                                message,
                                java.nio.charset.StandardCharsets.UTF_8
                        )
        );
    }
}