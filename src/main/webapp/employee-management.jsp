<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="com.schedulingdispatch.model.Employee" %>
<%@ page import="com.schedulingdispatch.model.User" %>

<%
    String contextPath = request.getContextPath();

    List<Employee> employees =
            (List<Employee>) request.getAttribute("employees");

    Employee editEmployee =
            (Employee) request.getAttribute("editEmployee");

    List<User> availableUsers =
            (List<User>) request.getAttribute("availableUsers");

    String keyword =
            (String) request.getAttribute("keyword");

    String success =
            request.getParameter("success");

    String error =
            (String) request.getAttribute("error");

    if (employees == null) {
        employees = java.util.Collections.emptyList();
    }

    if (availableUsers == null) {
        availableUsers = java.util.Collections.emptyList();
    }

    boolean editMode = editEmployee != null;
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Employee / Resource Management -
        Scheduling and Dispatching System
    </title>

    <style>

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, Helvetica, sans-serif;
            background: #f4f7fb;
            color: #172b4d;
        }

        .top-header {
            height: 64px;
            background: linear-gradient(
                90deg,
                #0878d9,
                #4355e8
            );
            color: white;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 24px;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 1000;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 21px;
            font-weight: 700;
        }

        .brand-icon {
            width: 28px;
            height: 28px;
            background: white;
            color: #111;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 2px;
            font-size: 18px;
        }

        .profile-circle {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: #f1f4f8;
            color: #607080;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
        }

        .sidebar {
            position: fixed;
            top: 64px;
            left: 0;
            bottom: 0;
            width: 215px;
            background: #14263b;
            padding-top: 18px;
            z-index: 900;
        }

        .sidebar-link {
            display: flex;
            align-items: center;
            gap: 12px;
            color: white;
            text-decoration: none;
            padding: 12px 18px;
            margin: 3px 8px;
            border-radius: 6px;
            font-size: 14px;
        }

        .sidebar-link:hover {
            background: #203a59;
        }

        .sidebar-link.active {
            background: #0878d9;
        }

        .sidebar-icon {
            width: 22px;
            text-align: center;
            font-size: 17px;
        }

        .main-content {
            margin-left: 215px;
            padding: 92px 25px 35px;
        }

        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
        }

        .page-header h1 {
            margin: 0;
            font-size: 27px;
            color: #102d52;
        }

        .page-header p {
            margin: 5px 0 0;
            color: #63758c;
            font-size: 13px;
        }

        .back-button {
            text-decoration: none;
            background: white;
            color: #17345c;
            border: 1px solid #d3deea;
            padding: 9px 14px;
            border-radius: 6px;
            font-size: 12px;
        }

        .message {
            padding: 11px 13px;
            border-radius: 6px;
            margin-bottom: 15px;
            font-size: 13px;
        }

        .success-message {
            background: #e9f9f0;
            border: 1px solid #b9e7cd;
            color: #087443;
        }

        .error-message {
            background: #fff0f0;
            border: 1px solid #f1bebe;
            color: #b42323;
        }

        .card {
            background: white;
            border: 1px solid #dce5ef;
            border-radius: 10px;
            padding: 18px;
            margin-bottom: 18px;
            box-shadow: 0 2px 8px rgba(20, 50, 80, 0.04);
        }

        .card-title {
            display: flex;
            align-items: center;
            gap: 9px;
            margin: 0 0 17px;
            font-size: 17px;
            color: #122f53;
        }

        .form-grid {
            display: grid;
            grid-template-columns:
                repeat(3, minmax(0, 1fr));
            gap: 15px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group label {
            font-size: 11px;
            font-weight: 700;
            color: #284d76;
            margin-bottom: 6px;
        }

        .form-group input,
        .form-group select {
            width: 100%;
            height: 33px;
            border: 1px solid #bfd0e4;
            border-radius: 5px;
            padding: 0 10px;
            font-size: 12px;
            color: #17345c;
            background: white;
        }

        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #0878d9;
            box-shadow: 0 0 0 2px rgba(8, 120, 217, 0.10);
        }

        .required {
            color: #e53935;
        }

        .form-actions {
            margin-top: 17px;
            display: flex;
            gap: 8px;
        }

        .button {
            border: none;
            border-radius: 5px;
            padding: 9px 14px;
            color: white;
            font-size: 12px;
            font-weight: 700;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }

        .button-primary {
            background: #0878d9;
        }

        .button-primary:hover {
            background: #0669bd;
        }

        .button-secondary {
            background: #6c7b8e;
        }

        .button-edit {
            background: #0878d9;
        }

        .button-danger {
            background: #df4b4b;
        }

        .button-warning {
            background: #ed9f00;
        }

        .search-row {
            display: flex;
            gap: 8px;
            margin-bottom: 15px;
        }

        .search-row input {
            flex: 1;
            height: 34px;
            border: 1px solid #bfd0e4;
            border-radius: 5px;
            padding: 0 10px;
            font-size: 12px;
        }

        .table-wrapper {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 1050px;
        }

        thead {
            background: #f1f6fc;
        }

        th {
            color: #29496c;
            font-size: 10px;
            text-align: left;
            padding: 11px 8px;
            white-space: nowrap;
        }

        td {
            border-top: 1px solid #e4ebf3;
            padding: 10px 8px;
            font-size: 10px;
            color: #344d69;
            white-space: nowrap;
        }

        .employee-code {
            color: #006edb;
            font-weight: 700;
        }

        .employee-name {
            font-weight: 700;
            color: #19395e;
        }

        .badge {
            display: inline-block;
            padding: 5px 9px;
            border-radius: 20px;
            font-size: 9px;
            font-weight: 700;
        }

        .badge-active {
            background: #e2f7ec;
            color: #078147;
        }

        .badge-inactive {
            background: #ffe6e6;
            color: #c63131;
        }

        .badge-available {
            background: #e2f7ec;
            color: #078147;
        }

        .badge-unavailable {
            background: #fff0dc;
            color: #cc7900;
        }

        .badge-leave {
            background: #eee7ff;
            color: #7048cc;
        }

        .actions {
            display: flex;
            gap: 5px;
        }

        .action-button {
            border: none;
            border-radius: 5px;
            padding: 7px 9px;
            color: white;
            font-size: 9px;
            font-weight: 700;
            cursor: pointer;
        }

        .action-edit {
            background: #0878d9;
        }

        .action-danger {
            background: #df4b4b;
        }

        .action-warning {
            background: #ed9f00;
        }

        .record-count {
            float: right;
            background: #eaf3ff;
            color: #0878d9;
            padding: 6px 10px;
            border-radius: 20px;
            font-size: 10px;
            font-weight: 700;
        }

        .empty-message {
            text-align: center;
            padding: 25px;
            color: #718096;
            font-size: 12px;
        }

        @media (max-width: 1000px) {

            .form-grid {
                grid-template-columns:
                    repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 700px) {

            .sidebar {
                width: 65px;
            }

            .sidebar-link span:last-child {
                display: none;
            }

            .main-content {
                margin-left: 65px;
                padding-left: 15px;
                padding-right: 15px;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }

            .page-header {
                align-items: flex-start;
                gap: 12px;
            }

            .brand {
                font-size: 15px;
            }
        }

    </style>

</head>

<body>

<!-- TOP HEADER -->

<header class="top-header">

    <div class="brand">

        <div class="brand-icon">
            📅
        </div>

        <span>
            Scheduling and Dispatching System
        </span>

    </div>

    <div class="profile-circle">
        S
    </div>

</header>


<!-- SIDEBAR -->

<aside class="sidebar">

    <a href="<%= contextPath %>/dashboard"
       class="sidebar-link">

        <span class="sidebar-icon">🏠</span>
        <span>Dashboard</span>

    </a>

    <a href="<%= contextPath %>/user-management"
       class="sidebar-link">

        <span class="sidebar-icon">👥</span>
        <span>User Management</span>

    </a>

    <a href="<%= contextPath %>/customer-management"
       class="sidebar-link">

        <span class="sidebar-icon">👨‍👩‍👧</span>
        <span>Customer Management</span>

    </a>

    <a href="<%= contextPath %>/employee-management"
       class="sidebar-link active">

        <span class="sidebar-icon">🧑‍🔧</span>
        <span>Employee / Resource</span>

    </a>

    <a href="#"
       class="sidebar-link">

        <span class="sidebar-icon">📅</span>
        <span>Scheduling</span>

    </a>

    <a href="#"
       class="sidebar-link">

        <span class="sidebar-icon">🚚</span>
        <span>Dispatching</span>

    </a>

    <a href="#"
       class="sidebar-link">

        <span class="sidebar-icon">📊</span>
        <span>Reports</span>

    </a>

    <a href="#"
       class="sidebar-link">

        <span class="sidebar-icon">⚙️</span>
        <span>System Configuration</span>

    </a>

</aside>


<!-- MAIN CONTENT -->

<main class="main-content">

    <div class="page-header">

        <div>

            <h1>
                Employee / Resource Management
            </h1>

            <p>
                Manage employees, technicians and resource availability.
            </p>

        </div>

        <a href="<%= contextPath %>/dashboard"
           class="back-button">
            ← Back to Dashboard
        </a>

    </div>


    <!-- SUCCESS MESSAGE -->

    <% if (success != null && !success.trim().isEmpty()) { %>

        <div class="message success-message">
            ✓ <%= success %>
        </div>

    <% } %>


    <!-- ERROR MESSAGE -->

    <% if (error != null && !error.trim().isEmpty()) { %>

        <div class="message error-message">
            ⚠ <%= error %>
        </div>

    <% } %>


    <!-- ADD / EDIT EMPLOYEE -->

    <div class="card">

        <h2 class="card-title">

            <span>
                <%= editMode ? "✎" : "✚" %>
            </span>

            <%= editMode
                    ? "Edit Employee"
                    : "Add Employee" %>

        </h2>


        <form method="post"
              action="<%= contextPath %>/employee-management">

            <input type="hidden"
                   name="action"
                   value="<%= editMode ? "update" : "create" %>">

            <% if (editMode) { %>

                <input type="hidden"
                       name="id"
                       value="<%= editEmployee.getId() %>">

            <% } %>


            <div class="form-grid">


                <!-- LOGIN USER -->

                <div class="form-group">

                    <label>
                        Login User <span class="required">*</span>
                    </label>

                    <select name="userId"
                            required>

                        <option value="">
                            -- Select Login User --
                        </option>

                        <%
                            for (User user : availableUsers) {

                                boolean selected = false;

                                if (editMode
                                        && editEmployee.getUserId() != null
                                        && editEmployee.getUserId()
                                            .equals(user.getId())) {

                                    selected = true;
                                }
                        %>

                            <option value="<%= user.getId() %>"
                                    <%= selected ? "selected" : "" %>>

                                <%= user.getFullName() %>
                                -
                                <%= user.getUsername() %>
                                -
                                <%= user.getRole() %>

                            </option>

                        <%
                            }
                        %>

                    </select>

                </div>


                <!-- EMPLOYEE CODE -->

                <div class="form-group">

                    <label>
                        Employee Code
                        <span class="required">*</span>
                    </label>

                    <input type="text"
                           name="employeeCode"
                           maxlength="50"
                           required
                           value="<%= editMode
                                ? editEmployee.getEmployeeCode()
                                : "" %>"
                           placeholder="EMP001">

                </div>


                <!-- EMPLOYEE NAME -->

                <div class="form-group">

                    <label>
                        Employee Name
                        <span class="required">*</span>
                    </label>

                    <input type="text"
                           name="name"
                           maxlength="100"
                           required
                           value="<%= editMode
                                ? editEmployee.getName()
                                : "" %>"
                           placeholder="Enter employee name">

                </div>


                <!-- EMAIL -->

                <div class="form-group">

                    <label>
                        Email
                    </label>

                    <input type="email"
                           name="email"
                           maxlength="100"
                           value="<%= editMode
                                && editEmployee.getEmail() != null
                                ? editEmployee.getEmail()
                                : "" %>"
                           placeholder="employee@example.com">

                </div>


                <!-- PHONE -->

                <div class="form-group">

                    <label>
                        Phone
                    </label>

                    <input type="text"
                           name="phone"
                           maxlength="20"
                           value="<%= editMode
                                && editEmployee.getPhone() != null
                                ? editEmployee.getPhone()
                                : "" %>"
                           placeholder="9876543210">

                </div>


                <!-- DESIGNATION -->

                <div class="form-group">

                    <label>
                        Designation
                    </label>

                    <input type="text"
                           name="designation"
                           maxlength="100"
                           value="<%= editMode
                                && editEmployee.getDesignation() != null
                                ? editEmployee.getDesignation()
                                : "" %>"
                           placeholder="Technician">

                </div>


                <!-- AVAILABILITY STATUS -->

                <div class="form-group">

                    <label>
                        Availability Status
                    </label>

                    <select name="availabilityStatus">

                        <option value="AVAILABLE"
                            <%= editMode
                                && "AVAILABLE".equals(
                                    editEmployee.getAvailabilityStatus())
                                ? "selected"
                                : "" %>>
                            AVAILABLE
                        </option>

                        <option value="UNAVAILABLE"
                            <%= editMode
                                && "UNAVAILABLE".equals(
                                    editEmployee.getAvailabilityStatus())
                                ? "selected"
                                : "" %>>
                            UNAVAILABLE
                        </option>

                        <option value="ON_LEAVE"
                            <%= editMode
                                && "ON_LEAVE".equals(
                                    editEmployee.getAvailabilityStatus())
                                ? "selected"
                                : "" %>>
                            ON_LEAVE
                        </option>

                    </select>

                </div>


                <!-- STATUS -->

                <div class="form-group">

                    <label>
                        Status
                    </label>

                    <select name="status">

                        <option value="ACTIVE"
                            <%= editMode
                                && "ACTIVE".equals(
                                    editEmployee.getStatus())
                                ? "selected"
                                : "" %>>
                            ACTIVE
                        </option>

                        <option value="INACTIVE"
                            <%= editMode
                                && "INACTIVE".equals(
                                    editEmployee.getStatus())
                                ? "selected"
                                : "" %>>
                            INACTIVE
                        </option>

                    </select>

                </div>

            </div>


            <!-- FORM BUTTONS -->

            <div class="form-actions">

                <button type="submit"
                        class="button button-primary">

                    <%= editMode
                            ? "Update Employee"
                            : "Add Employee" %>

                </button>

                <% if (editMode) { %>

                    <a href="<%= contextPath %>/employee-management"
                       class="button button-secondary">
                        Cancel
                    </a>

                <% } %>

            </div>

        </form>

    </div>


    <!-- SEARCH + EMPLOYEE LIST -->

    <div class="card">

        <h2 class="card-title">

            <span>
                👥
            </span>

            Employee List

            <span class="record-count">
                <%= employees.size() %> Record(s)
            </span>

        </h2>


        <!-- SEARCH -->

        <form method="get"
              action="<%= contextPath %>/employee-management"
              class="search-row">

            <input type="text"
                   name="keyword"
                   value="<%= keyword != null
                        ? keyword
                        : "" %>"
                   placeholder="Search by employee code, name, email, phone, designation...">

            <button type="submit"
                    class="button button-primary">
                Search
            </button>

            <a href="<%= contextPath %>/employee-management"
               class="button button-secondary">
                Clear
            </a>

        </form>


        <!-- EMPLOYEE TABLE -->

        <div class="table-wrapper">

            <table>

                <thead>

                    <tr>

                        <th>ID</th>
                        <th>Login User</th>
                        <th>Employee Code</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Designation</th>
                        <th>Availability</th>
                        <th>Status</th>
                        <th>Created At</th>
                        <th>Actions</th>

                    </tr>

                </thead>

                <tbody>

                <% if (employees.isEmpty()) { %>

                    <tr>

                        <td colspan="11"
                            class="empty-message">

                            No employees found.

                        </td>

                    </tr>

                <% } else { %>

                    <% for (Employee employee : employees) { %>

                        <tr>

                            <td>
                                <%= employee.getId() %>
                            </td>

                            <td>

                                <%
                                    User employeeUser = null;

                                    if (employee.getUserId() != null) {

                                        for (User user : availableUsers) {

                                            if (employee.getUserId()
                                                    .equals(user.getId())) {

                                                employeeUser = user;
                                                break;
                                            }
                                        }
                                    }
                                %>

                                <% if (employeeUser != null) { %>

                                    <strong>
                                        <%= employeeUser.getUsername() %>
                                    </strong>

                                <% } else if (employee.getUserId() != null) { %>

                                    User ID:
                                    <%= employee.getUserId() %>

                                <% } else { %>

                                    <span style="color:#c63131;">
                                        Not Assigned
                                    </span>

                                <% } %>

                            </td>

                            <td class="employee-code">
                                <%= employee.getEmployeeCode() %>
                            </td>

                            <td class="employee-name">
                                <%= employee.getName() %>
                            </td>

                            <td>
                                <%= employee.getEmail() != null
                                    ? employee.getEmail()
                                    : "-" %>
                            </td>

                            <td>
                                <%= employee.getPhone() != null
                                    ? employee.getPhone()
                                    : "-" %>
                            </td>

                            <td>
                                <%= employee.getDesignation() != null
                                    ? employee.getDesignation()
                                    : "-" %>
                            </td>

                            <td>

                                <%
                                    String availability =
                                            employee.getAvailabilityStatus();

                                    String availabilityClass =
                                            "badge-available";

                                    if ("UNAVAILABLE".equals(
                                            availability)) {

                                        availabilityClass =
                                                "badge-unavailable";

                                    } else if ("ON_LEAVE".equals(
                                            availability)) {

                                        availabilityClass =
                                                "badge-leave";
                                    }
                                %>

                                <span class="badge <%= availabilityClass %>">
                                    <%= availability %>
                                </span>

                            </td>

                            <td>

                                <%
                                    String status =
                                            employee.getStatus();

                                    String statusClass =
                                            "badge-active";

                                    if ("INACTIVE".equals(status)) {
                                        statusClass =
                                                "badge-inactive";
                                    }
                                %>

                                <span class="badge <%= statusClass %>">
                                    <%= status %>
                                </span>

                            </td>

                            <td>
                                <%= employee.getCreatedAt() != null
                                    ? employee.getCreatedAt()
                                    : "-" %>
                            </td>

                            <td>

                                <div class="actions">

                                    <!-- EDIT -->

                                    <a href="<%= contextPath %>/employee-management?editId=<%= employee.getId() %>"
                                       class="action-button action-edit">
                                        Edit
                                    </a>


                                    <!-- STATUS -->

                                    <form method="post"
                                          action="<%= contextPath %>/employee-management"
                                          style="display:inline;">

                                        <input type="hidden"
                                               name="action"
                                               value="status">

                                        <input type="hidden"
                                               name="id"
                                               value="<%= employee.getId() %>">

                                        <input type="hidden"
                                               name="status"
                                               value="<%= "ACTIVE".equals(
                                                        employee.getStatus())
                                                        ? "INACTIVE"
                                                        : "ACTIVE" %>">

                                        <button type="submit"
                                                class="action-button action-danger">

                                            <%= "ACTIVE".equals(
                                                    employee.getStatus())
                                                    ? "Deactivate"
                                                    : "Activate" %>

                                        </button>

                                    </form>


                                    <!-- AVAILABILITY -->

                                    <form method="post"
                                          action="<%= contextPath %>/employee-management"
                                          style="display:inline;">

                                        <input type="hidden"
                                               name="action"
                                               value="availability">

                                        <input type="hidden"
                                               name="id"
                                               value="<%= employee.getId() %>">

                                        <%
                                            String nextAvailability =
                                                    "AVAILABLE";

                                            if ("AVAILABLE".equals(
                                                    employee.getAvailabilityStatus())) {

                                                nextAvailability =
                                                        "UNAVAILABLE";

                                            } else if ("UNAVAILABLE".equals(
                                                    employee.getAvailabilityStatus())) {

                                                nextAvailability =
                                                        "ON_LEAVE";
                                            }
                                        %>

                                        <input type="hidden"
                                               name="availabilityStatus"
                                               value="<%= nextAvailability %>">

                                        <button type="submit"
                                                class="action-button action-warning">

                                            Change Availability

                                        </button>

                                    </form>

                                </div>

                            </td>

                        </tr>

                    <% } %>

                <% } %>

                </tbody>

            </table>

        </div>

    </div>

</main>

</body>

</html>