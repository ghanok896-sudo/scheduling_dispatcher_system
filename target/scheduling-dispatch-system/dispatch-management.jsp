<%@ page import="com.schedulingdispatch.model.User" %>
<%@ page import="com.schedulingdispatch.model.Dispatch" %>
<%@ page import="com.schedulingdispatch.model.Schedule" %>
<%@ page import="com.schedulingdispatch.model.Employee" %>
<%@ page import="java.util.List" %>

<%
    User loggedInUser =
            (User) session.getAttribute("loggedInUser");

    if (loggedInUser == null) {
        response.sendRedirect(
                request.getContextPath() + "/login"
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

    String contextPath =
            request.getContextPath();

    List<Dispatch> dispatches =
            (List<Dispatch>) request.getAttribute(
                    "dispatches"
            );

    List<Schedule> schedules =
            (List<Schedule>) request.getAttribute(
                    "schedules"
            );

    List<Employee> employees =
            (List<Employee>) request.getAttribute(
                    "employees"
            );

    Dispatch editDispatch =
            (Dispatch) request.getAttribute(
                    "editDispatch"
            );

    String error =
            (String) request.getAttribute(
                    "error"
            );

    String keyword =
            (String) request.getAttribute(
                    "keyword"
            );

    String success =
            request.getParameter("success");
%>

<!DOCTYPE html>
<html>
<head>

    <meta charset="UTF-8">

    <title>Dispatch Management - Scheduling & Dispatching System</title>

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

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

        .header {
            height: 64px;
            background: #1f2937;
            color: white;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 20px;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 1000;
        }

        .brand {
            font-size: 17px;
            font-weight: 700;
        }

        .admin-info {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 13px;
        }

        .avatar {
            width: 30px;
            height: 30px;
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
            bottom: 0;
            left: 0;
            width: 176px;
            background: #111827;
            color: white;
            padding: 20px 10px;
            overflow-y: auto;
        }

        .menu-title {
            color: #94a3b8;
            font-size: 10px;
            text-transform: uppercase;
            margin: 5px 8px 12px;
        }

        .nav-link {
            display: block;
            color: white;
            text-decoration: none;
            padding: 10px;
            border-radius: 6px;
            font-size: 12px;
            margin-bottom: 4px;
        }

        .nav-link:hover {
            background: #374151;
        }

        .nav-link.active {
            background: #374151;
            font-weight: bold;
        }

        .main {
            margin-left: 176px;
            padding: 84px 20px 30px;
        }

        .page-title {
            font-size: 24px;
            margin: 0 0 5px;
            color: #111827;
        }

        .page-subtitle {
            font-size: 12px;
            color: #64748b;
            margin-bottom: 18px;
        }

        .message {
            padding: 12px 14px;
            border-radius: 6px;
            margin-bottom: 14px;
            font-size: 12px;
        }

        .success {
            background: #dcfce7;
            color: #166534;
            border: 1px solid #86efac;
        }

        .error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fca5a5;
        }

        .card {
            background: white;
            border-radius: 9px;
            border: 1px solid #e5e7eb;
            margin-bottom: 18px;
            overflow: hidden;
        }

        .card-header {
            padding: 16px 18px;
            border-bottom: 1px solid #e5e7eb;
        }

        .card-header h2 {
            margin: 0;
            font-size: 15px;
        }

        .card-header p {
            margin: 5px 0 0;
            color: #64748b;
            font-size: 11px;
        }

        .card-body {
            padding: 18px;
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

        .form-group.full {
            grid-column: 1 / -1;
        }

        label {
            font-size: 11px;
            font-weight: 600;
            margin-bottom: 6px;
        }

        input,
        select,
        textarea {
            width: 100%;
            padding: 9px 10px;
            border: 1px solid #cbd5e1;
            border-radius: 5px;
            font-size: 12px;
            background: white;
        }

        textarea {
            min-height: 80px;
            resize: vertical;
        }

        input:focus,
        select:focus,
        textarea:focus {
            outline: none;
            border-color: #2563eb;
        }

        .btn {
            border: none;
            border-radius: 5px;
            padding: 9px 13px;
            cursor: pointer;
            font-size: 11px;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
        }

        .btn-primary {
            background: #2563eb;
            color: white;
        }

        .btn-warning {
            background: #d97706;
            color: white;
        }

        .btn-success {
            background: #059669;
            color: white;
        }

        .btn-danger {
            background: #dc2626;
            color: white;
        }

        .btn-secondary {
            background: #e5e7eb;
            color: #111827;
        }

        .btn-edit {
            background: #2563eb;
            color: white;
        }

        .form-actions {
            margin-top: 16px;
            display: flex;
            gap: 8px;
        }

        .search-row {
            display: flex;
            gap: 8px;
            margin-bottom: 14px;
        }

        .search-row input {
            flex: 1;
        }

        .table-wrapper {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 950px;
        }

        th {
            background: #f8fafc;
            color: #475569;
            font-size: 10px;
            text-transform: uppercase;
            text-align: left;
            padding: 10px;
            border-bottom: 1px solid #e2e8f0;
        }

        td {
            padding: 10px;
            border-bottom: 1px solid #e5e7eb;
            font-size: 11px;
            vertical-align: middle;
        }

        .badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 9px;
            font-weight: 700;
        }

        .assigned {
            background: #dbeafe;
            color: #1d4ed8;
        }

        .dispatched {
            background: #fef3c7;
            color: #92400e;
        }

        .in-progress {
            background: #ede9fe;
            color: #6d28d9;
        }

        .completed {
            background: #dcfce7;
            color: #166534;
        }

        .cancelled {
            background: #fee2e2;
            color: #991b1b;
        }

        .actions {
            display: flex;
            gap: 5px;
            flex-wrap: wrap;
        }

        .actions .btn {
            padding: 6px 8px;
            font-size: 9px;
        }

        .empty {
            text-align: center;
            padding: 30px;
            color: #64748b;
        }

        @media (max-width: 900px) {

            .form-grid {
                grid-template-columns: 1fr;
            }

            .form-group.full {
                grid-column: auto;
            }

            .sidebar {
                width: 150px;
            }

            .main {
                margin-left: 150px;
            }
        }

        @media (max-width: 650px) {

            .sidebar {
                display: none;
            }

            .main {
                margin-left: 0;
                padding: 80px 12px 20px;
            }

            .header {
                padding: 0 12px;
            }
        }

    </style>

</head>

<body>

<header class="header">

    <div class="brand">
        Scheduling &amp; Dispatching System
    </div>

    <div class="admin-info">

        <span>
            <%= loggedInUser.getFullName() != null
                    ? loggedInUser.getFullName()
                    : loggedInUser.getUsername() %>
        </span>

        <div class="avatar">
            <%= loggedInUser.getFullName() != null
                    && !loggedInUser.getFullName().trim().isEmpty()
                    ? loggedInUser.getFullName()
                        .trim()
                        .substring(0, 1)
                        .toUpperCase()
                    : "A" %>
        </div>

    </div>

</header>

<aside class="sidebar">

    <div class="menu-title">
        Main Menu
    </div>

    <a class="nav-link"
       href="<%= contextPath %>/dashboard">
        Dashboard
    </a>

    <a class="nav-link"
       href="<%= contextPath %>/user-management">
        User Management
    </a>

    <a class="nav-link"
       href="<%= contextPath %>/customer-management">
        Customer Management
    </a>

    <a class="nav-link"
       href="<%= contextPath %>/employee-management">
        Employee / Resource
    </a>

    <a class="nav-link"
       href="<%= contextPath %>/task-management">
        Task Management
    </a>

    <a class="nav-link"
       href="<%= contextPath %>/schedule-management">
        Scheduling
    </a>

    <a class="nav-link active"
       href="<%= contextPath %>/dispatch-management">
        Dispatching
    </a>

    <a class="nav-link"
       href="#">
        Reports
    </a>

    <a class="nav-link"
       href="#">
        System Configuration
    </a>

    <div class="menu-title"
         style="margin-top:25px;">
        Account
    </div>

    <a class="nav-link"
       href="<%= contextPath %>/logout">
        Logout
    </a>

</aside>

<main class="main">

    <h1 class="page-title">
        Dispatch Management
    </h1>

    <div class="page-subtitle">
        Create, assign, and manage customer task dispatches.
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

    <div class="card">

        <div class="card-header">

            <h2>
                <%= editDispatch == null
                        ? "Create New Dispatch"
                        : "Edit Dispatch" %>
            </h2>

            <p>
                Select a schedule and assign the responsible employee.
            </p>

        </div>

        <div class="card-body">

            <form method="post"
                  action="<%= contextPath %>/dispatch-management">

                <input type="hidden"
                       name="action"
                       value="<%= editDispatch == null
                               ? "create"
                               : "update" %>">

                <% if (editDispatch != null) { %>

                    <input type="hidden"
                           name="id"
                           value="<%= editDispatch.getId() %>">

                <% } %>

                <div class="form-grid">

                    <div class="form-group">

                        <label>
                            Schedule *
                        </label>

                        <select name="scheduleId"
                                required>

                            <option value="">
                                -- Select Schedule --
                            </option>

                            <% if (schedules != null) {
                                for (Schedule schedule : schedules) {

                                    boolean selected =
                                            editDispatch != null
                                            && editDispatch.getScheduleId()
                                                .equals(schedule.getId());
                            %>

                                <option
                                    value="<%= schedule.getId() %>"
                                    <%= selected
                                            ? "selected"
                                            : "" %>>

                                    Schedule #<%= schedule.getId() %>
                                    -
                                    Task #<%= schedule.getTaskId() %>
                                    -
                                    <%= schedule.getStatus() %>

                                </option>

                            <%  }
                               } %>

                        </select>

                    </div>

                    <div class="form-group">

                        <label>
                            Employee / Resource *
                        </label>

                        <select name="employeeId"
                                required>

                            <option value="">
                                -- Select Employee --
                            </option>

                            <% if (employees != null) {
                                for (Employee employee : employees) {

                                    boolean selected =
                                            editDispatch != null
                                            && editDispatch.getEmployeeId()
                                                .equals(employee.getId());
                            %>

                                <option
                                    value="<%= employee.getId() %>"
                                    <%= selected
                                            ? "selected"
                                            : "" %>>

                                    <%= employee.getEmployeeCode() %>
                                    -
                                    <%= employee.getName() %>

                                </option>

                            <%  }
                               } %>

                        </select>

                    </div>

                    <div class="form-group">

                        <label>
                            Dispatch Status
                        </label>

                        <select name="dispatchStatus">

                            <option value="ASSIGNED"
                                <%= editDispatch != null
                                    && "ASSIGNED".equalsIgnoreCase(
                                        editDispatch.getDispatchStatus())
                                    ? "selected"
                                    : "" %>>
                                ASSIGNED
                            </option>

                            <option value="DISPATCHED"
                                <%= editDispatch != null
                                    && "DISPATCHED".equalsIgnoreCase(
                                        editDispatch.getDispatchStatus())
                                    ? "selected"
                                    : "" %>>
                                DISPATCHED
                            </option>

                            <option value="IN_PROGRESS"
                                <%= editDispatch != null
                                    && "IN_PROGRESS".equalsIgnoreCase(
                                        editDispatch.getDispatchStatus())
                                    ? "selected"
                                    : "" %>>
                                IN PROGRESS
                            </option>

                            <option value="COMPLETED"
                                <%= editDispatch != null
                                    && "COMPLETED".equalsIgnoreCase(
                                        editDispatch.getDispatchStatus())
                                    ? "selected"
                                    : "" %>>
                                COMPLETED
                            </option>

                            <option value="CANCELLED"
                                <%= editDispatch != null
                                    && "CANCELLED".equalsIgnoreCase(
                                        editDispatch.getDispatchStatus())
                                    ? "selected"
                                    : "" %>>
                                CANCELLED
                            </option>

                        </select>

                    </div>

                    <div class="form-group full">

                        <label>
                            Remarks
                        </label>

                        <textarea name="remarks"
                                  maxlength="1000"
                                  placeholder="Enter dispatch remarks"><%= editDispatch != null
                                    && editDispatch.getRemarks() != null
                                    ? editDispatch.getRemarks()
                                    : "" %></textarea>

                    </div>

                </div>

                <div class="form-actions">

                    <button type="submit"
                            class="btn btn-primary">

                        <%= editDispatch == null
                                ? "Create Dispatch"
                                : "Update Dispatch" %>

                    </button>

                    <% if (editDispatch != null) { %>

                        <a class="btn btn-secondary"
                           href="<%= contextPath %>/dispatch-management">

                            Cancel

                        </a>

                    <% } %>

                </div>

            </form>

        </div>

    </div>

    <div class="card">

        <div class="card-header">

            <h2>
                Dispatch List
            </h2>

            <p>
                View and manage all dispatch assignments.
            </p>

        </div>

        <div class="card-body">

            <form method="get"
                  action="<%= contextPath %>/dispatch-management"
                  class="search-row">

                <input type="text"
                       name="keyword"
                       value="<%= keyword != null ? keyword : "" %>"
                       placeholder="Search by status or remarks">

                <button type="submit"
                        class="btn btn-primary">
                    Search
                </button>

                <a href="<%= contextPath %>/dispatch-management"
                   class="btn btn-secondary">
                    Clear
                </a>

            </form>

            <div class="table-wrapper">

                <table>

                    <thead>

                    <tr>

                        <th>ID</th>
                        <th>Schedule</th>
                        <th>Employee</th>
                        <th>Status</th>
                        <th>Dispatched At</th>
                        <th>Started At</th>
                        <th>Completed At</th>
                        <th>Remarks</th>
                        <th>Actions</th>

                    </tr>

                    </thead>

                    <tbody>

                    <% if (dispatches == null
                            || dispatches.isEmpty()) { %>

                        <tr>

                            <td colspan="9"
                                class="empty">

                                No dispatch records found.

                            </td>

                        </tr>

                    <% } else {

                        for (Dispatch dispatch : dispatches) {

                            String statusClass =
                                    "assigned";

                            if ("DISPATCHED".equalsIgnoreCase(
                                    dispatch.getDispatchStatus())) {

                                statusClass = "dispatched";

                            } else if ("IN_PROGRESS".equalsIgnoreCase(
                                    dispatch.getDispatchStatus())) {

                                statusClass = "in-progress";

                            } else if ("COMPLETED".equalsIgnoreCase(
                                    dispatch.getDispatchStatus())) {

                                statusClass = "completed";

                            } else if ("CANCELLED".equalsIgnoreCase(
                                    dispatch.getDispatchStatus())) {

                                statusClass = "cancelled";
                            }
                    %>

                        <tr>

                            <td>
                                <%= dispatch.getId() %>
                            </td>

                            <td>
                                Schedule #<%= dispatch.getScheduleId() %>
                            </td>

                            <td>

                                <%
                                    String employeeDisplay =
                                            "Employee #" +
                                            dispatch.getEmployeeId();

                                    if (employees != null) {

                                        for (Employee employee
                                                : employees) {

                                            if (employee.getId()
                                                    .equals(
                                                        dispatch.getEmployeeId()
                                                    )) {

                                                employeeDisplay =
                                                        employee.getEmployeeCode()
                                                        + " - "
                                                        + employee.getName();

                                                break;
                                            }
                                        }
                                    }
                                %>

                                <%= employeeDisplay %>

                            </td>

                            <td>

                                <span class="badge <%= statusClass %>">

                                    <%= dispatch.getDispatchStatus() %>

                                </span>

                            </td>

                            <td>
                                <%= dispatch.getDispatchedAt() != null
                                        ? dispatch.getDispatchedAt()
                                        : "-" %>
                            </td>

                            <td>
                                <%= dispatch.getStartedAt() != null
                                        ? dispatch.getStartedAt()
                                        : "-" %>
                            </td>

                            <td>
                                <%= dispatch.getCompletedAt() != null
                                        ? dispatch.getCompletedAt()
                                        : "-" %>
                            </td>

                            <td>
                                <%= dispatch.getRemarks() != null
                                        ? dispatch.getRemarks()
                                        : "-" %>
                            </td>

                            <td>

                                <div class="actions">

                                    <a class="btn btn-edit"
                                       href="<%= contextPath %>/dispatch-management?editId=<%= dispatch.getId() %>">

                                        Edit

                                    </a>

                                    <% if (!"DISPATCHED".equalsIgnoreCase(
                                            dispatch.getDispatchStatus())
                                            && !"COMPLETED".equalsIgnoreCase(
                                            dispatch.getDispatchStatus())
                                            && !"CANCELLED".equalsIgnoreCase(
                                            dispatch.getDispatchStatus())) { %>

                                        <form method="post"
                                              action="<%= contextPath %>/dispatch-management"
                                              style="display:inline;">

                                            <input type="hidden"
                                                   name="action"
                                                   value="status">

                                            <input type="hidden"
                                                   name="id"
                                                   value="<%= dispatch.getId() %>">

                                            <input type="hidden"
                                                   name="status"
                                                   value="DISPATCHED">

                                            <button class="btn btn-warning"
                                                    type="submit">

                                                Dispatch

                                            </button>

                                        </form>

                                    <% } %>

                                    <% if ("DISPATCHED".equalsIgnoreCase(
                                            dispatch.getDispatchStatus())
                                            || "ASSIGNED".equalsIgnoreCase(
                                            dispatch.getDispatchStatus())) { %>

                                        <form method="post"
                                              action="<%= contextPath %>/dispatch-management"
                                              style="display:inline;">

                                            <input type="hidden"
                                                   name="action"
                                                   value="status">

                                            <input type="hidden"
                                                   name="id"
                                                   value="<%= dispatch.getId() %>">

                                            <input type="hidden"
                                                   name="status"
                                                   value="IN_PROGRESS">

                                            <button class="btn btn-warning"
                                                    type="submit">

                                                Start

                                            </button>

                                        </form>

                                    <% } %>

                                    <% if (!"COMPLETED".equalsIgnoreCase(
                                            dispatch.getDispatchStatus())
                                            && !"CANCELLED".equalsIgnoreCase(
                                            dispatch.getDispatchStatus())) { %>

                                        <form method="post"
                                              action="<%= contextPath %>/dispatch-management"
                                              style="display:inline;">

                                            <input type="hidden"
                                                   name="action"
                                                   value="status">

                                            <input type="hidden"
                                                   name="id"
                                                   value="<%= dispatch.getId() %>">

                                            <input type="hidden"
                                                   name="status"
                                                   value="COMPLETED">

                                            <button class="btn btn-success"
                                                    type="submit">

                                                Complete

                                            </button>

                                        </form>

                                        <form method="post"
                                              action="<%= contextPath %>/dispatch-management"
                                              style="display:inline;">

                                            <input type="hidden"
                                                   name="action"
                                                   value="status">

                                            <input type="hidden"
                                                   name="id"
                                                   value="<%= dispatch.getId() %>">

                                            <input type="hidden"
                                                   name="status"
                                                   value="CANCELLED">

                                            <button class="btn btn-danger"
                                                    type="submit">

                                                Cancel

                                            </button>

                                        </form>

                                    <% } %>

                                    <form method="post"
                                          action="<%= contextPath %>/dispatch-management"
                                          style="display:inline;"
                                          onsubmit="return confirm('Delete this dispatch?');">

                                        <input type="hidden"
                                               name="action"
                                               value="delete">

                                        <input type="hidden"
                                               name="id"
                                               value="<%= dispatch.getId() %>">

                                        <button class="btn btn-danger"
                                                type="submit">

                                            Delete

                                        </button>

                                    </form>

                                </div>

                            </td>

                        </tr>

                    <%  }
                       } %>

                    </tbody>

                </table>

            </div>

        </div>

    </div>

</main>

</body>
</html>