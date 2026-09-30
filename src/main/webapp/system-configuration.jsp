<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.schedulingdispatch.model.User" %>
<%@ page import="jakarta.servlet.http.HttpServletResponse" %>

<%
    User user =
            (User) session.getAttribute("loggedInUser");

    if (user == null) {
        response.sendRedirect(
                request.getContextPath() + "/login"
        );
        return;
    }

    if (!"ADMIN".equalsIgnoreCase(user.getRole())) {
        response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Access denied. Administrator access is required."
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
            fullName == null || fullName.isEmpty()
                    ? "A"
                    : fullName.substring(0, 1).toUpperCase();

    String role =
            user.getRole() == null
                    ? ""
                    : user.getRole();
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        System Configuration - Scheduling & Dispatching System
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

        .configuration-grid {
            display: grid;

            grid-template-columns:
                    repeat(2, minmax(300px, 1fr));

            gap: 15px;
        }

        .configuration-card {
            background: white;

            border: 1px solid #dce5ef;

            border-radius: 7px;

            overflow: hidden;

            box-shadow:
                    0 3px 10px
                    rgba(40, 80, 120, 0.05);
        }

        .configuration-header {
            padding: 13px 15px;

            border-bottom: 1px solid #e3eaf2;

            background: #fbfdff;
        }

        .configuration-title {
            font-size: 13px;

            font-weight: 700;

            color: #173252;
        }

        .configuration-description {
            margin-top: 3px;

            font-size: 9px;

            color: #778aa2;
        }

        .configuration-body {
            padding: 14px 15px;
        }

        .configuration-row {
            display: flex;

            justify-content: space-between;

            align-items: center;

            gap: 15px;

            padding: 10px 0;

            border-bottom: 1px solid #edf1f5;
        }

        .configuration-row:last-child {
            border-bottom: none;
        }

        .configuration-label {
            color: #596f89;

            font-size: 10px;

            font-weight: 600;
        }

        .configuration-value {
            color: #172b46;

            font-size: 10px;

            font-weight: 600;

            text-align: right;
        }

        .status-badge {
            display: inline-block;

            padding: 4px 9px;

            border-radius: 10px;

            font-size: 8px;

            font-weight: 700;
        }

        .status-active {
            background: #dff8e9;

            color: #08773c;
        }

        .status-info {
            background: #e2efff;

            color: #1262bb;
        }

        .module-links {
            display: grid;

            grid-template-columns:
                    repeat(2, 1fr);

            gap: 9px;
        }

        .module-link {
            display: block;

            text-decoration: none;

            background: #f6f9fc;

            border: 1px solid #dce5ef;

            border-radius: 5px;

            padding: 10px;

            color: #24415f;

            font-size: 10px;

            font-weight: 600;

            transition: 0.2s;
        }

        .module-link:hover {
            background: #eaf2fb;

            border-color: #b9cce0;
        }

        .module-link small {
            display: block;

            margin-top: 4px;

            color: #7a8da5;

            font-size: 8px;

            font-weight: 400;
        }

        .notice {
            margin-top: 15px;

            padding: 12px 14px;

            background: #eef6ff;

            border: 1px solid #c7def6;

            border-radius: 6px;

            color: #315b82;

            font-size: 10px;

            line-height: 1.5;
        }

        .footer {
            text-align: center;

            color: #7d8da2;

            font-size: 9px;

            margin-top: 25px;
        }

        @media (max-width: 800px) {

            .sidebar {
                width: 90px;
            }

            .main-content {
                margin-left: 90px;
            }

            .configuration-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 550px) {

            .module-links {
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
       class="sidebar-link">

        Reports

    </a>

    <a href="<%= contextPath %>/system-configuration"
       class="sidebar-link active">

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
        System Configuration
    </h1>

    <p class="page-subtitle">
        View system information and configuration details.
    </p>


    <section class="configuration-grid">


        <div class="configuration-card">

            <div class="configuration-header">

                <div class="configuration-title">
                    Application Information
                </div>

                <div class="configuration-description">
                    Basic application details.
                </div>

            </div>

            <div class="configuration-body">

                <div class="configuration-row">

                    <span class="configuration-label">
                        Application Name
                    </span>

                    <span class="configuration-value">
                        Scheduling &amp; Dispatching System
                    </span>

                </div>

                <div class="configuration-row">

                    <span class="configuration-label">
                        Application Version
                    </span>

                    <span class="configuration-value">
                        1.0.0
                    </span>

                </div>

                <div class="configuration-row">

                    <span class="configuration-label">
                        Application Type
                    </span>

                    <span class="configuration-value">
                        Java Web Application
                    </span>

                </div>

                <div class="configuration-row">

                    <span class="configuration-label">
                        Current User
                    </span>

                    <span class="configuration-value">
                        <%= fullName %>
                    </span>

                </div>

                <div class="configuration-row">

                    <span class="configuration-label">
                        User Role
                    </span>

                    <span class="configuration-value">

                        <span class="status-badge status-active">
                            <%= role %>
                        </span>

                    </span>

                </div>

            </div>

        </div>


        <div class="configuration-card">

            <div class="configuration-header">

                <div class="configuration-title">
                    Technology Configuration
                </div>

                <div class="configuration-description">
                    Technologies used by the application.
                </div>

            </div>

            <div class="configuration-body">

                <div class="configuration-row">

                    <span class="configuration-label">
                        Programming Language
                    </span>

                    <span class="configuration-value">
                        Java 21
                    </span>

                </div>

                <div class="configuration-row">

                    <span class="configuration-label">
                        Web Technology
                    </span>

                    <span class="configuration-value">
                        JSP / Servlets
                    </span>

                </div>

                <div class="configuration-row">

                    <span class="configuration-label">
                        ORM
                    </span>

                    <span class="configuration-value">
                        Hibernate
                    </span>

                </div>

                <div class="configuration-row">

                    <span class="configuration-label">
                        Database
                    </span>

                    <span class="configuration-value">
                        MySQL
                    </span>

                </div>

                <div class="configuration-row">

                    <span class="configuration-label">
                        Server
                    </span>

                    <span class="configuration-value">
                        Apache Tomcat
                    </span>

                </div>

            </div>

        </div>


        <div class="configuration-card">

            <div class="configuration-header">

                <div class="configuration-title">
                    System Status
                </div>

                <div class="configuration-description">
                    Current application service status.
                </div>

            </div>

            <div class="configuration-body">

                <div class="configuration-row">

                    <span class="configuration-label">
                        Application Status
                    </span>

                    <span class="configuration-value">

                        <span class="status-badge status-active">
                            ACTIVE
                        </span>

                    </span>

                </div>

                <div class="configuration-row">

                    <span class="configuration-label">
                        Authentication
                    </span>

                    <span class="configuration-value">

                        <span class="status-badge status-active">
                            ENABLED
                        </span>

                    </span>

                </div>

                <div class="configuration-row">

                    <span class="configuration-label">
                        Admin Access
                    </span>

                    <span class="configuration-value">

                        <span class="status-badge status-active">
                            ENABLED
                        </span>

                    </span>

                </div>

                <div class="configuration-row">

                    <span class="configuration-label">
                        Database Access
                    </span>

                    <span class="configuration-value">

                        <span class="status-badge status-active">
                            CONFIGURED
                        </span>

                    </span>

                </div>

            </div>

        </div>


        <div class="configuration-card">

            <div class="configuration-header">

                <div class="configuration-title">
                    Module Configuration
                </div>

                <div class="configuration-description">
                    Navigate to the main system modules.
                </div>

            </div>

            <div class="configuration-body">

                <div class="module-links">

                    <a href="<%= contextPath %>/user-management"
                       class="module-link">

                        User Management

                        <small>
                            Manage system users and roles.
                        </small>

                    </a>

                    <a href="<%= contextPath %>/customer-management"
                       class="module-link">

                        Customer Management

                        <small>
                            Manage customer information.
                        </small>

                    </a>

                    <a href="<%= contextPath %>/employee-management"
                       class="module-link">

                        Employee Management

                        <small>
                            Manage employees and availability.
                        </small>

                    </a>

                    <a href="<%= contextPath %>/task-management"
                       class="module-link">

                        Task Management

                        <small>
                            Manage customer tasks.
                        </small>

                    </a>

                    <a href="<%= contextPath %>/schedule-management"
                       class="module-link">

                        Scheduling

                        <small>
                            Manage schedules and assignments.
                        </small>

                    </a>

                    <a href="<%= contextPath %>/dispatch-management"
                       class="module-link">

                        Dispatching

                        <small>
                            Manage dispatch assignments.
                        </small>

                    </a>

                    <a href="<%= contextPath %>/reports"
                       class="module-link">

                        Reports

                        <small>
                            View system statistics.
                        </small>

                    </a>

                    <a href="<%= contextPath %>/dashboard"
                       class="module-link">

                        Dashboard

                        <small>
                            Return to the admin dashboard.
                        </small>

                    </a>

                </div>

            </div>

        </div>

    </section>


    <div class="notice">

        <strong>System Configuration:</strong>

        This section currently provides system and application
        configuration information. Existing database tables and
        operational modules are not modified by this page.

    </div>


    <div class="footer">

        Scheduling and Dispatching System

        &nbsp; | &nbsp;

        System Configuration

    </div>

</main>

</body>

</html>