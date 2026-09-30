<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.schedulingdispatch.model.Notification" %>
<%@ page import="com.schedulingdispatch.model.User" %>

<%
    User user =
            (User) session.getAttribute("loggedInUser");

    if (user == null) {
        response.sendRedirect(
                request.getContextPath()
                        + "/login"
        );
        return;
    }

    if (!"ADMIN".equalsIgnoreCase(
            user.getRole())) {

        response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Access denied."
        );
        return;
    }

    String contextPath =
            request.getContextPath();

    String fullName =
            user.getFullName() == null
                    ? user.getUsername()
                    : user.getFullName();

    String firstLetter =
            fullName == null
                    || fullName.isEmpty()
                    ? "A"
                    : fullName.substring(
                            0,
                            1
                    ).toUpperCase();

    String keyword =
            (String) request.getAttribute(
                    "keyword"
            );

    String success =
            request.getParameter(
                    "success"
            );

    String error =
            (String) request.getAttribute(
                    "error"
            );

    Long unreadCountValue =
            (Long) request.getAttribute(
                    "unreadCount"
            );

    long unreadCount =
            unreadCountValue == null
                    ? 0
                    : unreadCountValue;

    List<Notification> notifications =
            (List<Notification>)
                    request.getAttribute(
                            "notifications"
                    );

    DateTimeFormatter formatter =
            DateTimeFormatter.ofPattern(
                    "dd-MM-yyyy HH:mm"
            );
%>

<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Notifications - Scheduling & Dispatching System
    </title>

    <style>

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family:
                    "Segoe UI",
                    Arial,
                    sans-serif;
            background: #f3f7fc;
            color: #172b46;
            min-height: 100vh;
        }

        .top-header {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            height: 72px;
            background: #1e2a3a;
            color: white;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 15px;
            z-index: 1000;
        }

        .brand {
            font-size: 15px;
            font-weight: 700;
        }

        .header-user {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 11px;
        }

        .avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: #344258;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
        }

        .sidebar {
            position: fixed;
            top: 72px;
            left: 0;
            bottom: 0;
            width: 132px;
            background: #101a2a;
            padding: 18px 8px;
            z-index: 900;
        }

        .menu-title {
            color: #91a2ba;
            font-size: 8px;
            margin: 0 6px 12px;
            text-transform: uppercase;
        }

        .sidebar-link {
            display: block;
            color: white;
            text-decoration: none;
            font-size: 10px;
            font-weight: 600;
            padding: 9px 7px;
            border-radius: 4px;
            margin-bottom: 4px;
        }

        .sidebar-link:hover {
            background: #27354a;
        }

        .sidebar-link.active {
            background: #3a4659;
        }

        .account-title {
            color: #91a2ba;
            font-size: 8px;
            margin: 25px 6px 12px;
            text-transform: uppercase;
        }

        .main-content {
            margin-left: 132px;
            padding: 92px 15px 30px;
            min-height: 100vh;
        }

        .page-title {
            font-size: 23px;
            margin-bottom: 3px;
            color: #12233e;
        }

        .page-subtitle {
            font-size: 11px;
            color: #647895;
            margin-bottom: 15px;
        }

        .alert {
            padding: 9px 12px;
            border-radius: 5px;
            margin-bottom: 12px;
            font-size: 10px;
        }

        .alert-success {
            background: #dcfce7;
            border: 1px solid #86efac;
            color: #166534;
        }

        .alert-error {
            background: #fee2e2;
            border: 1px solid #fca5a5;
            color: #991b1b;
        }

        .summary {
            display: flex;
            gap: 12px;
            margin-bottom: 15px;
        }

        .summary-card {
            background: white;
            border: 1px solid #dce5ef;
            border-radius: 6px;
            padding: 12px 15px;
            min-width: 180px;
            box-shadow:
                    0 2px 8px
                    rgba(40, 80, 120, 0.04);
        }

        .summary-label {
            font-size: 9px;
            color: #71849c;
        }

        .summary-value {
            margin-top: 4px;
            font-size: 20px;
            font-weight: 700;
            color: #1c4d82;
        }

        .panel {
            background: white;
            border: 1px solid #dce5ef;
            border-radius: 7px;
            overflow: hidden;
        }

        .panel-header {
            padding: 13px 15px;
            border-bottom: 1px solid #e1e8f0;
            background: #fbfdff;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
        }

        .panel-title {
            font-size: 13px;
            font-weight: 700;
            color: #173252;
        }

        .panel-description {
            margin-top: 3px;
            font-size: 9px;
            color: #778aa2;
        }

        .toolbar {
            padding: 12px 15px;
            border-bottom: 1px solid #e1e8f0;
            display: flex;
            gap: 7px;
        }

        .search-input {
            flex: 1;
            border: 1px solid #c8d5e4;
            border-radius: 4px;
            padding: 8px 10px;
            font-size: 10px;
            outline: none;
        }

        .search-input:focus {
            border-color: #2563eb;
        }

        .btn {
            border: none;
            border-radius: 4px;
            padding: 8px 12px;
            font-size: 9px;
            font-weight: 700;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }

        .btn-primary {
            background: #2563eb;
            color: white;
        }

        .btn-secondary {
            background: #e5e7eb;
            color: #374151;
        }

        .btn-success {
            background: #10b981;
            color: white;
        }

        .btn-danger {
            background: #dc2626;
            color: white;
        }

        .btn:hover {
            opacity: 0.9;
        }

        .table-wrapper {
            padding: 10px 15px 15px;
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 9px;
        }

        th {
            text-align: left;
            padding: 9px 7px;
            background: #f1f5f9;
            color: #526982;
            font-size: 8px;
            text-transform: uppercase;
        }

        td {
            padding: 9px 7px;
            border-bottom: 1px solid #e5ebf2;
            color: #344b65;
            vertical-align: middle;
        }

        tr.unread {
            background: #f6faff;
        }

        tr.unread td {
            font-weight: 600;
        }

        .notification-title {
            color: #173b64;
            font-weight: 700;
        }

        .notification-message {
            margin-top: 3px;
            color: #667b94;
            font-weight: 400;
            line-height: 1.4;
        }

        .badge {
            display: inline-block;
            padding: 4px 7px;
            border-radius: 10px;
            font-size: 7px;
            font-weight: 700;
        }

        .badge-unread {
            background: #dbeafe;
            color: #1d4ed8;
        }

        .badge-read {
            background: #e5e7eb;
            color: #6b7280;
        }

        .badge-today {
            background: #fef3c7;
            color: #92400e;
        }

        .badge-tomorrow {
            background: #dbeafe;
            color: #1e40af;
        }

        .badge-overdue {
            background: #fee2e2;
            color: #991b1b;
        }

        .badge-cancelled {
            background: #f3e8ff;
            color: #6b21a8;
        }

        .badge-rescheduled {
            background: #dcfce7;
            color: #166534;
        }

        .actions {
            display: flex;
            gap: 4px;
            flex-wrap: wrap;
        }

        .empty {
            text-align: center;
            padding: 35px 15px;
            color: #7b8da4;
            font-size: 10px;
        }

        .footer {
            text-align: center;
            margin-top: 20px;
            color: #7d8da2;
            font-size: 9px;
        }

        @media (max-width: 800px) {

            .sidebar {
                width: 90px;
            }

            .main-content {
                margin-left: 90px;
            }

            .summary {
                flex-wrap: wrap;
            }
        }

        @media (max-width: 600px) {

            .panel-header {
                align-items: flex-start;
                flex-direction: column;
            }

            .toolbar {
                flex-direction: column;
            }

            .summary-card {
                width: 100%;
            }
        }

    </style>

</head>

<body>

<header class="top-header">

    <div class="brand">
        Scheduling &amp; Dispatching System
    </div>

    <div class="header-user">

        <span>
            <%= fullName %>
        </span>

        <div class="avatar">
            <%= firstLetter %>
        </div>

    </div>

</header>


<aside class="sidebar">

    <div class="menu-title">
        Main Menu
    </div>

    <a href="<%= contextPath %>/dashboard"
       class="sidebar-link">
        Dashboard
    </a>

    <a href="<%= contextPath %>/user-management"
       class="sidebar-link">
        User Management
    </a>

    <a href="<%= contextPath %>/customer-management"
       class="sidebar-link">
        Customer Management
    </a>

    <a href="<%= contextPath %>/employee-management"
       class="sidebar-link">
        Employee / Resource
    </a>

    <a href="<%= contextPath %>/task-management"
       class="sidebar-link">
        Task Management
    </a>

    <a href="<%= contextPath %>/schedule-management"
       class="sidebar-link">
        Scheduling
    </a>

    <a href="<%= contextPath %>/dispatch-management"
       class="sidebar-link">
        Dispatching
    </a>

    <a href="<%= contextPath %>/reports"
       class="sidebar-link">
        Reports
    </a>

    <a href="<%= contextPath %>/system-configuration"
       class="sidebar-link">
        System Configuration
    </a>

    <div class="account-title">
        Account
    </div>

    <a href="<%= contextPath %>/logout"
       class="sidebar-link">
        Logout
    </a>

</aside>


<main class="main-content">

    <h1 class="page-title">
        Notifications &amp; Reminders
    </h1>

    <p class="page-subtitle">
        View today's schedules, upcoming activities,
        overdue tasks, and schedule updates.
    </p>


    <% if (success != null && !success.trim().isEmpty()) { %>

        <div class="alert alert-success">
            <%= success %>
        </div>

    <% } %>


    <% if (error != null && !error.trim().isEmpty()) { %>

        <div class="alert alert-error">
            <%= error %>
        </div>

    <% } %>


    <div class="summary">

        <div class="summary-card">

            <div class="summary-label">
                Unread Notifications
            </div>

            <div class="summary-value">
                <%= unreadCount %>
            </div>

        </div>

    </div>


    <section class="panel">

        <div class="panel-header">

            <div>

                <div class="panel-title">
                    Notification List
                </div>

                <div class="panel-description">
                    System-generated reminders and alerts.
                </div>

            </div>

            <form method="post"
                  action="<%= contextPath %>/notification-management">

                <input type="hidden"
                       name="action"
                       value="markAllRead">

                <button type="submit"
                        class="btn btn-success">

                    Mark All as Read

                </button>

            </form>

        </div>


        <form method="get"
              action="<%= contextPath %>/notification-management"
              class="toolbar">

            <input type="text"
                   name="keyword"
                   class="search-input"
                   placeholder="Search notifications..."
                   value="<%= keyword == null ? "" : keyword %>">

            <button type="submit"
                    class="btn btn-primary">

                Search

            </button>

            <a href="<%= contextPath %>/notification-management"
               class="btn btn-secondary">

                Clear

            </a>

        </form>


        <div class="table-wrapper">

            <% if (notifications == null
                    || notifications.isEmpty()) { %>

                <div class="empty">
                    No notifications found.
                </div>

            <% } else { %>

                <table>

                    <thead>

                    <tr>

                        <th>
                            ID
                        </th>

                        <th>
                            Type
                        </th>

                        <th>
                            Notification
                        </th>

                        <th>
                            Schedule
                        </th>

                        <th>
                            Created
                        </th>

                        <th>
                            Status
                        </th>

                        <th>
                            Actions
                        </th>

                    </tr>

                    </thead>

                    <tbody>

                    <%
                        for (Notification notification :
                                notifications) {

                            String type =
                                    notification.getNotificationType();

                            String badgeClass =
                                    "badge-unread";

                            if ("TODAY".equalsIgnoreCase(type)) {

                                badgeClass =
                                        "badge-today";

                            } else if (
                                    "TOMORROW".equalsIgnoreCase(type)) {

                                badgeClass =
                                        "badge-tomorrow";

                            } else if (
                                    "OVERDUE".equalsIgnoreCase(type)) {

                                badgeClass =
                                        "badge-overdue";

                            } else if (
                                    "CANCELLED".equalsIgnoreCase(type)) {

                                badgeClass =
                                        "badge-cancelled";

                            } else if (
                                    "RESCHEDULED".equalsIgnoreCase(type)) {

                                badgeClass =
                                        "badge-rescheduled";
                            }
                    %>

                    <tr class="<%= notification.isRead()
                            ? ""
                            : "unread" %>">

                        <td>
                            <%= notification.getId() %>
                        </td>

                        <td>

                            <span class="badge <%= badgeClass %>">

                                <%= type == null
                                        ? "GENERAL"
                                        : type %>

                            </span>

                        </td>

                        <td>

                            <div class="notification-title">

                                <%= notification.getTitle() %>

                            </div>

                            <div class="notification-message">

                                <%= notification.getMessage() %>

                            </div>

                        </td>

                        <td>

                            <%= notification.getScheduleId() == null
                                    ? "-"
                                    : "#" + notification.getScheduleId() %>

                        </td>

                        <td>

                            <%= notification.getCreatedAt() == null
                                    ? "-"
                                    : notification
                                            .getCreatedAt()
                                            .format(formatter) %>

                        </td>

                        <td>

                            <% if (notification.isRead()) { %>

                                <span class="badge badge-read">
                                    READ
                                </span>

                            <% } else { %>

                                <span class="badge badge-unread">
                                    UNREAD
                                </span>

                            <% } %>

                        </td>

                        <td>

                            <div class="actions">

                                <% if (!notification.isRead()) { %>

                                    <form method="post"
                                          action="<%= contextPath %>/notification-management">

                                        <input type="hidden"
                                               name="action"
                                               value="read">

                                        <input type="hidden"
                                               name="id"
                                               value="<%= notification.getId() %>">

                                        <button type="submit"
                                                class="btn btn-primary">

                                            Read

                                        </button>

                                    </form>

                                <% } %>


                                <form method="post"
                                      action="<%= contextPath %>/notification-management"
                                      onsubmit="return confirm('Delete this notification?');">

                                    <input type="hidden"
                                           name="action"
                                           value="delete">

                                    <input type="hidden"
                                           name="id"
                                           value="<%= notification.getId() %>">

                                    <button type="submit"
                                            class="btn btn-danger">

                                        Delete

                                    </button>

                                </form>

                            </div>

                        </td>

                    </tr>

                    <% } %>

                    </tbody>

                </table>

            <% } %>

        </div>

    </section>


    <div class="footer">

        Scheduling and Dispatching System

        &nbsp; | &nbsp;

        Notifications &amp; Reminders

    </div>

</main>

</body>

</html>