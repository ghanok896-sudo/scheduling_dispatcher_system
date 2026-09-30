<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List"%>
<%@ page import="java.time.format.DateTimeFormatter"%>

<%@ page import="com.schedulingdispatch.model.Task"%>
<%@ page import="com.schedulingdispatch.model.Customer"%>
<%@ page import="com.schedulingdispatch.model.Employee"%>
<%@ page import="com.schedulingdispatch.model.User"%>

<%
    HttpSession currentSession = request.getSession(false);

    User loggedInUser = null;

    if (currentSession != null) {
        Object userObject =
                currentSession.getAttribute("loggedInUser");

        if (userObject instanceof User) {
            loggedInUser = (User) userObject;
        }
    }

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

    String contextPath = request.getContextPath();

    List<Task> tasks =
            (List<Task>) request.getAttribute("tasks");

    List<Customer> customers =
            (List<Customer>) request.getAttribute("customers");

    List<Employee> employees =
            (List<Employee>) request.getAttribute("employees");

    Task editTask =
            (Task) request.getAttribute("editTask");

    String keyword =
            (String) request.getAttribute("keyword");

    String error =
            (String) request.getAttribute("error");

    String success =
            request.getParameter("success");

    DateTimeFormatter dateTimeFormatter =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    DateTimeFormatter inputDateTimeFormatter =
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    String pageTitle =
            editTask == null
                    ? "Task Management"
                    : "Edit Task";

    String firstLetter = "?";

    if (loggedInUser.getFullName() != null
            && !loggedInUser.getFullName().trim().isEmpty()) {

        firstLetter =
                loggedInUser.getFullName()
                        .trim()
                        .substring(0, 1)
                        .toUpperCase();
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title><%= pageTitle %> - Scheduling & Dispatching System</title>

    <style>

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: Arial, Helvetica, sans-serif;
            background: #f4f6f9;
            color: #263238;
            min-height: 100vh;
        }

        .top-header {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            height: 70px;
            background: #ffffff;
            border-bottom: 1px solid #e5e7eb;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 28px;
            z-index: 1000;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .brand-icon {
            width: 42px;
            height: 42px;
            border-radius: 10px;
            background: #2563eb;
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 19px;
            font-weight: bold;
        }

        .brand-text h1 {
            font-size: 19px;
            color: #111827;
            margin-bottom: 2px;
        }

        .brand-text span {
            font-size: 12px;
            color: #6b7280;
        }

        .header-right {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .user-info {
            text-align: right;
        }

        .user-info strong {
            display: block;
            font-size: 14px;
            color: #111827;
        }

        .user-info span {
            font-size: 12px;
            color: #6b7280;
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: #2563eb;
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
        }

        .sidebar {
            position: fixed;
            top: 70px;
            left: 0;
            bottom: 0;
            width: 250px;
            background: #111827;
            padding: 22px 14px;
            overflow-y: auto;
            z-index: 900;
        }

        .sidebar-title {
            color: #9ca3af;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 1px;
            padding: 0 14px 10px;
        }

        .nav-link {
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
            color: #d1d5db;
            padding: 12px 14px;
            border-radius: 8px;
            margin-bottom: 5px;
            font-size: 14px;
            transition: 0.2s;
        }

        .nav-link:hover {
            background: #1f2937;
            color: #ffffff;
        }

        .nav-link.active {
            background: #2563eb;
            color: #ffffff;
        }

        .nav-icon {
            width: 20px;
            text-align: center;
            font-size: 15px;
        }

        .main-content {
            margin-left: 250px;
            padding: 100px 30px 40px;
        }

        .page-heading {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
            margin-bottom: 24px;
        }

        .page-heading h2 {
            font-size: 27px;
            color: #111827;
            margin-bottom: 5px;
        }

        .page-heading p {
            color: #6b7280;
            font-size: 14px;
        }

        .page-badge {
            background: #dbeafe;
            color: #1d4ed8;
            padding: 9px 14px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
        }

        .alert {
            padding: 13px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        .alert-error {
            background: #fee2e2;
            border: 1px solid #fecaca;
            color: #991b1b;
        }

        .alert-success {
            background: #dcfce7;
            border: 1px solid #bbf7d0;
            color: #166534;
        }

        .card {
            background: #ffffff;
            border: 1px solid #e5e7eb;
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: 0 2px 7px rgba(0, 0, 0, 0.03);
        }

        .card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
            margin-bottom: 20px;
        }

        .card-header h3 {
            font-size: 18px;
            color: #111827;
        }

        .card-header p {
            font-size: 13px;
            color: #6b7280;
            margin-top: 4px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 18px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group.full-width {
            grid-column: 1 / -1;
        }

        label {
            font-size: 13px;
            font-weight: 600;
            color: #374151;
            margin-bottom: 7px;
        }

        input,
        select,
        textarea {
            width: 100%;
            padding: 11px 12px;
            border: 1px solid #d1d5db;
            border-radius: 7px;
            font-size: 14px;
            color: #111827;
            background: #ffffff;
            outline: none;
        }

        input:focus,
        select:focus,
        textarea:focus {
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.10);
        }

        textarea {
            resize: vertical;
            min-height: 95px;
        }

        .help-text {
            font-size: 11px;
            color: #6b7280;
            margin-top: 5px;
        }

        .form-actions {
            display: flex;
            gap: 10px;
            margin-top: 22px;
            flex-wrap: wrap;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            border: none;
            border-radius: 7px;
            padding: 10px 17px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: 0.2s;
        }

        .btn-primary {
            background: #2563eb;
            color: #ffffff;
        }

        .btn-primary:hover {
            background: #1d4ed8;
        }

        .btn-secondary {
            background: #e5e7eb;
            color: #374151;
        }

        .btn-secondary:hover {
            background: #d1d5db;
        }

        .btn-success {
            background: #16a34a;
            color: #ffffff;
        }

        .btn-success:hover {
            background: #15803d;
        }

        .btn-warning {
            background: #f59e0b;
            color: #ffffff;
        }

        .btn-warning:hover {
            background: #d97706;
        }

        .btn-danger {
            background: #dc2626;
            color: #ffffff;
        }

        .btn-danger:hover {
            background: #b91c1c;
        }

        .btn-small {
            padding: 7px 10px;
            font-size: 11px;
        }

        .search-row {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }

        .search-row input {
            flex: 1;
        }

        .table-wrapper {
            width: 100%;
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 1050px;
        }

        thead {
            background: #f9fafb;
        }

        th {
            text-align: left;
            padding: 13px 12px;
            border-bottom: 1px solid #e5e7eb;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.4px;
            color: #6b7280;
            white-space: nowrap;
        }

        td {
            padding: 14px 12px;
            border-bottom: 1px solid #f0f1f3;
            font-size: 13px;
            color: #374151;
            vertical-align: middle;
        }

        tbody tr:hover {
            background: #fafafa;
        }

        .task-title {
            font-weight: 600;
            color: #111827;
        }

        .task-description {
            max-width: 240px;
            color: #6b7280;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .badge {
            display: inline-flex;
            padding: 5px 9px;
            border-radius: 15px;
            font-size: 10px;
            font-weight: 700;
            white-space: nowrap;
        }

        .priority-low {
            background: #dcfce7;
            color: #166534;
        }

        .priority-medium {
            background: #dbeafe;
            color: #1d4ed8;
        }

        .priority-high {
            background: #fef3c7;
            color: #92400e;
        }

        .priority-urgent {
            background: #fee2e2;
            color: #991b1b;
        }

        .status-pending {
            background: #f3f4f6;
            color: #374151;
        }

        .status-in-progress {
            background: #dbeafe;
            color: #1d4ed8;
        }

        .status-completed {
            background: #dcfce7;
            color: #166534;
        }

        .status-cancelled {
            background: #fee2e2;
            color: #991b1b;
        }

        .action-group {
            display: flex;
            gap: 5px;
            flex-wrap: wrap;
        }

        .inline-form {
            display: inline;
        }

        .empty-state {
            text-align: center;
            padding: 45px 20px;
            color: #6b7280;
        }

        .empty-state strong {
            display: block;
            color: #374151;
            font-size: 15px;
            margin-bottom: 6px;
        }

        .footer-note {
            text-align: center;
            color: #9ca3af;
            font-size: 12px;
            padding: 15px 0;
        }

        @media (max-width: 1000px) {

            .sidebar {
                width: 220px;
            }

            .main-content {
                margin-left: 220px;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }

            .form-group.full-width {
                grid-column: auto;
            }
        }

        @media (max-width: 760px) {

            .top-header {
                padding: 0 15px;
            }

            .brand-text {
                display: none;
            }

            .user-info {
                display: none;
            }

            .sidebar {
                position: static;
                width: 100%;
                height: auto;
                padding: 10px;
                margin-top: 70px;
            }

            .main-content {
                margin-left: 0;
                padding: 25px 15px;
            }

            .top-header {
                position: fixed;
            }

            .sidebar-title {
                display: none;
            }

            .nav-link {
                display: inline-flex;
                margin-right: 4px;
            }

            .page-heading {
                align-items: flex-start;
                flex-direction: column;
            }

            .search-row {
                flex-direction: column;
            }

            .card {
                padding: 18px;
            }
        }

    </style>

</head>

<body>

<header class="top-header">

    <div class="brand">

        <div class="brand-icon">
            SD
        </div>

        <div class="brand-text">
            <h1>Scheduling & Dispatching</h1>
            <span>Management System</span>
        </div>

    </div>

    <div class="header-right">

        <div class="user-info">

            <strong>
                <%= loggedInUser.getFullName() != null
                        ? loggedInUser.getFullName()
                        : loggedInUser.getUsername() %>
            </strong>

            <span>
                <%= loggedInUser.getRole() %>
            </span>

        </div>

        <div class="user-avatar">
            <%= firstLetter %>
        </div>

    </div>

</header>


<aside class="sidebar">

    <div class="sidebar-title">
        Main Menu
    </div>

    <a href="<%= contextPath %>/dashboard"
       class="nav-link">

        <span class="nav-icon">⌂</span>
        <span>Dashboard</span>

    </a>

    <a href="<%= contextPath %>/user-management"
       class="nav-link">

        <span class="nav-icon">👤</span>
        <span>User Management</span>

    </a>

    <a href="<%= contextPath %>/customer-management"
       class="nav-link">

        <span class="nav-icon">👥</span>
        <span>Customer Management</span>

    </a>

    <a href="<%= contextPath %>/employee-management"
       class="nav-link">

        <span class="nav-icon">🧑‍💼</span>
        <span>Employee / Resource</span>

    </a>

    <a href="<%= contextPath %>/task-management"
       class="nav-link active">

        <span class="nav-icon">✓</span>
        <span>Task Management</span>

    </a>

    <a href="<%= contextPath %>/schedule-management"
       class="nav-link">

        <span class="nav-icon">▣</span>
        <span>Scheduling</span>

    </a>

    <a href="#"
       class="nav-link">

        <span class="nav-icon">⇢</span>
        <span>Dispatching</span>

    </a>

    <a href="#"
       class="nav-link">

        <span class="nav-icon">▤</span>
        <span>Reports</span>

    </a>

    <a href="#"
       class="nav-link">

        <span class="nav-icon">⚙</span>
        <span>System Configuration</span>

    </a>

    <a href="<%= contextPath %>/logout"
       class="nav-link">

        <span class="nav-icon">↪</span>
        <span>Logout</span>

    </a>

</aside>


<main class="main-content">

    <div class="page-heading">

        <div>

            <h2>
                <%= editTask == null
                        ? "Task Management"
                        : "Edit Task" %>
            </h2>

            <p>
                Create, assign, update and manage operational tasks.
            </p>

        </div>

        <div class="page-badge">
            ADMIN
        </div>

    </div>


    <% if (error != null && !error.trim().isEmpty()) { %>

        <div class="alert alert-error">
            <%= error %>
        </div>

    <% } %>


    <% if (success != null && !success.trim().isEmpty()) { %>

        <div class="alert alert-success">
            <%= success %>
        </div>

    <% } %>


    <section class="card">

        <div class="card-header">

            <div>

                <h3>
                    <%= editTask == null
                            ? "Create New Task"
                            : "Update Task" %>
                </h3>

                <p>
                    Enter the task details and assignment information.
                </p>

            </div>

        </div>


        <form method="post"
              action="<%= contextPath %>/task-management"
              onsubmit="return validateTaskForm();">

            <input type="hidden"
                   name="action"
                   value="<%= editTask == null
                           ? "create"
                           : "update" %>">

            <% if (editTask != null) { %>

                <input type="hidden"
                       name="taskId"
                       value="<%= editTask.getId() %>">

            <% } %>


            <div class="form-grid">

                <div class="form-group full-width">

                    <label for="title">
                        Task Title *
                    </label>

                    <input type="text"
                           id="title"
                           name="title"
                           maxlength="150"
                           required
                           value="<%= editTask != null
                                   && editTask.getTitle() != null
                                   ? editTask.getTitle()
                                   : "" %>"
                           placeholder="Enter task title">

                </div>


                <div class="form-group full-width">

                    <label for="description">
                        Description
                    </label>

                    <textarea id="description"
                              name="description"
                              maxlength="500"
                              placeholder="Enter task description"><%= editTask != null
                                      && editTask.getDescription() != null
                                      ? editTask.getDescription()
                                      : "" %></textarea>

                    <span class="help-text">
                        Maximum 500 characters.
                    </span>

                </div>


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

                        <%
                            if (customers != null) {

                                for (Customer customer : customers) {

                                    boolean selected =
                                            editTask != null
                                            && editTask.getCustomerId() != null
                                            && editTask.getCustomerId()
                                                    .equals(customer.getId());
                        %>

                            <option value="<%= customer.getId() %>"
                                    <%= selected ? "selected" : "" %>>

                                <%= customer.getName() %>

                                <% if (customer.getPhone() != null
                                        && !customer.getPhone().trim().isEmpty()) { %>

                                    - <%= customer.getPhone() %>

                                <% } %>

                            </option>

                        <%
                                }
                            }
                        %>

                    </select>

                </div>


                <div class="form-group">

                    <label for="assignedEmployeeId">
                        Assign Employee
                    </label>

                    <select id="assignedEmployeeId"
                            name="assignedEmployeeId">

                        <option value="">
                            -- Unassigned --
                        </option>

                        <%
                            if (employees != null) {

                                for (Employee employee : employees) {

                                    boolean selected =
                                            editTask != null
                                            && editTask.getAssignedEmployeeId() != null
                                            && editTask.getAssignedEmployeeId()
                                                    .equals(employee.getId());
                        %>

                            <option value="<%= employee.getId() %>"
                                    <%= selected ? "selected" : "" %>>

                                <%= employee.getName() %>
                                - <%= employee.getEmployeeCode() %>

                            </option>

                        <%
                                }
                            }
                        %>

                    </select>

                    <span class="help-text">
                        Only active and available employees are listed.
                    </span>

                </div>


                <div class="form-group">

                    <label for="priority">
                        Priority
                    </label>

                    <select id="priority"
                            name="priority">

                        <option value="LOW"
                            <%= editTask != null
                                && "LOW".equalsIgnoreCase(editTask.getPriority())
                                ? "selected"
                                : "" %>>
                            Low
                        </option>

                        <option value="MEDIUM"
                            <%= editTask == null
                                || "MEDIUM".equalsIgnoreCase(editTask.getPriority())
                                ? "selected"
                                : "" %>>
                            Medium
                        </option>

                        <option value="HIGH"
                            <%= editTask != null
                                && "HIGH".equalsIgnoreCase(editTask.getPriority())
                                ? "selected"
                                : "" %>>
                            High
                        </option>

                        <option value="URGENT"
                            <%= editTask != null
                                && "URGENT".equalsIgnoreCase(editTask.getPriority())
                                ? "selected"
                                : "" %>>
                            Urgent
                        </option>

                    </select>

                </div>


                <div class="form-group">

                    <label for="status">
                        Status
                    </label>

                    <select id="status"
                            name="status">

                        <option value="PENDING"
                            <%= editTask == null
                                || "PENDING".equalsIgnoreCase(editTask.getStatus())
                                ? "selected"
                                : "" %>>
                            Pending
                        </option>

                        <option value="IN_PROGRESS"
                            <%= editTask != null
                                && "IN_PROGRESS".equalsIgnoreCase(editTask.getStatus())
                                ? "selected"
                                : "" %>>
                            In Progress
                        </option>

                        <option value="COMPLETED"
                            <%= editTask != null
                                && "COMPLETED".equalsIgnoreCase(editTask.getStatus())
                                ? "selected"
                                : "" %>>
                            Completed
                        </option>

                        <option value="CANCELLED"
                            <%= editTask != null
                                && "CANCELLED".equalsIgnoreCase(editTask.getStatus())
                                ? "selected"
                                : "" %>>
                            Cancelled
                        </option>

                    </select>

                </div>


                <div class="form-group">

                    <label for="dueDate">
                        Due Date
                    </label>

                    <input type="datetime-local"
                           id="dueDate"
                           name="dueDate"
                           value="<%= editTask != null
                                   && editTask.getDueDate() != null
                                   ? editTask.getDueDate()
                                        .format(inputDateTimeFormatter)
                                   : "" %>">

                </div>

            </div>


            <div class="form-actions">

                <button type="submit"
                        class="btn btn-primary">

                    <%= editTask == null
                            ? "Create Task"
                            : "Update Task" %>

                </button>


                <% if (editTask != null) { %>

                    <a href="<%= contextPath %>/task-management"
                       class="btn btn-secondary">

                        Cancel Edit

                    </a>

                <% } %>

            </div>

        </form>

    </section>


    <section class="card">

        <div class="card-header">

            <div>

                <h3>
                    Task List
                </h3>

                <p>
                    View and manage all tasks.
                </p>

            </div>

        </div>


        <form method="get"
              action="<%= contextPath %>/task-management"
              class="search-row">

            <input type="text"
                   name="keyword"
                   value="<%= keyword != null ? keyword : "" %>"
                   placeholder="Search by title, description, priority or status">

            <button type="submit"
                    class="btn btn-primary">

                Search

            </button>

            <a href="<%= contextPath %>/task-management"
               class="btn btn-secondary">

                Clear

            </a>

        </form>


        <div class="table-wrapper">

            <%
                if (tasks == null || tasks.isEmpty()) {
            %>

                <div class="empty-state">

                    <strong>
                        No tasks found.
                    </strong>

                    Create a task using the form above.

                </div>

            <%
                } else {
            %>

                <table>

                    <thead>

                        <tr>

                            <th>ID</th>
                            <th>Task</th>
                            <th>Customer</th>
                            <th>Employee</th>
                            <th>Priority</th>
                            <th>Status</th>
                            <th>Due Date</th>
                            <th>Actions</th>

                        </tr>

                    </thead>

                    <tbody>

                    <%
                        for (Task task : tasks) {

                            String priorityClass =
                                    "priority-medium";

                            if ("LOW".equalsIgnoreCase(task.getPriority())) {
                                priorityClass = "priority-low";
                            } else if ("HIGH".equalsIgnoreCase(task.getPriority())) {
                                priorityClass = "priority-high";
                            } else if ("URGENT".equalsIgnoreCase(task.getPriority())) {
                                priorityClass = "priority-urgent";
                            }

                            String statusClass =
                                    "status-pending";

                            if ("IN_PROGRESS".equalsIgnoreCase(task.getStatus())) {
                                statusClass = "status-in-progress";
                            } else if ("COMPLETED".equalsIgnoreCase(task.getStatus())) {
                                statusClass = "status-completed";
                            } else if ("CANCELLED".equalsIgnoreCase(task.getStatus())) {
                                statusClass = "status-cancelled";
                            }

                            String customerName = "Not Found";

                            if (customers != null) {

                                for (Customer customer : customers) {

                                    if (customer.getId()
                                            .equals(task.getCustomerId())) {

                                        customerName =
                                                customer.getName();

                                        break;
                                    }
                                }
                            }

                            String employeeName = "Unassigned";

                            if (task.getAssignedEmployeeId() != null
                                    && employees != null) {

                                for (Employee employee : employees) {

                                    if (employee.getId()
                                            .equals(task.getAssignedEmployeeId())) {

                                        employeeName =
                                                employee.getName();

                                        break;
                                    }
                                }
                            }
                    %>

                        <tr>

                            <td>
                                #<%= task.getId() %>
                            </td>

                            <td>

                                <div class="task-title">
                                    <%= task.getTitle() %>
                                </div>

                                <div class="task-description"
                                     title="<%= task.getDescription() != null
                                             ? task.getDescription()
                                             : "" %>">

                                    <%= task.getDescription() != null
                                            && !task.getDescription().trim().isEmpty()
                                            ? task.getDescription()
                                            : "No description" %>

                                </div>

                            </td>

                            <td>
                                <%= customerName %>
                            </td>

                            <td>
                                <%= employeeName %>
                            </td>

                            <td>

                                <span class="badge <%= priorityClass %>">

                                    <%= task.getPriority() != null
                                            ? task.getPriority()
                                            : "MEDIUM" %>

                                </span>

                            </td>

                            <td>

                                <span class="badge <%= statusClass %>">

                                    <%= task.getStatus() != null
                                            ? task.getStatus().replace("_", " ")
                                            : "PENDING" %>

                                </span>

                            </td>

                            <td>

                                <%= task.getDueDate() != null
                                        ? task.getDueDate()
                                            .format(dateTimeFormatter)
                                        : "No due date" %>

                            </td>

                            <td>

                                <div class="action-group">

                                    <a href="<%= contextPath %>/task-management?editId=<%= task.getId() %>"
                                       class="btn btn-primary btn-small">

                                        Edit

                                    </a>


                                    <% if (!"IN_PROGRESS".equalsIgnoreCase(task.getStatus())
                                            && !"COMPLETED".equalsIgnoreCase(task.getStatus())
                                            && !"CANCELLED".equalsIgnoreCase(task.getStatus())) { %>

                                        <form method="post"
                                              action="<%= contextPath %>/task-management"
                                              class="inline-form">

                                            <input type="hidden"
                                                   name="action"
                                                   value="status">

                                            <input type="hidden"
                                                   name="taskId"
                                                   value="<%= task.getId() %>">

                                            <input type="hidden"
                                                   name="status"
                                                   value="IN_PROGRESS">

                                            <button type="submit"
                                                    class="btn btn-warning btn-small">

                                                Start

                                            </button>

                                        </form>

                                    <% } %>


                                    <% if ("IN_PROGRESS".equalsIgnoreCase(task.getStatus())) { %>

                                        <form method="post"
                                              action="<%= contextPath %>/task-management"
                                              class="inline-form">

                                            <input type="hidden"
                                                   name="action"
                                                   value="status">

                                            <input type="hidden"
                                                   name="taskId"
                                                   value="<%= task.getId() %>">

                                            <input type="hidden"
                                                   name="status"
                                                   value="COMPLETED">

                                            <button type="submit"
                                                    class="btn btn-success btn-small">

                                                Complete

                                            </button>

                                        </form>

                                    <% } %>


                                    <% if (!"COMPLETED".equalsIgnoreCase(task.getStatus())
                                            && !"CANCELLED".equalsIgnoreCase(task.getStatus())) { %>

                                        <form method="post"
                                              action="<%= contextPath %>/task-management"
                                              class="inline-form"
                                              onsubmit="return confirm('Cancel this task?');">

                                            <input type="hidden"
                                                   name="action"
                                                   value="status">

                                            <input type="hidden"
                                                   name="taskId"
                                                   value="<%= task.getId() %>">

                                            <input type="hidden"
                                                   name="status"
                                                   value="CANCELLED">

                                            <button type="submit"
                                                    class="btn btn-danger btn-small">

                                                Cancel

                                            </button>

                                        </form>

                                    <% } %>


                                    <form method="post"
                                          action="<%= contextPath %>/task-management"
                                          class="inline-form"
                                          onsubmit="return confirm('Delete this task?');">

                                        <input type="hidden"
                                               name="action"
                                               value="delete">

                                        <input type="hidden"
                                               name="taskId"
                                               value="<%= task.getId() %>">

                                        <button type="submit"
                                                class="btn btn-secondary btn-small">

                                            Delete

                                        </button>

                                    </form>

                                </div>

                            </td>

                        </tr>

                    <%
                        }
                    %>

                    </tbody>

                </table>

            <%
                }
            %>

        </div>

    </section>


    <div class="footer-note">
        Scheduling & Dispatching System
    </div>

</main>


<script>

    function validateTaskForm() {

        const title =
            document.getElementById("title").value.trim();

        const customer =
            document.getElementById("customerId").value;

        const dueDate =
            document.getElementById("dueDate").value;

        if (title.length === 0) {

            alert("Task title is required.");

            return false;
        }

        if (customer === "") {

            alert("Please select a customer.");

            return false;
        }

        if (dueDate !== "") {

            const selectedDate =
                new Date(dueDate);

            const now =
                new Date();

            if (selectedDate < now) {

                alert("Due date cannot be in the past.");

                return false;
            }
        }

        return true;
    }

</script>

</body>

</html>    