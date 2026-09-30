<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.schedulingdispatch.model.User" %>

<%
    String contextPath = request.getContextPath();

User loggedInUser =
(User) session.getAttribute("loggedInUser");

    if (loggedInUser == null) {
        response.sendRedirect(contextPath + "/login");
        return;
    }

    if (!"ADMIN".equalsIgnoreCase(
            loggedInUser.getRole())) {

        response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Access denied.");
        return;
    }

    List<User> users =
            (List<User>) request.getAttribute("users");

    String keyword =
            (String) request.getAttribute("keyword");

    User editUser =
            (User) request.getAttribute("editUser");

    String success =
            request.getParameter("success");

    String error =
            (String) request.getAttribute("error");

    if (error == null) {
        error = request.getParameter("error");
    }

    boolean editMode = editUser != null;
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>User Management - Scheduling and Dispatching System</title>

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

            background: #f4f8fd;
            color: #172642;
        }

        /* HEADER */

        .header {
            height: 84px;

            position: fixed;
            top: 0;
            left: 0;
            right: 0;

            z-index: 100;

            display: flex;
            align-items: center;
            justify-content: space-between;

            padding: 0 28px;

            color: white;

            background:
                linear-gradient(
                    110deg,
                    #0969d8,
                    #1285e8,
                    #4858ed
                );

            box-shadow:
                0 3px 12px rgba(0,0,0,.12);
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .brand-icon {
            font-size: 34px;
        }

        .brand-name {
            font-size: 27px;
            font-weight: 700;
        }

        .header-user {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .avatar {
            width: 44px;
            height: 44px;

            border-radius: 50%;

            background: white;
            color: #1878df;

            display: flex;
            align-items: center;
            justify-content: center;

            font-weight: 700;
        }

        .header-user-text {
            display: flex;
            flex-direction: column;
        }

        .header-user-name {
            font-weight: 600;
            font-size: 14px;
        }

        .header-user-role {
            font-size: 12px;
            opacity: .85;
        }

        /* SIDEBAR */

        .sidebar {
            position: fixed;

            top: 84px;
            bottom: 0;
            left: 0;

            width: 286px;

            background:
                linear-gradient(
                    180deg,
                    #18283c,
                    #101d2e
                );

            padding: 30px 10px;

            color: white;

            display: flex;
            flex-direction: column;
        }

        .menu {
            list-style: none;
        }

        .menu li {
            margin-bottom: 7px;
        }

        .menu a,
        .logout {
            min-height: 55px;

            display: flex;
            align-items: center;

            gap: 16px;

            padding: 0 18px;

            color: #edf3fa;
            text-decoration: none;

            border-radius: 8px;

            font-size: 15px;
        }

        .menu a:hover,
        .logout:hover {
            background: rgba(255,255,255,.09);
        }

        .menu a.active {
            background:
                linear-gradient(
                    90deg,
                    #0d82ed,
                    #0875dc
                );
        }

        .menu-icon {
            width: 27px;
            text-align: center;
            font-size: 22px;
        }

        .sidebar-spacer {
            flex: 1;
        }

        .divider {
            height: 1px;
            background: rgba(255,255,255,.18);
            margin: 0 10px 15px;
        }

        /* MAIN */

        .main {
            margin-left: 286px;

            padding:
                112px 34px 40px;

            min-height: 100vh;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;

            margin-bottom: 24px;
        }

        .page-title {
            font-size: 35px;
            color: #122546;
        }

        .page-subtitle {
            margin-top: 6px;
            color: #61728c;
        }

        .add-button {
            border: none;

            padding: 13px 21px;

            border-radius: 8px;

            background: #087be6;

            color: white;

            font-size: 14px;
            font-weight: 600;

            cursor: pointer;

            text-decoration: none;

            box-shadow:
                0 5px 13px rgba(8,123,230,.25);
        }

        .add-button:hover {
            background: #066bc9;
        }

        /* MESSAGE */

        .message {
            padding: 13px 17px;

            border-radius: 8px;

            margin-bottom: 18px;

            font-size: 14px;
        }

        .success {
            background: #e8f8ef;
            border: 1px solid #bde8cf;
            color: #16733d;
        }

        .error {
            background: #fff0f0;
            border: 1px solid #f2c4c4;
            color: #bd3030;
        }

        /* CONTENT GRID */

        .content-grid {
            display: grid;

            grid-template-columns:
                minmax(0, 1fr)
                370px;

            gap: 22px;

            align-items: start;
        }

        /* CARD */

        .card {
            background: white;

            border: 1px solid #e2ebf5;

            border-radius: 13px;

            box-shadow:
                0 6px 22px rgba(30,70,110,.06);

            overflow: hidden;
        }

        .card-header {
            padding: 18px 20px;

            border-bottom: 1px solid #e7eef6;

            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .card-title {
            font-size: 18px;
            font-weight: 700;
            color: #152744;
        }

        /* SEARCH */

        .search-area {
            padding: 16px 20px;

            background: #fbfdff;

            border-bottom: 1px solid #e7eef6;
        }

        .search-form {
            display: flex;
            gap: 9px;
        }

        .search-input {
            flex: 1;

            padding: 11px 13px;

            border: 1px solid #ccd9e8;

            border-radius: 7px;

            outline: none;

            font-size: 14px;
        }

        .search-input:focus {
            border-color: #1686ed;

            box-shadow:
                0 0 0 3px rgba(22,134,237,.10);
        }

        .search-button {
            border: none;

            padding: 0 19px;

            border-radius: 7px;

            background: #087be6;

            color: white;

            cursor: pointer;

            font-weight: 600;
        }

        .clear-button {
            display: flex;
            align-items: center;

            padding: 0 14px;

            border-radius: 7px;

            background: #edf3f9;

            color: #50627a;

            text-decoration: none;

            font-size: 13px;
        }

        /* TABLE */

        .table-wrapper {
            overflow-x: auto;
        }

        table {
            width: 100%;

            border-collapse: collapse;
        }

        th {
            background: #f6f9fd;

            color: #64748b;

            font-size: 12px;

            text-transform: uppercase;

            letter-spacing: .4px;

            padding: 13px 12px;

            text-align: left;

            white-space: nowrap;
        }

        td {
            padding: 14px 12px;

            border-top: 1px solid #edf2f7;

            font-size: 13px;

            color: #354866;

            vertical-align: middle;
        }

        tbody tr:hover {
            background: #f8fbff;
        }

        .user-name {
            font-weight: 600;
            color: #162744;
        }

        .role {
            display: inline-block;

            padding: 5px 9px;

            border-radius: 20px;

            background: #e9f3ff;

            color: #0872d5;

            font-size: 11px;

            font-weight: 700;
        }

        .status {
            display: inline-flex;
            align-items: center;

            gap: 5px;

            font-weight: 600;

            font-size: 11px;
        }

        .status-dot {
            width: 8px;
            height: 8px;

            border-radius: 50%;
        }

        .active {
            color: #159447;
        }

        .active .status-dot {
            background: #19b663;
        }

        .inactive {
            color: #a05a5a;
        }

        .inactive .status-dot {
            background: #d95353;
        }

        .actions {
            display: flex;
            gap: 5px;
            flex-wrap: wrap;
        }

        .action-button {
            border: none;

            padding: 6px 9px;

            border-radius: 5px;

            font-size: 11px;

            cursor: pointer;

            text-decoration: none;
        }

        .edit {
            background: #e9f3ff;
            color: #0872d5;
        }

        .activate {
            background: #e9f8ef;
            color: #168348;
        }

        .deactivate {
            background: #fff0e8;
            color: #c65d24;
        }

        /* FORM */

        .form-card {
            padding-bottom: 20px;
        }

        .form-body {
            padding: 20px;
        }

        .form-group {
            margin-bottom: 15px;
        }

        label {
            display: block;

            margin-bottom: 6px;

            color: #41536d;

            font-size: 13px;

            font-weight: 600;
        }

        input,
        select {
            width: 100%;

            padding: 10px 11px;

            border: 1px solid #cedae8;

            border-radius: 7px;

            outline: none;

            font-size: 13px;

            background: white;
        }

        input:focus,
        select:focus {
            border-color: #1686ed;

            box-shadow:
                0 0 0 3px rgba(22,134,237,.10);
        }

        .required {
            color: #e54848;
        }

        .form-note {
            color: #718198;

            font-size: 11px;

            margin-top: 5px;

            line-height: 1.4;
        }

        .form-buttons {
            display: flex;
            gap: 9px;
            margin-top: 20px;
        }

        .primary-button {
            flex: 1;

            border: none;

            padding: 11px;

            border-radius: 7px;

            background: #087be6;

            color: white;

            font-weight: 600;

            cursor: pointer;
        }

        .secondary-button {
            flex: 1;

            display: flex;
            justify-content: center;
            align-items: center;

            border-radius: 7px;

            background: #edf2f7;

            color: #52647b;

            text-decoration: none;

            font-size: 13px;
        }

        .empty {
            text-align: center;

            padding: 40px 20px;

            color: #73839a;
        }

        /* RESPONSIVE */

        @media (max-width: 1100px) {

            .sidebar {
                width: 220px;
            }

            .main {
                margin-left: 220px;
            }

            .content-grid {
                grid-template-columns: 1fr;
            }

            .brand-name {
                font-size: 22px;
            }
        }

        @media (max-width: 760px) {

            .header {
                height: 70px;
            }

            .brand-name {
                font-size: 17px;
            }

            .sidebar {
                top: 70px;
                width: 68px;
                padding: 18px 7px;
            }

            .menu a,
            .logout {
                justify-content: center;
                padding: 0;
            }

            .menu-text {
                display: none;
            }

            .main {
                margin-left: 68px;
                padding: 92px 15px 30px;
            }

            .page-header {
                align-items: flex-start;
                flex-direction: column;
                gap: 15px;
            }

            .header-user-text {
                display: none;
            }

            .page-title {
                font-size: 29px;
            }
        }

    </style>

</head>

<body>

<!-- HEADER -->

<header class="header">

    <div class="brand">

        <div class="brand-icon">
            📅
        </div>

        <div class="brand-name">
            Scheduling and Dispatching System
        </div>

    </div>

    <div class="header-user">

        <div class="avatar">
            <%= loggedInUser.getFullName()
                    .substring(0, 1)
                    .toUpperCase() %>
        </div>

        <div class="header-user-text">

            <span class="header-user-name">
                <%= loggedInUser.getFullName() %>
            </span>

            <span class="header-user-role">
                <%= loggedInUser.getRole() %>
            </span>

        </div>

    </div>

</header>


<!-- SIDEBAR -->

<aside class="sidebar">

    <ul class="menu">

        <li>
            <a href="<%= contextPath %>/dashboard">

                <span class="menu-icon">🏠</span>

                <span class="menu-text">
                    Dashboard
                </span>

            </a>
        </li>

        <li>
            <a href="<%= contextPath %>/user-management"
               class="active">

                <span class="menu-icon">👥</span>

                <span class="menu-text">
                    User Management
                </span>

            </a>
        </li>

        <li>
            <a href="#">

                <span class="menu-icon">👨‍👩‍👧</span>

                <span class="menu-text">
                    Customer Management
                </span>

            </a>
        </li>

        <li>
            <a href="#">

                <span class="menu-icon">👨‍🔧</span>

                <span class="menu-text">
                    Employee / Resource
                </span>

            </a>
        </li>

        <li>
            <a href="#">

                <span class="menu-icon">📅</span>

                <span class="menu-text">
                    Scheduling
                </span>

            </a>
        </li>

        <li>
            <a href="#">

                <span class="menu-icon">🚚</span>

                <span class="menu-text">
                    Dispatching
                </span>

            </a>
        </li>

        <li>
            <a href="#">

                <span class="menu-icon">📊</span>

                <span class="menu-text">
                    Reports
                </span>

            </a>
        </li>

        <li>
            <a href="#">

                <span class="menu-icon">⚙️</span>

                <span class="menu-text">
                    System Configuration
                </span>

            </a>
        </li>

    </ul>

    <div class="sidebar-spacer"></div>

    <div class="divider"></div>

    <a href="<%= contextPath %>/logout"
       class="logout">

        <span class="menu-icon">
            🚪
        </span>

        <span class="menu-text">
            Logout
        </span>

    </a>

</aside>


<!-- MAIN -->

<main class="main">

    <div class="page-header">

        <div>

            <h1 class="page-title">
                User Management
            </h1>

            <p class="page-subtitle">
                Manage system users, roles and account status.
            </p>

        </div>

        <a href="#user-form"
           class="add-button">

            + Add User

        </a>

    </div>


    <% if (success != null && !success.isEmpty()) { %>

        <div class="message success">
            ✓ <%= success %>
        </div>

    <% } %>


    <% if (error != null && !error.isEmpty()) { %>

        <div class="message error">
            ⚠ <%= error %>
        </div>

    <% } %>


    <div class="content-grid">


        <!-- USER LIST -->

        <section class="card">

            <div class="card-header">

                <div class="card-title">
                    System Users
                </div>

            </div>


            <div class="search-area">

                <form method="get"
                      action="<%= contextPath %>/user-management"
                      class="search-form">

                    <input
                        type="text"
                        name="keyword"
                        class="search-input"
                        placeholder="Search username, name, email, role or status..."
                        value="<%= keyword == null ? "" : keyword %>">

                    <button
                        type="submit"
                        class="search-button">

                        Search

                    </button>

                    <% if (keyword != null
                            && !keyword.trim().isEmpty()) { %>

                        <a href="<%= contextPath %>/user-management"
                           class="clear-button">

                            Clear

                        </a>

                    <% } %>

                </form>

            </div>


            <div class="table-wrapper">

                <table>

                    <thead>

                    <tr>

                        <th>ID</th>

                        <th>User</th>

                        <th>Email</th>

                        <th>Role</th>

                        <th>Status</th>

                        <th>Actions</th>

                    </tr>

                    </thead>

                    <tbody>

                    <% if (users == null
                            || users.isEmpty()) { %>

                        <tr>

                            <td colspan="6"
                                class="empty">

                                No users found.

                            </td>

                        </tr>

                    <% } else { %>

                        <% for (User user : users) { %>

                            <tr>

                                <td>
                                    <%= user.getId() %>
                                </td>

                                <td>

                                    <div class="user-name">
                                        <%= user.getFullName() %>
                                    </div>

                                    <div style="
                                        font-size:11px;
                                        color:#7a8aa0;
                                        margin-top:3px;">

                                        @<%= user.getUsername() %>

                                    </div>

                                </td>

                                <td>
                                    <%= user.getEmail() %>
                                </td>

                                <td>

                                    <span class="role">
                                        <%= user.getRole() %>
                                    </span>

                                </td>

                                <td>

                                    <% if ("ACTIVE".equalsIgnoreCase(
                                            user.getStatus())) { %>

                                        <span class="status active">

                                            <span class="status-dot"></span>

                                            ACTIVE

                                        </span>

                                    <% } else { %>

                                        <span class="status inactive">

                                            <span class="status-dot"></span>

                                            INACTIVE

                                        </span>

                                    <% } %>

                                </td>

                                <td>

                                    <div class="actions">

                                        <a
                                            href="<%= contextPath %>/user-management?editId=<%= user.getId() %>"
                                            class="action-button edit">

                                            Edit

                                        </a>


                                        <% if (user.getId().equals(
                                                loggedInUser.getId())) { %>

                                            <span
                                                class="action-button edit"
                                                title="You cannot deactivate your own account">

                                                Current

                                            </span>

                                        <% } else if ("ACTIVE".equalsIgnoreCase(
                                                user.getStatus())) { %>

                                            <form method="post"
                                                  action="<%= contextPath %>/user-management"
                                                  style="display:inline;">

                                                <input type="hidden"
                                                       name="action"
                                                       value="status">

                                                <input type="hidden"
                                                       name="id"
                                                       value="<%= user.getId() %>">

                                                <input type="hidden"
                                                       name="status"
                                                       value="INACTIVE">

                                                <button
                                                    type="submit"
                                                    class="action-button deactivate"
                                                    onclick="return confirm('Deactivate this user?');">

                                                    Deactivate

                                                </button>

                                            </form>

                                        <% } else { %>

                                            <form method="post"
                                                  action="<%= contextPath %>/user-management"
                                                  style="display:inline;">

                                                <input type="hidden"
                                                       name="action"
                                                       value="status">

                                                <input type="hidden"
                                                       name="id"
                                                       value="<%= user.getId() %>">

                                                <input type="hidden"
                                                       name="status"
                                                       value="ACTIVE">

                                                <button
                                                    type="submit"
                                                    class="action-button activate">

                                                    Activate

                                                </button>

                                            </form>

                                        <% } %>

                                    </div>

                                </td>

                            </tr>

                        <% } %>

                    <% } %>

                    </tbody>

                </table>

            </div>

        </section>


        <!-- ADD / EDIT -->

        <section class="card form-card"
                 id="user-form">

            <div class="card-header">

                <div class="card-title">

                    <%= editMode
                            ? "Edit User"
                            : "Add New User" %>

                </div>

            </div>


            <div class="form-body">

                <form method="post"
                      action="<%= contextPath %>/user-management">


                    <% if (editMode) { %>

                        <input type="hidden"
                               name="action"
                               value="update">

                        <input type="hidden"
                               name="id"
                               value="<%= editUser.getId() %>">

                    <% } else { %>

                        <input type="hidden"
                               name="action"
                               value="create">

                    <% } %>


                    <div class="form-group">

                        <label>
                            Username
                            <span class="required">*</span>
                        </label>

                        <input
                            type="text"
                            name="username"
                            maxlength="50"
                            required
                            value="<%= editMode
                                    ? editUser.getUsername()
                                    : "" %>">

                    </div>


                    <div class="form-group">

                        <label>
                            Full Name
                            <span class="required">*</span>
                        </label>

                        <input
                            type="text"
                            name="fullName"
                            maxlength="100"
                            required
                            value="<%= editMode
                                    ? editUser.getFullName()
                                    : "" %>">

                    </div>


                    <div class="form-group">

                        <label>
                            Email
                            <span class="required">*</span>
                        </label>

                        <input
                            type="email"
                            name="email"
                            maxlength="100"
                            required
                            value="<%= editMode
                                    ? editUser.getEmail()
                                    : "" %>">

                    </div>


                    <div class="form-group">

                        <label>
                            Phone
                        </label>

                        <input
                            type="text"
                            name="phone"
                            maxlength="20"
                            value="<%= editMode
                                    && editUser.getPhone() != null
                                    ? editUser.getPhone()
                                    : "" %>">

                    </div>


                    <div class="form-group">

                        <label>
                            <%= editMode
                                    ? "New Password"
                                    : "Password" %>

                            <% if (!editMode) { %>

                                <span class="required">*</span>

                            <% } %>

                        </label>

                        <input
                            type="password"
                            name="password"
                            minlength="6"
                            <%= editMode ? "" : "required" %>>

                        <% if (editMode) { %>

                            <div class="form-note">
                                Leave blank to keep the existing password.
                            </div>

                        <% } else { %>

                            <div class="form-note">
                                Minimum 6 characters.
                            </div>

                        <% } %>

                    </div>


                    <div class="form-group">

                        <label>
                            Role
                            <span class="required">*</span>
                        </label>

                        <select name="role"
                                required>

                            <option value="ADMIN"
                                <%= editMode
                                    && "ADMIN".equalsIgnoreCase(
                                        editUser.getRole())
                                    ? "selected"
                                    : "" %>>
                                ADMIN
                            </option>

                            <option value="MANAGER"
                                <%= editMode
                                    && "MANAGER".equalsIgnoreCase(
                                        editUser.getRole())
                                    ? "selected"
                                    : "" %>>
                                MANAGER
                            </option>

                            <option value="DISPATCHER"
                                <%= !editMode
                                    || "DISPATCHER".equalsIgnoreCase(
                                        editMode
                                            ? editUser.getRole()
                                            : "")
                                    ? ""
                                    : "" %>>
                                DISPATCHER
                            </option>

                            <option value="EMPLOYEE"
                                <%= (!editMode
                                    && true)
                                    || (editMode
                                    && "EMPLOYEE".equalsIgnoreCase(
                                        editUser.getRole()))
                                    ? "selected"
                                    : "" %>>
                                EMPLOYEE
                            </option>

                        </select>

                    </div>


                    <div class="form-group">

                        <label>
                            Status
                            <span class="required">*</span>
                        </label>

                        <select name="status"
                                required>

                            <option value="ACTIVE"
                                <%= !editMode
                                    || "ACTIVE".equalsIgnoreCase(
                                        editUser.getStatus())
                                    ? "selected"
                                    : "" %>>

                                ACTIVE

                            </option>

                            <option value="INACTIVE"
                                <%= editMode
                                    && "INACTIVE".equalsIgnoreCase(
                                        editUser.getStatus())
                                    ? "selected"
                                    : "" %>>

                                INACTIVE

                            </option>

                        </select>

                    </div>


                    <div class="form-buttons">

                        <button
                            type="submit"
                            class="primary-button">

                            <%= editMode
                                    ? "Update User"
                                    : "Create User" %>

                        </button>

                        <% if (editMode) { %>

                            <a
                                href="<%= contextPath %>/user-management"
                                class="secondary-button">

                                Cancel

                            </a>

                        <% } %>

                    </div>

                </form>

            </div>

        </section>

    </div>

</main>

</body>

</html>