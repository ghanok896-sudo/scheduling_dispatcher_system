<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.schedulingdispatch.model.User" %>

<%@ page import="java.util.List" %>

<%
    User user =
            (User) request.getAttribute("user");

    if (user == null) {

        response.sendRedirect(
                request.getContextPath() + "/login"
        );

        return;
    }

    String contextPath =
            request.getContextPath();

    String fullName =
            user.getFullName() == null
                    ? user.getUsername()
                    : user.getFullName();

    String role =
            user.getRole() == null
                    ? ""
                    : user.getRole();

    String firstLetter =
            fullName == null || fullName.isEmpty()
                    ? "A"
                    : fullName.substring(0, 1).toUpperCase();

    Long totalUsers =
            (Long) request.getAttribute("totalUsers");

    Long activeUsers =
            (Long) request.getAttribute("activeUsers");

    Long totalCustomers =
            (Long) request.getAttribute("totalCustomers");

    Long activeCustomers =
            (Long) request.getAttribute("activeCustomers");

    Long totalEmployees =
            (Long) request.getAttribute("totalEmployees");

    Long availableEmployees =
            (Long) request.getAttribute("availableEmployees");

    Long totalTasks =
            (Long) request.getAttribute("totalTasks");

    Long pendingTasks =
            (Long) request.getAttribute("pendingTasks");

    Long inProgressTasks =
            (Long) request.getAttribute("inProgressTasks");

    Long completedTasks =
            (Long) request.getAttribute("completedTasks");

    Long cancelledTasks =
            (Long) request.getAttribute("cancelledTasks");

    Long totalSchedules =
            (Long) request.getAttribute("totalSchedules");

    Long scheduledSchedules =
            (Long) request.getAttribute("scheduledSchedules");

    Long activeSchedules =
            (Long) request.getAttribute("activeSchedules");

    Long completedSchedules =
            (Long) request.getAttribute("completedSchedules");

    Long cancelledSchedules =
            (Long) request.getAttribute("cancelledSchedules");

    Long totalDispatches =
            (Long) request.getAttribute("totalDispatches");

    Long assignedDispatches =
            (Long) request.getAttribute("assignedDispatches");

    Long dispatchedDispatches =
            (Long) request.getAttribute("dispatchedDispatches");

    Long startedDispatches =
            (Long) request.getAttribute("startedDispatches");

    Long completedDispatches =
            (Long) request.getAttribute("completedDispatches");

    Long cancelledDispatches =
            (Long) request.getAttribute("cancelledDispatches");

    if (totalUsers == null) totalUsers = 0L;
    if (activeUsers == null) activeUsers = 0L;

    if (totalCustomers == null) totalCustomers = 0L;
    if (activeCustomers == null) activeCustomers = 0L;

    if (totalEmployees == null) totalEmployees = 0L;
    if (availableEmployees == null) availableEmployees = 0L;

    if (totalTasks == null) totalTasks = 0L;
    if (pendingTasks == null) pendingTasks = 0L;
    if (inProgressTasks == null) inProgressTasks = 0L;
    if (completedTasks == null) completedTasks = 0L;
    if (cancelledTasks == null) cancelledTasks = 0L;

    if (totalSchedules == null) totalSchedules = 0L;
    if (scheduledSchedules == null) scheduledSchedules = 0L;
    if (activeSchedules == null) activeSchedules = 0L;
    if (completedSchedules == null) completedSchedules = 0L;
    if (cancelledSchedules == null) cancelledSchedules = 0L;

    if (totalDispatches == null) totalDispatches = 0L;
    if (assignedDispatches == null) assignedDispatches = 0L;
    if (dispatchedDispatches == null) dispatchedDispatches = 0L;
    if (startedDispatches == null) startedDispatches = 0L;
    if (completedDispatches == null) completedDispatches = 0L;
    if (cancelledDispatches == null) cancelledDispatches = 0L;

    List<Object[]> taskPrioritySummary =
            (List<Object[]>) request.getAttribute(
                    "taskPrioritySummary"
            );

    List<Object[]> taskStatusSummary =
            (List<Object[]>) request.getAttribute(
                    "taskStatusSummary"
            );

    List<Object[]> dispatchStatusSummary =
            (List<Object[]>) request.getAttribute(
                    "dispatchStatusSummary"
            );

    List<Object[]> scheduleStatusSummary =
            (List<Object[]>) request.getAttribute(
                    "scheduleStatusSummary"
            );

    String error =
            (String) request.getAttribute("error");
%>

<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Reports - Scheduling and Dispatching System
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

            padding: 0 18px;

            z-index: 1000;
        }

        .brand {
            font-size: 16px;

            font-weight: 700;
        }

        .header-user {
            display: flex;

            align-items: center;

            gap: 10px;

            font-size: 12px;
        }

        .header-avatar {
            width: 34px;
            height: 34px;

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

            padding: 92px 15px 35px;

            min-height: 100vh;
        }

        .page-title {
            font-size: 23px;

            color: #12233e;

            margin-bottom: 3px;
        }

        .page-subtitle {
            color: #647895;

            font-size: 11px;

            margin-bottom: 15px;
        }

        .alert {
            padding: 11px 14px;

            border-radius: 5px;

            margin-bottom: 15px;

            font-size: 12px;
        }

        .alert-error {
            background: #ffe7e7;

            border: 1px solid #f2a5a5;

            color: #a40000;
        }

        .summary-grid {
            display: grid;

            grid-template-columns:
                repeat(6, minmax(130px, 1fr));

            gap: 10px;

            margin-bottom: 18px;
        }

        .summary-card {
            background: white;

            border: 1px solid #dce5ef;

            border-radius: 7px;

            padding: 13px;

            box-shadow:
                0 3px 10px rgba(40, 80, 120, 0.05);
        }

        .summary-label {
            color: #71839b;

            font-size: 10px;

            margin-bottom: 8px;
        }

        .summary-number {
            color: #12233e;

            font-size: 25px;

            font-weight: 700;
        }

        .summary-detail {
            color: #7889a0;

            font-size: 9px;

            margin-top: 4px;
        }

        .report-grid {
            display: grid;

            grid-template-columns:
                repeat(2, minmax(300px, 1fr));

            gap: 15px;

            margin-bottom: 15px;
        }

        .report-card {
            background: white;

            border: 1px solid #dce5ef;

            border-radius: 7px;

            overflow: hidden;

            box-shadow:
                0 3px 10px rgba(40, 80, 120, 0.05);
        }

        .report-header {
            padding: 12px 14px;

            border-bottom: 1px solid #e3eaf2;

            background: #fbfdff;
        }

        .report-title {
            font-size: 13px;

            color: #173252;

            font-weight: 700;
        }

        .report-description {
            font-size: 9px;

            color: #778aa2;

            margin-top: 3px;
        }

        .report-body {
            padding: 10px 14px 14px;
        }

        table {
            width: 100%;

            border-collapse: collapse;
        }

        th {
            text-align: left;

            font-size: 9px;

            color: #536983;

            background: #f5f8fb;

            padding: 8px 7px;

            border-bottom: 1px solid #dce5ef;
        }

        td {
            font-size: 10px;

            color: #314762;

            padding: 8px 7px;

            border-bottom: 1px solid #edf1f5;
        }

        tr:last-child td {
            border-bottom: none;
        }

        .status {
            display: inline-block;

            padding: 3px 7px;

            border-radius: 10px;

            font-size: 8px;

            font-weight: 700;
        }

        .status-green {
            background: #dff8e9;

            color: #08773c;
        }

        .status-blue {
            background: #e2efff;

            color: #1262bb;
        }

        .status-orange {
            background: #fff0d7;

            color: #b96600;
        }

        .status-red {
            background: #ffe1e1;

            color: #b00000;
        }

        .status-gray {
            background: #edf0f3;

            color: #5d6977;
        }

        .full-width {
            grid-column: 1 / -1;
        }

        .footer {
            text-align: center;

            color: #7d8da2;

            font-size: 9px;

            margin-top: 22px;
        }

        @media (max-width: 1200px) {

            .summary-grid {
                grid-template-columns:
                    repeat(3, 1fr);
            }

        }

        @media (max-width: 800px) {

            .sidebar {
                width: 90px;
            }

            .main-content {
                margin-left: 90px;
            }

            .summary-grid {
                grid-template-columns:
                    repeat(2, 1fr);
            }

            .report-grid {
                grid-template-columns: 1fr;
            }

        }

        @media (max-width: 550px) {

            .summary-grid {
                grid-template-columns: 1fr;
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

        <div class="header-avatar">
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
       class="sidebar-link active">
        Reports
    </a>

    <a href="#"
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
        Reports
    </h1>

    <p class="page-subtitle">
        View system statistics and operational reports.
    </p>

    <%
        if (error != null && !error.trim().isEmpty()) {
    %>

        <div class="alert alert-error">
            <%= error %>
        </div>

    <%
        }
    %>

    <section class="summary-grid">

        <div class="summary-card">

            <div class="summary-label">
                Total Users
            </div>

            <div class="summary-number">
                <%= totalUsers %>
            </div>

            <div class="summary-detail">
                <%= activeUsers %> active users
            </div>

        </div>

        <div class="summary-card">

            <div class="summary-label">
                Total Customers
            </div>

            <div class="summary-number">
                <%= totalCustomers %>
            </div>

            <div class="summary-detail">
                <%= activeCustomers %> active customers
            </div>

        </div>

        <div class="summary-card">

            <div class="summary-label">
                Total Employees
            </div>

            <div class="summary-number">
                <%= totalEmployees %>
            </div>

            <div class="summary-detail">
                <%= availableEmployees %> available
            </div>

        </div>

        <div class="summary-card">

            <div class="summary-label">
                Total Tasks
            </div>

            <div class="summary-number">
                <%= totalTasks %>
            </div>

            <div class="summary-detail">
                <%= pendingTasks %> pending
            </div>

        </div>

        <div class="summary-card">

            <div class="summary-label">
                Total Schedules
            </div>

            <div class="summary-number">
                <%= totalSchedules %>
            </div>

            <div class="summary-detail">
                <%= scheduledSchedules %> scheduled
            </div>

        </div>

        <div class="summary-card">

            <div class="summary-label">
                Total Dispatches
            </div>

            <div class="summary-number">
                <%= totalDispatches %>
            </div>

            <div class="summary-detail">
                <%= completedDispatches %> completed
            </div>

        </div>

    </section>

    <section class="report-grid">

        <div class="report-card">

            <div class="report-header">

                <div class="report-title">
                    Task Status Report
                </div>

                <div class="report-description">
                    Current task distribution by status.
                </div>

            </div>

            <div class="report-body">

                <table>

                    <thead>

                    <tr>

                        <th>
                            Status
                        </th>

                        <th>
                            Total
                        </th>

                    </tr>

                    </thead>

                    <tbody>

                    <%
                        if (taskStatusSummary != null
                                && !taskStatusSummary.isEmpty()) {

                            for (Object[] row :
                                    taskStatusSummary) {

                                String status =
                                        row[0] == null
                                                ? "UNKNOWN"
                                                : row[0].toString();

                                String total =
                                        row[1] == null
                                                ? "0"
                                                : row[1].toString();

                                String cssClass =
                                        "status-gray";

                                if ("COMPLETED".equalsIgnoreCase(status)) {
                                    cssClass = "status-green";
                                } else if ("IN_PROGRESS".equalsIgnoreCase(status)) {
                                    cssClass = "status-blue";
                                } else if ("PENDING".equalsIgnoreCase(status)) {
                                    cssClass = "status-orange";
                                } else if ("CANCELLED".equalsIgnoreCase(status)) {
                                    cssClass = "status-red";
                                }
                    %>

                    <tr>

                        <td>

                            <span class="status <%= cssClass %>">
                                <%= status.replace("_", " ") %>
                            </span>

                        </td>

                        <td>
                            <%= total %>
                        </td>

                    </tr>

                    <%
                            }

                        } else {
                    %>

                    <tr>

                        <td colspan="2">
                            No task status data available.
                        </td>

                    </tr>

                    <%
                        }
                    %>

                    </tbody>

                </table>

            </div>

        </div>

        <div class="report-card">

            <div class="report-header">

                <div class="report-title">
                    Task Priority Report
                </div>

                <div class="report-description">
                    Tasks grouped by priority level.
                </div>

            </div>

            <div class="report-body">

                <table>

                    <thead>

                    <tr>

                        <th>
                            Priority
                        </th>

                        <th>
                            Total
                        </th>

                    </tr>

                    </thead>

                    <tbody>

                    <%
                        if (taskPrioritySummary != null
                                && !taskPrioritySummary.isEmpty()) {

                            for (Object[] row :
                                    taskPrioritySummary) {

                                String priority =
                                        row[0] == null
                                                ? "UNKNOWN"
                                                : row[0].toString();

                                String total =
                                        row[1] == null
                                                ? "0"
                                                : row[1].toString();

                                String cssClass =
                                        "status-gray";

                                if ("URGENT".equalsIgnoreCase(priority)) {
                                    cssClass = "status-red";
                                } else if ("HIGH".equalsIgnoreCase(priority)) {
                                    cssClass = "status-orange";
                                } else if ("MEDIUM".equalsIgnoreCase(priority)) {
                                    cssClass = "status-blue";
                                } else if ("LOW".equalsIgnoreCase(priority)) {
                                    cssClass = "status-green";
                                }
                    %>

                    <tr>

                        <td>

                            <span class="status <%= cssClass %>">
                                <%= priority %>
                            </span>

                        </td>

                        <td>
                            <%= total %>
                        </td>

                    </tr>

                    <%
                            }

                        } else {
                    %>

                    <tr>

                        <td colspan="2">
                            No task priority data available.
                        </td>

                    </tr>

                    <%
                        }
                    %>

                    </tbody>

                </table>

            </div>

        </div>

        <div class="report-card">

            <div class="report-header">

                <div class="report-title">
                    Schedule Status Report
                </div>

                <div class="report-description">
                    Current schedule distribution.
                </div>

            </div>

            <div class="report-body">

                <table>

                    <thead>

                    <tr>

                        <th>
                            Status
                        </th>

                        <th>
                            Total
                        </th>

                    </tr>

                    </thead>

                    <tbody>

                    <%
                        if (scheduleStatusSummary != null
                                && !scheduleStatusSummary.isEmpty()) {

                            for (Object[] row :
                                    scheduleStatusSummary) {

                                String status =
                                        row[0] == null
                                                ? "UNKNOWN"
                                                : row[0].toString();

                                String total =
                                        row[1] == null
                                                ? "0"
                                                : row[1].toString();

                                String cssClass =
                                        "status-gray";

                                if ("COMPLETED".equalsIgnoreCase(status)) {
                                    cssClass = "status-green";
                                } else if ("IN_PROGRESS".equalsIgnoreCase(status)) {
                                    cssClass = "status-blue";
                                } else if ("SCHEDULED".equalsIgnoreCase(status)) {
                                    cssClass = "status-orange";
                                } else if ("CANCELLED".equalsIgnoreCase(status)) {
                                    cssClass = "status-red";
                                }
                    %>

                    <tr>

                        <td>

                            <span class="status <%= cssClass %>">
                                <%= status.replace("_", " ") %>
                            </span>

                        </td>

                        <td>
                            <%= total %>
                        </td>

                    </tr>

                    <%
                            }

                        } else {
                    %>

                    <tr>

                        <td colspan="2">
                            No schedule status data available.
                        </td>

                    </tr>

                    <%
                        }
                    %>

                    </tbody>

                </table>

            </div>

        </div>

        <div class="report-card">

            <div class="report-header">

                <div class="report-title">
                    Dispatch Status Report
                </div>

                <div class="report-description">
                    Current dispatch distribution.
                </div>

            </div>

            <div class="report-body">

                <table>

                    <thead>

                    <tr>

                        <th>
                            Status
                        </th>

                        <th>
                            Total
                        </th>

                    </tr>

                    </thead>

                    <tbody>

                    <%
                        if (dispatchStatusSummary != null
                                && !dispatchStatusSummary.isEmpty()) {

                            for (Object[] row :
                                    dispatchStatusSummary) {

                                String status =
                                        row[0] == null
                                                ? "UNKNOWN"
                                                : row[0].toString();

                                String total =
                                        row[1] == null
                                                ? "0"
                                                : row[1].toString();

                                String cssClass =
                                        "status-gray";

                                if ("COMPLETED".equalsIgnoreCase(status)) {
                                    cssClass = "status-green";
                                } else if ("STARTED".equalsIgnoreCase(status)) {
                                    cssClass = "status-blue";
                                } else if ("DISPATCHED".equalsIgnoreCase(status)) {
                                    cssClass = "status-orange";
                                } else if ("CANCELLED".equalsIgnoreCase(status)) {
                                    cssClass = "status-red";
                                } else if ("ASSIGNED".equalsIgnoreCase(status)) {
                                    cssClass = "status-blue";
                                }
                    %>

                    <tr>

                        <td>

                            <span class="status <%= cssClass %>">
                                <%= status.replace("_", " ") %>
                            </span>

                        </td>

                        <td>
                            <%= total %>
                        </td>

                    </tr>

                    <%
                            }

                        } else {
                    %>

                    <tr>

                        <td colspan="2">
                            No dispatch status data available.
                        </td>

                    </tr>

                    <%
                        }
                    %>

                    </tbody>

                </table>

            </div>

        </div>

        <div class="report-card full-width">

            <div class="report-header">

                <div class="report-title">
                    Operational Summary
                </div>

                <div class="report-description">
                    Overall status of tasks, schedules and dispatches.
                </div>

            </div>

            <div class="report-body">

                <table>

                    <thead>

                    <tr>

                        <th>
                            Module
                        </th>

                        <th>
                            Total
                        </th>

                        <th>
                            Active / Pending
                        </th>

                        <th>
                            In Progress
                        </th>

                        <th>
                            Completed
                        </th>

                        <th>
                            Cancelled
                        </th>

                    </tr>

                    </thead>

                    <tbody>

                    <tr>

                        <td>
                            Tasks
                        </td>

                        <td>
                            <%= totalTasks %>
                        </td>

                        <td>
                            <%= pendingTasks %>
                        </td>

                        <td>
                            <%= inProgressTasks %>
                        </td>

                        <td>
                            <%= completedTasks %>
                        </td>

                        <td>
                            <%= cancelledTasks %>
                        </td>

                    </tr>

                    <tr>

                        <td>
                            Schedules
                        </td>

                        <td>
                            <%= totalSchedules %>
                        </td>

                        <td>
                            <%= scheduledSchedules %>
                        </td>

                        <td>
                            <%= activeSchedules %>
                        </td>

                        <td>
                            <%= completedSchedules %>
                        </td>

                        <td>
                            <%= cancelledSchedules %>
                        </td>

                    </tr>

                    <tr>

                        <td>
                            Dispatches
                        </td>

                        <td>
                            <%= totalDispatches %>
                        </td>

                        <td>
                            <%= assignedDispatches %>
                        </td>

                        <td>
                            <%= startedDispatches %>
                        </td>

                        <td>
                            <%= completedDispatches %>
                        </td>

                        <td>
                            <%= cancelledDispatches %>
                        </td>

                    </tr>

                    </tbody>

                </table>

            </div>

        </div>

    </section>

    <div class="footer">

        Scheduling and Dispatching System
        &nbsp; | &nbsp;
        Reports

    </div>

</main>

</body>

</html>