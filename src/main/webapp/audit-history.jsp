<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.schedulingdispatch.model.AuditHistory" %>
<%@ page import="com.schedulingdispatch.model.User" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>

<%
    User loggedInUser =
            (User) session.getAttribute("loggedInUser");

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
                403,
                "Access denied."
        );
        return;
    }

    String contextPath =
            request.getContextPath();

    String keyword =
            (String) request.getAttribute(
                    "keyword"
            );

    List<AuditHistory> auditHistoryList =
            (List<AuditHistory>)
                    request.getAttribute(
                            "auditHistoryList"
                    );

    String error =
            (String) request.getAttribute(
                    "error"
            );

    DateTimeFormatter dateTimeFormatter =
            DateTimeFormatter.ofPattern(
                    "dd-MM-yyyy HH:mm:ss"
            );
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Audit History - Scheduling and Dispatching System
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
            color: #14213d;
            min-height: 100vh;
        }

        .top-header {
            height: 58px;

            background: #1c2b3f;

            color: white;

            display: flex;

            align-items: center;

            justify-content: space-between;

            padding: 0 15px;
        }

        .brand {
            font-size: 14px;
            font-weight: 700;
        }

        .admin {
            font-size: 11px;

            display: flex;

            align-items: center;

            gap: 10px;
        }

        .avatar {
            width: 30px;
            height: 30px;

            border-radius: 50%;

            background: #31445e;

            display: flex;

            align-items: center;

            justify-content: center;

            font-weight: 700;
        }

        .layout {
            display: flex;

            min-height:
                    calc(100vh - 58px);
        }

        .sidebar {
            width: 132px;

            flex-shrink: 0;

            background: #101d2e;

            color: white;

            padding: 18px 8px;
        }

        .menu-title {
            color: #8ca0b8;

            font-size: 8px;

            margin-bottom: 12px;

            text-transform: uppercase;
        }

        .sidebar a {
            display: block;

            color: white;

            text-decoration: none;

            font-size: 9px;

            padding: 9px 7px;

            border-radius: 4px;

            margin-bottom: 3px;
        }

        .sidebar a:hover,
        .sidebar a.active {
            background: #34445a;
        }

        .content {
            flex: 1;

            padding: 20px 15px;

            min-width: 0;
        }

        .page-title {
            font-size: 22px;

            margin-bottom: 4px;
        }

        .page-subtitle {
            font-size: 10px;

            color: #64748b;

            margin-bottom: 15px;
        }

        .alert {
            padding: 11px 13px;

            border-radius: 5px;

            margin-bottom: 12px;

            font-size: 11px;
        }

        .alert.error {
            background: #ffe5e5;

            color: #a10000;

            border: 1px solid #ffb6b6;
        }

        .card {
            background: white;

            border: 1px solid #d7e0eb;

            border-radius: 6px;

            overflow: hidden;
        }

        .card-header {
            padding: 13px 14px;

            border-bottom:
                    1px solid #d7e0eb;
        }

        .card-header h2 {
            font-size: 13px;

            margin-bottom: 3px;
        }

        .card-header p {
            font-size: 9px;

            color: #718096;
        }

        .search-bar {
            padding: 12px 14px;

            border-bottom:
                    1px solid #d7e0eb;

            display: flex;

            gap: 7px;
        }

        .search-bar input {
            flex: 1;

            min-width: 0;

            border:
                    1px solid #cbd5e1;

            border-radius: 4px;

            padding: 8px 10px;

            font-size: 10px;

            outline: none;
        }

        .btn {
            border: 0;

            border-radius: 4px;

            padding: 8px 12px;

            font-size: 9px;

            font-weight: 600;

            text-decoration: none;

            cursor: pointer;

            display: inline-block;
        }

        .btn-primary {
            background: #2563eb;
            color: white;
        }

        .btn-clear {
            background: #e5e7eb;
            color: #1f2937;
        }

        .table-wrap {
            overflow-x: auto;

            padding: 10px 14px 14px;
        }

        table {
            width: 100%;

            border-collapse: collapse;

            min-width: 850px;
        }

        th {
            background: #f1f5f9;

            color: #334155;

            font-size: 8px;

            text-align: left;

            padding: 9px 7px;

            white-space: nowrap;
        }

        td {
            border-top:
                    1px solid #e2e8f0;

            padding: 9px 7px;

            font-size: 9px;

            vertical-align: top;
        }

        .badge {
            display: inline-block;

            padding: 4px 7px;

            border-radius: 12px;

            font-size: 7px;

            font-weight: 700;

            background: #e0ecff;

            color: #155eef;
        }

        .status-old {
            color: #64748b;
        }

        .status-new {
            color: #047857;

            font-weight: 700;
        }

        .empty {
            text-align: center;

            padding: 35px 10px;

            color: #94a3b8;

            font-size: 10px;
        }

        .footer {
            text-align: center;

            color: #94a3b8;

            font-size: 8px;

            margin-top: 20px;
        }

        @media (max-width: 700px) {

            .sidebar {
                width: 105px;
            }

            .content {
                padding: 15px 8px;
            }

            .search-bar {
                flex-wrap: wrap;
            }

            .search-bar input {
                flex-basis: 100%;
            }
        }

    </style>

</head>

<body>

<header class="top-header">

    <div class="brand">
        Scheduling &amp; Dispatching System
    </div>

    <div class="admin">

        <span>
            <%= loggedInUser.getFullName() == null
                    ? loggedInUser.getUsername()
                    : loggedInUser.getFullName() %>
        </span>

        <span class="avatar">

            <%
                String username =
                        loggedInUser.getUsername();

                String avatarLetter =
                        username == null
                                || username.isEmpty()
                                ? "A"
                                : username.substring(
                                        0,
                                        1
                                ).toUpperCase();
            %>

            <%= avatarLetter %>

        </span>

    </div>

</header>

<div class="layout">

    <aside class="sidebar">

        <div class="menu-title">
            Main Menu
        </div>

        <a href="<%= contextPath %>/dashboard">
            Dashboard
        </a>

        <a href="<%= contextPath %>/user-management">
            User Management
        </a>

        <a href="<%= contextPath %>/customer-management">
            Customer Management
        </a>

        <a href="<%= contextPath %>/employee-management">
            Employee / Resource
        </a>

        <a href="<%= contextPath %>/task-management">
            Task Management
        </a>

        <a href="<%= contextPath %>/schedule-management">
            Scheduling
        </a>

        <a href="<%= contextPath %>/dispatch-management">
            Dispatching
        </a>

        <a href="<%= contextPath %>/reports">
            Reports
        </a>

        <a href="<%= contextPath %>/system-configuration">
            System Configuration
        </a>

        <a href="<%= contextPath %>/audit-history"
           class="active">
            Audit History
        </a>

        <div class="menu-title"
             style="margin-top:18px;">
            Account
        </div>

        <a href="<%= contextPath %>/logout">
            Logout
        </a>

    </aside>

    <main class="content">

        <h1 class="page-title">
            Audit History
        </h1>

        <p class="page-subtitle">
            View schedule activity, status changes,
            and system audit records.
        </p>

        <% if (error != null) { %>

            <div class="alert error">
                <%= error %>
            </div>

        <% } %>

        <section class="card">

            <div class="card-header">

                <h2>
                    Audit Records
                </h2>

                <p>
                    System-generated history
                    for schedule operations.
                </p>

            </div>

            <form class="search-bar"
                  method="get"
                  action="<%= contextPath %>/audit-history">

                <input type="text"
                       name="keyword"
                       value="<%= keyword == null
                               ? ""
                               : keyword %>"
                       placeholder="Search by schedule, user, action, status, or description">

                <button type="submit"
                        class="btn btn-primary">
                    Search
                </button>

                <a href="<%= contextPath %>/audit-history"
                   class="btn btn-clear">
                    Clear
                </a>

            </form>

            <div class="table-wrap">

                <% if (auditHistoryList == null
                        || auditHistoryList.isEmpty()) { %>

                    <div class="empty">
                        No audit records found.
                    </div>

                <% } else { %>

                    <table>

                        <thead>

                        <tr>
                            <th>ID</th>
                            <th>SCHEDULE</th>
                            <th>USER</th>
                            <th>ACTION</th>
                            <th>OLD STATUS</th>
                            <th>NEW STATUS</th>
                            <th>DESCRIPTION</th>
                            <th>CREATED</th>
                        </tr>

                        </thead>

                        <tbody>

                        <% for (AuditHistory audit
                                : auditHistoryList) { %>

                            <tr>

                                <td>
                                    <%= audit.getId() %>
                                </td>

                                <td>
                                    <%= audit.getScheduleId() == null
                                            ? "-"
                                            : "#"
                                            + audit.getScheduleId() %>
                                </td>

                                <td>
                                    <%= audit.getUserId() == null
                                            ? "-"
                                            : audit.getUserId() %>
                                </td>

                                <td>

                                    <span class="badge">
                                        <%= audit.getAction() %>
                                    </span>

                                </td>

                                <td class="status-old">
                                    <%= audit.getOldStatus() == null
                                            ? "-"
                                            : audit.getOldStatus() %>
                                </td>

                                <td class="status-new">
                                    <%= audit.getNewStatus() == null
                                            ? "-"
                                            : audit.getNewStatus() %>
                                </td>

                                <td>
                                    <%= audit.getDescription() == null
                                            ? "-"
                                            : audit.getDescription() %>
                                </td>

                                <td>
                                    <%= audit.getCreatedAt() == null
                                            ? "-"
                                            : audit.getCreatedAt()
                                            .format(
                                                    dateTimeFormatter
                                            ) %>
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
            &nbsp;|&nbsp;
            Audit History
        </div>

    </main>

</div>

</body>

</html>