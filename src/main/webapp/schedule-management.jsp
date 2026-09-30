<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List"%>
<%@ page import="com.schedulingdispatch.model.Schedule"%>
<%@ page import="com.schedulingdispatch.model.Customer"%>
<%@ page import="com.schedulingdispatch.model.Employee"%>
<%@ page import="com.schedulingdispatch.model.User"%>
<%@ page import="java.time.format.DateTimeFormatter"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");

    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    if (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
        response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Access denied."
        );
        return;
    }

    String contextPath = request.getContextPath();

    List<Schedule> schedules =
            (List<Schedule>) request.getAttribute("schedules");

    List<Customer> customers =
            (List<Customer>) request.getAttribute("customers");

    List<Employee> employees =
            (List<Employee>) request.getAttribute("employees");

    Schedule editSchedule =
            (Schedule) request.getAttribute("editSchedule");

    String keyword =
            (String) request.getAttribute("keyword");

    String error =
            (String) request.getAttribute("error");

    String success =
            request.getParameter("success");

    if (schedules == null) {
        schedules = java.util.Collections.emptyList();
    }

    if (customers == null) {
        customers = java.util.Collections.emptyList();
    }

    if (employees == null) {
        employees = java.util.Collections.emptyList();
    }

    DateTimeFormatter displayFormatter =
            DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm");

    String formTitle =
            editSchedule == null
                    ? "Create New Schedule"
                    : "Edit Schedule";

    String submitAction =
            editSchedule == null
                    ? "create"
                    : "update";
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Schedule Management</title>

    <style>

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, Helvetica, sans-serif;
            background: #f4f6f9;
            color: #1f2937;
        }

        .top-header {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            height: 64px;
            background: #1f2937;
            color: white;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 24px;
            z-index: 1000;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
        }

        .brand {
            font-size: 20px;
            font-weight: bold;
        }

        .user-area {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 14px;
        }

        .user-badge {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: #374151;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
        }

        .sidebar {
            position: fixed;
            top: 64px;
            left: 0;
            bottom: 0;
            width: 235px;
            background: #111827;
            padding: 20px 12px;
            overflow-y: auto;
        }

        .sidebar-title {
            color: #9ca3af;
            font-size: 12px;
            text-transform: uppercase;
            padding: 10px 12px;
            letter-spacing: 0.6px;
        }

        .sidebar a {
            display: block;
            text-decoration: none;
            color: #d1d5db;
            padding: 12px 14px;
            border-radius: 7px;
            margin-bottom: 4px;
            font-size: 14px;
        }

        .sidebar a:hover,
        .sidebar a.active {
            background: #374151;
            color: white;
        }

        .main-content {
            margin-left: 235px;
            padding: 92px 28px 40px;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            margin-bottom: 24px;
        }

        .page-header h1 {
            margin: 0;
            font-size: 28px;
        }

        .page-header p {
            margin: 6px 0 0;
            color: #6b7280;
            font-size: 14px;
        }

        .card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.06);
            margin-bottom: 24px;
        }

        .card-header {
            padding: 18px 20px;
            border-bottom: 1px solid #e5e7eb;
        }

        .card-header h2 {
            margin: 0;
            font-size: 18px;
        }

        .card-body {
            padding: 20px;
        }

        .message {
            padding: 12px 15px;
            border-radius: 7px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        .success {
            background: #ecfdf5;
            color: #065f46;
            border: 1px solid #a7f3d0;
        }

        .error {
            background: #fef2f2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }

        .form-grid {
            display: grid;
            grid-template-columns:
                repeat(3, minmax(0, 1fr));
            gap: 18px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group.full {
            grid-column: 1 / -1;
        }

        label {
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 7px;
            color: #374151;
        }

        input,
        select,
        textarea {
            width: 100%;
            border: 1px solid #d1d5db;
            border-radius: 6px;
            padding: 10px 11px;
            font-size: 14px;
            background: white;
            color: #111827;
        }

        input:focus,
        select:focus,
        textarea:focus {
            outline: none;
            border-color: #6b7280;
        }

        textarea {
            resize: vertical;
            min-height: 90px;
        }

        .form-actions {
            margin-top: 20px;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .btn {
            border: none;
            border-radius: 6px;
            padding: 10px 16px;
            cursor: pointer;
            font-size: 14px;
            text-decoration: none;
            display: inline-block;
        }

        .btn-primary {
            background: #2563eb;
            color: white;
        }

        .btn-primary:hover {
            background: #1d4ed8;
        }

        .btn-secondary {
            background: #6b7280;
            color: white;
        }

        .btn-secondary:hover {
            background: #4b5563;
        }

        .btn-danger {
            background: #dc2626;
            color: white;
        }

        .btn-danger:hover {
            background: #b91c1c;
        }

        .btn-warning {
            background: #d97706;
            color: white;
        }

        .btn-warning:hover {
            background: #b45309;
        }

        .btn-success {
            background: #059669;
            color: white;
        }

        .btn-success:hover {
            background: #047857;
        }

        .search-row {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .search-row input {
            flex: 1;
        }

        .table-container {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 1250px;
        }

        th,
        td {
            padding: 12px 10px;
            border-bottom: 1px solid #e5e7eb;
            text-align: left;
            font-size: 13px;
            vertical-align: middle;
        }

        th {
            background: #f9fafb;
            color: #374151;
            font-weight: 600;
            white-space: nowrap;
        }

        td {
            color: #4b5563;
        }

        tr:hover td {
            background: #fafafa;
        }

        .badge {
            display: inline-block;
            padding: 5px 9px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 600;
        }

        .badge-scheduled {
            background: #dbeafe;
            color: #1e40af;
        }

        .badge-progress {
            background: #fef3c7;
            color: #92400e;
        }

        .badge-completed {
            background: #d1fae5;
            color: #065f46;
        }

        .badge-cancelled {
            background: #fee2e2;
            color: #991b1b;
        }

        .badge-low {
            background: #f3f4f6;
            color: #374151;
        }

        .badge-medium {
            background: #dbeafe;
            color: #1e40af;
        }

        .badge-high {
            background: #ffedd5;
            color: #9a3412;
        }

        .badge-urgent {
            background: #fee2e2;
            color: #991b1b;
        }

        .action-group {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
        }

        .small-btn {
            padding: 6px 9px;
            font-size: 12px;
        }

        .empty-state {
            text-align: center;
            padding: 35px 15px;
            color: #6b7280;
        }

        .info-text {
            color: #6b7280;
            font-size: 12px;
            margin-top: 5px;
        }

        @media (max-width: 1100px) {

            .form-grid {
                grid-template-columns:
                    repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 768px) {

            .top-header {
                padding: 0 14px;
            }

            .brand {
                font-size: 16px;
            }

            .sidebar {
                width: 190px;
            }

            .main-content {
                margin-left: 190px;
                padding: 88px 16px 30px;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }

            .page-header {
                flex-direction: column;
                align-items: flex-start;
            }
        }

        @media (max-width: 600px) {

            .sidebar {
                position: static;
                width: 100%;
                margin-top: 64px;
                height: auto;
            }

            .top-header {
                position: absolute;
            }

            .main-content {
                margin-left: 0;
                padding: 25px 14px;
            }

            .search-row {
                flex-direction: column;
                align-items: stretch;
            }
        }

    </style>

</head>

<body>

<header class="top-header">

    <div class="brand">
        Scheduling & Dispatching System
    </div>

    <div class="user-area">

        <span>
            <%= loggedInUser.getFullName() != null
                    ? loggedInUser.getFullName()
                    : loggedInUser.getUsername() %>
        </span>

        <div class="user-badge">
            <%= loggedInUser.getUsername()
                    .substring(0, 1)
                    .toUpperCase() %>
        </div>

    </div>

</header>


<aside class="sidebar">

    <div class="sidebar-title">
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
        Employee / Resource Management
    </a>

    <a href="<%= contextPath %>/schedule-management"
       class="active">
        Scheduling
    </a>

    <a href="#">
        Dispatching
    </a>

    <a href="#">
        Reports
    </a>

    <a href="#">
        System Configuration
    </a>

    <div class="sidebar-title">
        Account
    </div>

    <a href="<%= contextPath %>/logout">
        Logout
    </a>

</aside>


<main class="main-content">

    <div class="page-header">

        <div>

            <h1>Schedule Management</h1>

            <p>
                Create, update and manage customer task schedules.
            </p>

        </div>

    </div>


    <% if (success != null && !success.trim().isEmpty()) { %>

        <div class="message success">
            <%= success %>
        </div>

    <% } %>


    <% if (error != null && !error.trim().isEmpty()) { %>

        <div class="message error">
            <%= error %>
        </div>

    <% } %>


    <!-- CREATE / EDIT FORM -->

    <div class="card">

        <div class="card-header">

            <h2>
                <%= formTitle %>
            </h2>

        </div>

        <div class="card-body">

            <form method="post"
                  action="<%= contextPath %>/schedule-management">

                <input type="hidden"
                       name="action"
                       value="<%= submitAction %>">

                <% if (editSchedule != null) { %>

                    <input type="hidden"
                           name="id"
                           value="<%= editSchedule.getId() %>">

                <% } %>


                <div class="form-grid">


                    <!-- TASK -->

                    <div class="form-group">

                        <label for="taskId">
                            Task *
                        </label>

                        <input type="number"
                               id="taskId"
                               name="taskId"
                               min="1"
                               required
                               value="<%= editSchedule != null
                                       ? editSchedule.getTaskId()
                                       : "" %>">

                        <div class="info-text">
                            Enter the existing Task ID.
                        </div>

                    </div>


                    <!-- CUSTOMER -->

                    <div class="form-group">

                        <label for="customerId">
                            Customer *
                        </label>

                        <select id="customerId"
                                name="customerId"
                                required>

                            <option value="">
                                -- Select Customer --
                            </option>

                            <% for (Customer customer : customers) {

                                boolean selected =
                                        editSchedule != null
                                        && editSchedule.getCustomerId()
                                                != null
                                        && editSchedule.getCustomerId()
                                                .equals(customer.getId());
                            %>

                                <option value="<%= customer.getId() %>"
                                    <%= selected ? "selected" : "" %>>

                                    <%= customer.getName() %>

                                    <% if (customer.getPhone() != null) { %>
                                        - <%= customer.getPhone() %>
                                    <% } %>

                                </option>

                            <% } %>

                        </select>

                    </div>


                    <!-- EMPLOYEE -->

                    <div class="form-group">

                        <label for="employeeId">
                            Employee / Resource
                        </label>

                        <select id="employeeId"
                                name="employeeId">

                            <option value="">
                                -- No Employee Assigned --
                            </option>

                            <% for (Employee employee : employees) {

                                boolean selected =
                                        editSchedule != null
                                        && editSchedule.getEmployeeId()
                                                != null
                                        && editSchedule.getEmployeeId()
                                                .equals(employee.getId());
                            %>

                                <option value="<%= employee.getId() %>"
                                    <%= selected ? "selected" : "" %>>

                                    <%= employee.getEmployeeCode() %>
                                    -
                                    <%= employee.getName() %>

                                </option>

                            <% } %>

                        </select>

                        <div class="info-text">
                            Only active and available employees are shown.
                        </div>

                    </div>


                    <!-- START -->

                    <div class="form-group">

                        <label for="scheduledStart">
                            Scheduled Start *
                        </label>

                        <input type="datetime-local"
                               id="scheduledStart"
                               name="scheduledStart"
                               required

                               <% if (editSchedule != null
                                       && editSchedule.getScheduledStart()
                                                != null) { %>

                                   value="<%= editSchedule
                                           .getScheduledStart()
                                           .format(
                                               DateTimeFormatter.ofPattern(
                                                   "yyyy-MM-dd'T'HH:mm"
                                               )
                                           ) %>"

                               <% } %>
                        >

                    </div>


                    <!-- END -->

                    <div class="form-group">

                        <label for="scheduledEnd">
                            Scheduled End *
                        </label>

                        <input type="datetime-local"
                               id="scheduledEnd"
                               name="scheduledEnd"
                               required

                               <% if (editSchedule != null
                                       && editSchedule.getScheduledEnd()
                                                != null) { %>

                                   value="<%= editSchedule
                                           .getScheduledEnd()
                                           .format(
                                               DateTimeFormatter.ofPattern(
                                                   "yyyy-MM-dd'T'HH:mm"
                                               )
                                           ) %>"

                               <% } %>
                        >

                    </div>


                    <!-- PRIORITY -->

                    <div class="form-group">

                        <label for="priority">
                            Priority
                        </label>

                        <select id="priority"
                                name="priority">

                            <option value="LOW"
                                <%= editSchedule != null
                                        && "LOW".equalsIgnoreCase(
                                                editSchedule.getPriority())
                                        ? "selected"
                                        : "" %>>
                                LOW
                            </option>

                            <option value="MEDIUM"
                                <%= editSchedule == null
                                        || "MEDIUM".equalsIgnoreCase(
                                                editSchedule.getPriority())
                                        ? "selected"
                                        : "" %>>
                                MEDIUM
                            </option>

                            <option value="HIGH"
                                <%= editSchedule != null
                                        && "HIGH".equalsIgnoreCase(
                                                editSchedule.getPriority())
                                        ? "selected"
                                        : "" %>>
                                HIGH
                            </option>

                            <option value="URGENT"
                                <%= editSchedule != null
                                        && "URGENT".equalsIgnoreCase(
                                                editSchedule.getPriority())
                                        ? "selected"
                                        : "" %>>
                                URGENT
                            </option>

                        </select>

                    </div>


                    <!-- STATUS -->

                    <div class="form-group">

                        <label for="status">
                            Status
                        </label>

                        <select id="status"
                                name="status">

                            <option value="SCHEDULED"
                                <%= editSchedule == null
                                        || "SCHEDULED".equalsIgnoreCase(
                                                editSchedule.getStatus())
                                        ? "selected"
                                        : "" %>>
                                SCHEDULED
                            </option>

                            <option value="IN_PROGRESS"
                                <%= editSchedule != null
                                        && "IN_PROGRESS".equalsIgnoreCase(
                                                editSchedule.getStatus())
                                        ? "selected"
                                        : "" %>>
                                IN PROGRESS
                            </option>

                            <option value="COMPLETED"
                                <%= editSchedule != null
                                        && "COMPLETED".equalsIgnoreCase(
                                                editSchedule.getStatus())
                                        ? "selected"
                                        : "" %>>
                                COMPLETED
                            </option>

                            <option value="CANCELLED"
                                <%= editSchedule != null
                                        && "CANCELLED".equalsIgnoreCase(
                                                editSchedule.getStatus())
                                        ? "selected"
                                        : "" %>>
                                CANCELLED
                            </option>

                        </select>

                    </div>


                    <!-- NOTES -->

                    <div class="form-group full">

                        <label for="notes">
                            Notes
                        </label>

                        <textarea id="notes"
                                  name="notes"
                                  maxlength="500"
                                  placeholder="Enter schedule notes"><%= editSchedule != null
                                        && editSchedule.getNotes() != null
                                        ? editSchedule.getNotes()
                                        : "" %></textarea>

                    </div>

                </div>


                <div class="form-actions">

                    <button type="submit"
                            class="btn btn-primary">

                        <%= editSchedule == null
                                ? "Create Schedule"
                                : "Update Schedule" %>

                    </button>


                    <% if (editSchedule != null) { %>

                        <a href="<%= contextPath %>/schedule-management"
                           class="btn btn-secondary">

                            Cancel Edit

                        </a>

                    <% } %>

                </div>

            </form>

        </div>

    </div>


    <!-- SEARCH -->

    <div class="card">

        <div class="card-header">

            <h2>
                Search Schedules
            </h2>

        </div>

        <div class="card-body">

            <form method="get"
                  action="<%= contextPath %>/schedule-management">

                <div class="search-row">

                    <input type="text"
                           name="keyword"
                           placeholder="Search by ID, task ID, customer ID, employee ID, priority, status or notes"
                           value="<%= keyword != null
                                   ? keyword
                                   : "" %>">

                    <button type="submit"
                            class="btn btn-primary">

                        Search

                    </button>

                    <a href="<%= contextPath %>/schedule-management"
                       class="btn btn-secondary">

                        Clear

                    </a>

                </div>

            </form>

        </div>

    </div>


    <!-- SCHEDULE LIST -->

    <div class="card">

        <div class="card-header">

            <h2>
                Schedule List
            </h2>

        </div>

        <div class="card-body">

            <% if (schedules.isEmpty()) { %>

                <div class="empty-state">
                    No schedules found.
                </div>

            <% } else { %>

                <div class="table-container">

                    <table>

                        <thead>

                            <tr>

                                <th>ID</th>

                                <th>Task ID</th>

                                <th>Customer</th>

                                <th>Employee</th>

                                <th>Start</th>

                                <th>End</th>

                                <th>Priority</th>

                                <th>Status</th>

                                <th>Notes</th>

                                <th>Actions</th>

                            </tr>

                        </thead>

                        <tbody>

                        <% for (Schedule schedule : schedules) { %>

                            <tr>

                                <td>
                                    <strong>
                                        <%= schedule.getId() %>
                                    </strong>
                                </td>


                                <td>
                                    <%= schedule.getTaskId() %>
                                </td>


                                <td>

                                    <%
                                        String customerName =
                                                "Customer ID "
                                                + schedule.getCustomerId();

                                        for (Customer customer : customers) {

                                            if (customer.getId()
                                                    .equals(
                                                        schedule.getCustomerId()
                                                    )) {

                                                customerName =
                                                        customer.getName();

                                                break;
                                            }
                                        }
                                    %>

                                    <%= customerName %>

                                </td>


                                <td>

                                    <%
                                        String employeeName = "Not Assigned";

                                        if (schedule.getEmployeeId()
                                                != null) {

                                            for (Employee employee
                                                    : employees) {

                                                if (employee.getId()
                                                        .equals(
                                                            schedule
                                                                .getEmployeeId()
                                                        )) {

                                                    employeeName =
                                                            employee
                                                                .getEmployeeCode()
                                                            + " - "
                                                            + employee
                                                                .getName();

                                                    break;
                                                }
                                            }
                                        }
                                    %>

                                    <%= employeeName %>

                                </td>


                                <td>

                                    <%= schedule.getScheduledStart()
                                            != null
                                            ? schedule
                                                .getScheduledStart()
                                                .format(
                                                    displayFormatter
                                                )
                                            : "-" %>

                                </td>


                                <td>

                                    <%= schedule.getScheduledEnd()
                                            != null
                                            ? schedule
                                                .getScheduledEnd()
                                                .format(
                                                    displayFormatter
                                                )
                                            : "-" %>

                                </td>


                                <td>

                                    <%
                                        String priority =
                                                schedule.getPriority();

                                        String priorityClass =
                                                "badge-medium";

                                        if ("LOW".equalsIgnoreCase(priority)) {
                                            priorityClass = "badge-low";
                                        } else if ("HIGH".equalsIgnoreCase(priority)) {
                                            priorityClass = "badge-high";
                                        } else if ("URGENT".equalsIgnoreCase(priority)) {
                                            priorityClass = "badge-urgent";
                                        }
                                    %>

                                    <span class="badge <%= priorityClass %>">
                                        <%= priority != null
                                                ? priority
                                                : "-" %>
                                    </span>

                                </td>


                                <td>

                                    <%
                                        String status =
                                                schedule.getStatus();

                                        String statusClass =
                                                "badge-scheduled";

                                        if ("IN_PROGRESS"
                                                .equalsIgnoreCase(status)) {

                                            statusClass =
                                                    "badge-progress";

                                        } else if ("COMPLETED"
                                                .equalsIgnoreCase(status)) {

                                            statusClass =
                                                    "badge-completed";

                                        } else if ("CANCELLED"
                                                .equalsIgnoreCase(status)) {

                                            statusClass =
                                                    "badge-cancelled";
                                        }
                                    %>

                                    <span class="badge <%= statusClass %>">
                                        <%= status != null
                                                ? status.replace(
                                                    "_",
                                                    " "
                                                  )
                                                : "-" %>
                                    </span>

                                </td>


                                <td>

                                    <%= schedule.getNotes() != null
                                            && !schedule.getNotes()
                                                    .trim()
                                                    .isEmpty()
                                            ? schedule.getNotes()
                                            : "-" %>

                                </td>


                                <td>

                                    <div class="action-group">

                                        <a class="btn btn-primary small-btn"
                                           href="<%= contextPath %>/schedule-management?editId=<%= schedule.getId() %>">

                                            Edit

                                        </a>


                                        <% if (!"COMPLETED".equalsIgnoreCase(
                                                schedule.getStatus())) { %>

                                            <form method="post"
                                                  action="<%= contextPath %>/schedule-management"
                                                  style="display:inline;">

                                                <input type="hidden"
                                                       name="action"
                                                       value="status">

                                                <input type="hidden"
                                                       name="id"
                                                       value="<%= schedule.getId() %>">

                                                <input type="hidden"
                                                       name="status"
                                                       value="IN_PROGRESS">

                                                <button type="submit"
                                                        class="btn btn-warning small-btn">

                                                    In Progress

                                                </button>

                                            </form>

                                        <% } %>


                                        <% if (!"COMPLETED".equalsIgnoreCase(
                                                schedule.getStatus())) { %>

                                            <form method="post"
                                                  action="<%= contextPath %>/schedule-management"
                                                  style="display:inline;">

                                                <input type="hidden"
                                                       name="action"
                                                       value="status">

                                                <input type="hidden"
                                                       name="id"
                                                       value="<%= schedule.getId() %>">

                                                <input type="hidden"
                                                       name="status"
                                                       value="COMPLETED">

                                                <button type="submit"
                                                        class="btn btn-success small-btn">

                                                    Complete

                                                </button>

                                            </form>

                                        <% } %>


                                        <% if (!"CANCELLED".equalsIgnoreCase(
                                                schedule.getStatus())) { %>

                                            <form method="post"
                                                  action="<%= contextPath %>/schedule-management"
                                                  style="display:inline;">

                                                <input type="hidden"
                                                       name="action"
                                                       value="status">

                                                <input type="hidden"
                                                       name="id"
                                                       value="<%= schedule.getId() %>">

                                                <input type="hidden"
                                                       name="status"
                                                       value="CANCELLED">

                                                <button type="submit"
                                                        class="btn btn-danger small-btn">

                                                    Cancel

                                                </button>

                                            </form>

                                        <% } %>


                                        <form method="post"
                                              action="<%= contextPath %>/schedule-management"
                                              style="display:inline;"
                                              onsubmit="return confirm('Are you sure you want to delete this schedule?');">

                                            <input type="hidden"
                                                   name="action"
                                                   value="delete">

                                            <input type="hidden"
                                                   name="id"
                                                   value="<%= schedule.getId() %>">

                                            <button type="submit"
                                                    class="btn btn-danger small-btn">

                                                Delete

                                            </button>

                                        </form>

                                    </div>

                                </td>

                            </tr>

                        <% } %>

                        </tbody>

                    </table>

                </div>

            <% } %>

        </div>

    </div>

</main>


<script>

    const startInput =
        document.getElementById("scheduledStart");

    const endInput =
        document.getElementById("scheduledEnd");

    function validateScheduleTime() {

        if (!startInput || !endInput) {
            return true;
        }

        if (startInput.value
                && endInput.value
                && endInput.value <= startInput.value) {

            endInput.setCustomValidity(
                "Scheduled end must be after scheduled start."
            );

            return false;

        } else {

            endInput.setCustomValidity("");

            return true;
        }
    }

    if (startInput) {
        startInput.addEventListener(
            "change",
            validateScheduleTime
        );
    }

    if (endInput) {
        endInput.addEventListener(
            "change",
            validateScheduleTime
        );
    }

</script>

</body>
</html>      