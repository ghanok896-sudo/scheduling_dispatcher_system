<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.schedulingdispatch.model.User" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%
    User user = (User) request.getAttribute("user");

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String contextPath = request.getContextPath();

    LocalDate today = LocalDate.now();
    DateTimeFormatter dateFormatter =
            DateTimeFormatter.ofPattern("EEEE, dd MMM yyyy");

    String currentDate = today.format(dateFormatter);

    String role = user.getRole() == null ? "" : user.getRole();

    String fullName = user.getFullName() == null
            ? user.getUsername()
            : user.getFullName();

    String firstLetter =
            fullName == null || fullName.isEmpty()
                    ? "U"
                    : fullName.substring(0, 1).toUpperCase();
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Dashboard - Scheduling and Dispatching System</title>

    <style>

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: "Segoe UI", Arial, sans-serif;
            background: #f3f7fc;
            color: #14213d;
            min-height: 100vh;
        }

        .top-header {
            height: 84px;
            background: linear-gradient(
                110deg,
                #0969d8 0%,
                #1285e8 48%,
                #4858ed 100%
            );
            color: white;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 28px;
            box-shadow: 0 3px 12px rgba(0,0,0,.12);
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 1000;
        }

        .brand-section {
            display: flex;
            align-items: center;
            gap: 18px;
        }

        .brand-icon {
            width: 58px;
            height: 58px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 35px;
        }

        .brand-title {
            font-size: 29px;
            font-weight: 700;
            letter-spacing: -.5px;
        }

        .header-right {
            display: flex;
            align-items: center;
            gap: 25px;
        }

        .notification {
            position: relative;
            width: 44px;
            height: 44px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 27px;
            cursor: pointer;
        }

        .notification-count {
            position: absolute;
            top: -2px;
            right: -1px;
            background: #ff4b4b;
            width: 23px;
            height: 23px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 700;
            border: 2px solid white;
        }

        .profile-menu {
            display: flex;
            align-items: center;
            gap: 12px;
            cursor: pointer;
        }

        .profile-avatar {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background: #e7edf5;
            color: #63748a;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            font-weight: 700;
            border: 2px solid rgba(255,255,255,.75);
        }

        .profile-details {
            display: flex;
            flex-direction: column;
            gap: 2px;
        }

        .profile-name {
            font-size: 14px;
            font-weight: 600;
        }

        .profile-role {
            font-size: 13px;
            opacity: .85;
        }

        .profile-arrow {
            font-size: 18px;
            margin-left: 7px;
        }

        .sidebar {
            position: fixed;
            top: 84px;
            left: 0;
            bottom: 0;
            width: 286px;
            background: linear-gradient(
                180deg,
                #18283c 0%,
                #152337 55%,
                #101d2e 100%
            );
            color: white;
            padding: 30px 10px 20px;
            z-index: 900;
            display: flex;
            flex-direction: column;
        }

        .sidebar-menu {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 7px;
        }

        .sidebar-menu li {
            width: 100%;
        }

        .sidebar-link {
            min-height: 55px;
            padding: 0 18px;
            display: flex;
            align-items: center;
            gap: 17px;
            color: #eef4fb;
            text-decoration: none;
            border-radius: 8px;
            font-size: 16px;
            transition:
                background .2s ease,
                transform .2s ease;
        }

        .sidebar-link:hover {
            background: rgba(255,255,255,.09);
            transform: translateX(2px);
        }

        .sidebar-link.active {
            background: linear-gradient(
                90deg,
                #0d82ed,
                #0875dc
            );
            box-shadow:
                0 5px 12px rgba(0,118,235,.28);
        }

        .sidebar-icon {
            width: 27px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 23px;
        }

        .sidebar-text {
            line-height: 1.35;
        }

        .sidebar-spacer {
            flex: 1;
        }

        .sidebar-divider {
            height: 1px;
            background: rgba(255,255,255,.18);
            margin: 0 10px 14px;
        }

        .logout-link {
            min-height: 55px;
            padding: 0 18px;
            display: flex;
            align-items: center;
            gap: 17px;
            color: #f2f5f9;
            text-decoration: none;
            border-radius: 8px;
            font-size: 16px;
            transition: background .2s ease;
        }

        .logout-link:hover {
            background: rgba(255,255,255,.09);
        }

        .main-content {
            margin-left: 286px;
            padding: 112px 34px 40px;
            min-height: 100vh;
            background:
                radial-gradient(
                    circle at 90% 10%,
                    rgba(26,133,232,.07),
                    transparent 28%
                ),
                #f4f8fd;
        }

        .page-heading {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 20px;
            margin-bottom: 25px;
        }

        .page-title {
            font-size: 38px;
            line-height: 1.1;
            color: #132544;
            font-weight: 700;
        }

        .page-subtitle {
            margin-top: 7px;
            color: #5c6e89;
            font-size: 17px;
        }

        .date-box {
            min-width: 245px;
            padding: 13px 18px;
            border: 1px solid #c8e1fa;
            background: #eaf5ff;
            border-radius: 12px;
            display: flex;
            align-items: center;
            gap: 13px;
            color: #425a78;
        }

        .date-icon {
            font-size: 28px;
        }

        .date-text {
            font-size: 14px;
            font-weight: 600;
            line-height: 1.5;
        }

        .profile-card {
            background: rgba(255,255,255,.92);
            border: 1px solid #e2edf8;
            border-radius: 14px;
            min-height: 123px;
            padding: 18px 24px;
            display: flex;
            align-items: center;
            box-shadow: 0 7px 25px rgba(30,80,130,.07);
            margin-bottom: 28px;
        }

        .welcome-avatar {
            width: 88px;
            height: 88px;
            flex-shrink: 0;
            border-radius: 50%;
            background: linear-gradient(
                145deg,
                #1686ed,
                #1165d5
            );
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 34px;
            font-weight: 700;
            box-shadow:
                0 7px 17px rgba(18,115,224,.25);
        }

        .welcome-section {
            padding-left: 28px;
            min-width: 330px;
            flex: 1;
        }

        .welcome-title {
            font-size: 23px;
            color: #102247;
            margin-bottom: 5px;
        }

        .welcome-description {
            font-size: 14px;
            color: #526785;
        }

        .profile-info {
            display: flex;
            align-items: stretch;
        }

        .info-item {
            min-width: 135px;
            padding: 0 24px;
            border-left: 1px solid #dce7f2;
            display: flex;
            flex-direction: column;
            justify-content: center;
            gap: 4px;
        }

        .info-icon {
            color: #0878e5;
            font-size: 22px;
            margin-bottom: 2px;
        }

        .info-label {
            color: #64748b;
            font-size: 13px;
        }

        .info-value {
            color: #142544;
            font-size: 15px;
            font-weight: 700;
            word-break: break-word;
        }

        .status-value {
            color: #159447;
        }

        .status-dot {
            width: 11px;
            height: 11px;
            display: inline-block;
            border-radius: 50%;
            background: #16b763;
            margin-right: 5px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns:
                repeat(6, minmax(150px, 1fr));
            gap: 20px;
            margin-bottom: 29px;
        }

        .stat-card {
            min-height: 151px;
            border-radius: 13px;
            padding: 21px 22px;
            position: relative;
            overflow: hidden;
            border: 1px solid transparent;
            transition:
                transform .2s ease,
                box-shadow .2s ease;
        }

        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow:
                0 10px 25px rgba(30,70,120,.10);
        }

        .stat-blue {
            background: #eaf5ff;
            border-color: #d3e9fc;
        }

        .stat-green {
            background: #eafaf3;
            border-color: #d2f0e0;
        }

        .stat-yellow {
            background: #fff8df;
            border-color: #f8e9b7;
        }

        .stat-orange {
            background: #fff1e4;
            border-color: #f9dec4;
        }

        .stat-purple {
            background: #f5edff;
            border-color: #e8d9fb;
        }

        .stat-completed {
            background: #e9faf3;
            border-color: #d4f0e2;
        }

        .stat-icon {
            font-size: 29px;
            margin-bottom: 14px;
        }

        .stat-blue .stat-icon {
            color: #087ce7;
        }

        .stat-green .stat-icon {
            color: #13a15b;
        }

        .stat-yellow .stat-icon {
            color: #d99a00;
        }

        .stat-orange .stat-icon {
            color: #ed790f;
        }

        .stat-purple .stat-icon {
            color: #7140cf;
        }

        .stat-completed .stat-icon {
            color: #13a862;
        }

        .stat-number {
            font-size: 25px;
            font-weight: 700;
            color: #102347;
            margin-bottom: 5px;
        }

        .stat-label {
            font-size: 14px;
            color: #132544;
            font-weight: 600;
        }

        .stat-background-icon {
            position: absolute;
            right: 12px;
            top: 28px;
            font-size: 62px;
            opacity: .08;
        }

        .section-heading {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 18px;
        }

        .section-title {
            display: flex;
            align-items: center;
            gap: 13px;
            font-size: 25px;
            color: #102448;
        }

        .section-title-icon {
            color: #087be6;
            font-size: 29px;
        }

        .section-description {
            padding: 9px 15px;
            background: #e8f4ff;
            color: #0872d5;
            border-radius: 7px;
            font-size: 13px;
        }

        .modules-grid {
            display: grid;
            grid-template-columns:
                repeat(4, minmax(220px, 1fr));
            gap: 18px;
        }

        .module-card {
            min-height: 116px;
            background: white;
            border: 1px solid #e5edf6;
            border-radius: 12px;
            padding: 18px 16px;
            display: flex;
            align-items: center;
            gap: 17px;
            text-decoration: none;
            color: inherit;
            box-shadow:
                0 5px 18px rgba(30,70,110,.05);
            transition:
                transform .2s ease,
                box-shadow .2s ease,
                border-color .2s ease;
        }

        .module-card:hover {
            transform: translateY(-3px);
            border-color: #cfe3f7;
            box-shadow:
                0 10px 25px rgba(30,70,120,.10);
        }

        .module-icon {
            width: 64px;
            height: 64px;
            flex-shrink: 0;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 28px;
        }

        .module-blue {
            background: #087be6;
        }

        .module-green {
            background: #20ba69;
        }

        .module-orange {
            background: #ff861f;
        }

        .module-yellow {
            background: #d99a00;
        }

        .module-purple {
            background: #7240d6;
        }

        .module-red {
            background: #f24737;
        }

        .module-cyan {
            background: #0db6b0;
        }

        .module-gray {
            background: #66798f;
        }

        .module-content {
            flex: 1;
        }

        .module-title {
            color: #142544;
            font-size: 16px;
            font-weight: 700;
            margin-bottom: 6px;
            line-height: 1.2;
        }

        .module-description {
            color: #61728b;
            font-size: 14px;
            line-height: 1.4;
        }

        .module-arrow {
            color: #087be6;
            font-size: 28px;
            flex-shrink: 0;
        }

        .dashboard-footer {
            margin-top: 35px;
            text-align: center;
            color: #7a8ba1;
            font-size: 13px;
            padding-bottom: 10px;
        }

        @media(max-width:1400px) {

            .stats-grid {
                grid-template-columns:
                    repeat(3, minmax(170px, 1fr));
            }

            .modules-grid {
                grid-template-columns:
                    repeat(2, minmax(250px, 1fr));
            }

            .profile-info {
                flex-wrap: wrap;
            }

            .info-item {
                min-width: 145px;
            }
        }

        @media(max-width:1050px) {

            .sidebar {
                width: 225px;
            }

            .main-content {
                margin-left: 225px;
            }

            .brand-title {
                font-size: 23px;
            }

            .profile-card {
                flex-wrap: wrap;
                gap: 20px;
            }

            .welcome-section {
                min-width: 250px;
            }

            .profile-info {
                width: 100%;
            }

            .info-item:first-child {
                border-left: none;
                padding-left: 0;
            }
        }

        @media(max-width:760px) {

            .top-header {
                height: 70px;
                padding: 0 15px;
            }

            .brand-icon {
                font-size: 27px;
            }

            .brand-title {
                font-size: 18px;
            }

            .profile-details,
            .profile-arrow {
                display: none;
            }

            .sidebar {
                top: 70px;
                width: 68px;
                padding: 18px 7px;
            }

            .sidebar-link,
            .logout-link {
                justify-content: center;
                padding: 0;
            }

            .sidebar-text {
                display: none;
            }

            .sidebar-icon {
                font-size: 22px;
            }

            .sidebar-divider {
                margin-left: 3px;
                margin-right: 3px;
            }

            .main-content {
                margin-left: 68px;
                padding: 92px 17px 30px;
            }

            .page-heading {
                flex-direction: column;
            }

            .page-title {
                font-size: 30px;
            }

            .date-box {
                width: 100%;
            }

            .stats-grid {
                grid-template-columns:
                    repeat(2, minmax(130px, 1fr));
                gap: 12px;
            }

            .modules-grid {
                grid-template-columns: 1fr;
            }

            .profile-card {
                padding: 20px;
            }

            .welcome-section {
                padding-left: 0;
                min-width: 100%;
            }

            .profile-info {
                display: grid;
                grid-template-columns: repeat(2, 1fr);
                gap: 15px;
            }

            .info-item {
                border-left: none;
                padding: 0;
            }

            .section-heading {
                align-items: flex-start;
                flex-direction: column;
                gap: 10px;
            }
        }

        @media(max-width:480px) {

            .header-right {
                gap: 10px;
            }

            .notification {
                display: none;
            }

            .stats-grid {
                grid-template-columns: 1fr;
            }

            .profile-info {
                grid-template-columns: 1fr;
            }

            .brand-title {
                font-size: 16px;
            }

            .main-content {
                padding-left: 12px;
                padding-right: 12px;
            }
        }

    </style>

</head>

<body>

<header class="top-header">

    <div class="brand-section">

        <div class="brand-icon">📅</div>

        <div class="brand-title">
            Scheduling and Dispatching System
        </div>

    </div>

    <div class="header-right">

        <a href="<%= contextPath %>/notification-management"
           class="notification"
           title="Notifications"
           style="text-decoration:none;color:inherit;">

            🔔

            <span class="notification-count">
                3
            </span>

        </a>

        <div class="profile-menu">

            <div class="profile-avatar">
                <%= firstLetter %>
            </div>

            <div class="profile-details">

                <span class="profile-name">
                    <%= fullName %>
                </span>

                <span class="profile-role">
                    <%= role %>
                </span>

            </div>

            <span class="profile-arrow">▾</span>

        </div>

    </div>

</header>


<aside class="sidebar">

    <ul class="sidebar-menu">

        <li>
            <a href="<%= contextPath %>/dashboard"
               class="sidebar-link active">

                <span class="sidebar-icon">🏠</span>

                <span class="sidebar-text">
                    Dashboard
                </span>

            </a>
        </li>


        <li>
            <a href="<%= contextPath %>/user-management"
               class="sidebar-link">

                <span class="sidebar-icon">👥</span>

                <span class="sidebar-text">
                    User Management
                </span>

            </a>
        </li>


        <li>
            <a href="<%= contextPath %>/customer-management"
               class="sidebar-link">

                <span class="sidebar-icon">👨‍👩‍👧</span>

                <span class="sidebar-text">
                    Customer Management
                </span>

            </a>
        </li>


        <li>
            <a href="<%= contextPath %>/employee-management"
               class="sidebar-link">

                <span class="sidebar-icon">👨‍🔧</span>

                <span class="sidebar-text">
                    Employee / Resource
                </span>

            </a>
        </li>


        <li>
            <a href="<%= contextPath %>/task-management"
               class="sidebar-link">

                <span class="sidebar-icon">📋</span>

                <span class="sidebar-text">
                    Task Management
                </span>

            </a>
        </li>


        <li>
            <a href="<%= contextPath %>/schedule-management"
               class="sidebar-link">

                <span class="sidebar-icon">📅</span>

                <span class="sidebar-text">
                    Scheduling
                </span>

            </a>
        </li>


        <li>
            <a href="<%= contextPath %>/dispatch-management"
               class="sidebar-link">

                <span class="sidebar-icon">🚚</span>

                <span class="sidebar-text">
                    Dispatching
                </span>

            </a>
        </li>


        <li>
            <a href="<%= contextPath %>/notification-management"
               class="sidebar-link">

                <span class="sidebar-icon">🔔</span>

                <span class="sidebar-text">
                    Notifications
                </span>

            </a>
        </li>


        <li>
            <a href="<%= contextPath %>/reports"
               class="sidebar-link">

                <span class="sidebar-icon">📊</span>

                <span class="sidebar-text">
                    Reports
                </span>

            </a>
        </li>


        <li>
            <a href="<%= contextPath %>/system-configuration"
               class="sidebar-link">

                <span class="sidebar-icon">⚙️</span>

                <span class="sidebar-text">
                    System Configuration
                </span>

            </a>
        </li>


        <!-- NEW: Audit History -->

        <li>
            <a href="<%= contextPath %>/audit-history"
               class="sidebar-link">

                <span class="sidebar-icon">📝</span>

                <span class="sidebar-text">
                    Audit History
                </span>

            </a>
        </li>


        <!-- NEW: Calendar Events -->

        <li>
            <a href="<%= contextPath %>/calendar-events"
               class="sidebar-link">

                <span class="sidebar-icon">🗓️</span>

                <span class="sidebar-text">
                    Calendar Events
                </span>

            </a>
        </li>

    </ul>


    <div class="sidebar-spacer"></div>

    <div class="sidebar-divider"></div>


    <a href="<%= contextPath %>/logout"
       class="logout-link">

        <span class="sidebar-icon">🚪</span>

        <span class="sidebar-text">
            Logout
        </span>

    </a>

</aside>


<main class="main-content">


    <div class="page-heading">

        <div>

            <h1 class="page-title">
                Dashboard
            </h1>

            <p class="page-subtitle">
                Welcome to Scheduling and Dispatching System.
                Here is your system overview.
            </p>

        </div>


        <div class="date-box">

            <div class="date-icon">
                📅
            </div>

            <div class="date-text">

                <%= currentDate %>

                <br>

                <%= java.time.LocalTime.now()
                        .format(
                                java.time.format.DateTimeFormatter
                                        .ofPattern("hh:mm a")
                        )
                %>

            </div>

        </div>

    </div>


    <section class="profile-card">


        <div class="welcome-avatar">
            <%= firstLetter %>
        </div>


        <div class="welcome-section">

            <h2 class="welcome-title">
                Welcome, <%= fullName %>
            </h2>

            <p class="welcome-description">
                You are logged in to the Scheduling and Dispatching System.
            </p>

        </div>


        <div class="profile-info">


            <div class="info-item">

                <div class="info-icon">
                    👤
                </div>

                <div class="info-label">
                    Username
                </div>

                <div class="info-value">
                    <%= user.getUsername() %>
                </div>

            </div>


            <div class="info-item">

                <div class="info-icon">
                    🛡️
                </div>

                <div class="info-label">
                    Role
                </div>

                <div class="info-value">
                    <%= role %>
                </div>

            </div>


            <div class="info-item">

                <div class="info-icon">
                    ✉️
                </div>

                <div class="info-label">
                    Email
                </div>

                <div class="info-value">
                    <%= user.getEmail() %>
                </div>

            </div>


            <div class="info-item">

                <div class="info-icon">
                    ●
                </div>

                <div class="info-label">
                    Status
                </div>

                <div class="info-value status-value">

                    <span class="status-dot"></span>

                    <%= user.getStatus() %>

                </div>

            </div>


        </div>

    </section>


    <section class="stats-grid">


        <div class="stat-card stat-blue">

            <div class="stat-icon">
                📅
            </div>

            <div class="stat-number">
                0
            </div>

            <div class="stat-label">
                Total Schedules
            </div>

            <div class="stat-background-icon">
                📅
            </div>

        </div>


        <div class="stat-card stat-green">

            <div class="stat-icon">
                📅
            </div>

            <div class="stat-number">
                0
            </div>

            <div class="stat-label">
                Today's Schedules
            </div>

            <div class="stat-background-icon">
                📅
            </div>

        </div>


        <div class="stat-card stat-yellow">

            <div class="stat-icon">
                📋
            </div>

            <div class="stat-number">
                0
            </div>

            <div class="stat-label">
                Pending Tasks
            </div>

            <div class="stat-background-icon">
                📋
            </div>

        </div>


        <div class="stat-card stat-orange">

            <div class="stat-icon">
                👨‍🔧
            </div>

            <div class="stat-number">
                0
            </div>

            <div class="stat-label">
                Assigned Tasks
            </div>

            <div class="stat-background-icon">
                👨‍🔧
            </div>

        </div>


        <div class="stat-card stat-purple">

            <div class="stat-icon">
                ⚙️
            </div>

            <div class="stat-number">
                0
            </div>

            <div class="stat-label">
                In Progress
            </div>

            <div class="stat-background-icon">
                ⚙️
            </div>

        </div>


        <div class="stat-card stat-completed">

            <div class="stat-icon">
                ✓
            </div>

            <div class="stat-number">
                0
            </div>

            <div class="stat-label">
                Completed
            </div>

            <div class="stat-background-icon">
                ✓
            </div>

        </div>


    </section>


    <section>


        <div class="section-heading">

            <h2 class="section-title">

                <span class="section-title-icon">
                    ▦
                </span>

                Available Modules

            </h2>


            <div class="section-description">

                Quick access to all system modules based on your role.

            </div>

        </div>


        <div class="modules-grid">


            <a href="<%= contextPath %>/user-management"
               class="module-card">

                <div class="module-icon module-blue">
                    👥
                </div>

                <div class="module-content">

                    <div class="module-title">
                        User Management
                    </div>

                    <div class="module-description">
                        Manage system users, roles and permissions.
                    </div>

                </div>

                <div class="module-arrow">
                    ›
                </div>

            </a>


            <a href="<%= contextPath %>/customer-management"
               class="module-card">

                <div class="module-icon module-green">
                    👥
                </div>

                <div class="module-content">

                    <div class="module-title">
                        Customer Management
                    </div>

                    <div class="module-description">
                        Manage customers and service history.
                    </div>

                </div>

                <div class="module-arrow">
                    ›
                </div>

            </a>


            <a href="<%= contextPath %>/employee-management"
               class="module-card">

                <div class="module-icon module-orange">
                    👨‍🔧
                </div>

                <div class="module-content">

                    <div class="module-title">
                        Employee / Resource Management
                    </div>

                    <div class="module-description">
                        Manage employees, technicians and resources.
                    </div>

                </div>

                <div class="module-arrow">
                    ›
                </div>

            </a>


            <a href="<%= contextPath %>/task-management"
               class="module-card">

                <div class="module-icon module-yellow">
                    📋
                </div>

                <div class="module-content">

                    <div class="module-title">
                        Task Management
                    </div>

                    <div class="module-description">
                        Create, update and manage customer tasks.
                    </div>

                </div>

                <div class="module-arrow">
                    ›
                </div>

            </a>


            <a href="<%= contextPath %>/schedule-management"
               class="module-card">

                <div class="module-icon module-purple">
                    📅
                </div>

                <div class="module-content">

                    <div class="module-title">
                        Scheduling
                    </div>

                    <div class="module-description">
                        Create and manage customer schedules.
                    </div>

                </div>

                <div class="module-arrow">
                    ›
                </div>

            </a>


            <a href="<%= contextPath %>/dispatch-management"
               class="module-card">

                <div class="module-icon module-red">
                    🚚
                </div>

                <div class="module-content">

                    <div class="module-title">
                        Dispatching
                    </div>

                    <div class="module-description">
                        Assign and track dispatch activities.
                    </div>

                </div>

                <div class="module-arrow">
                    ›
                </div>

            </a>


            <a href="<%= contextPath %>/notification-management"
               class="module-card">

                <div class="module-icon module-yellow">
                    🔔
                </div>

                <div class="module-content">

                    <div class="module-title">
                        Notifications
                    </div>

                    <div class="module-description">
                        View and manage system notifications.
                    </div>

                </div>

                <div class="module-arrow">
                    ›
                </div>

            </a>


            <a href="<%= contextPath %>/reports"
               class="module-card">

                <div class="module-icon module-cyan">
                    📊
                </div>

                <div class="module-content">

                    <div class="module-title">
                        Reports
                    </div>

                    <div class="module-description">
                        View reports and system analytics.
                    </div>

                </div>

                <div class="module-arrow">
                    ›
                </div>

            </a>


            <a href="<%= contextPath %>/system-configuration"
               class="module-card">

                <div class="module-icon module-gray">
                    ⚙️
                </div>

                <div class="module-content">

                    <div class="module-title">
                        System Configuration
                    </div>

                    <div class="module-description">
                        Manage system settings and configurations.
                    </div>

                </div>

                <div class="module-arrow">
                    ›
                </div>

            </a>


            <!-- NEW: Audit History Module -->

            <a href="<%= contextPath %>/audit-history"
               class="module-card">

                <div class="module-icon module-blue">
                    📝
                </div>

                <div class="module-content">

                    <div class="module-title">
                        Audit History
                    </div>

                    <div class="module-description">
                        View schedule status changes and audit logs.
                    </div>

                </div>

                <div class="module-arrow">
                    ›
                </div>

            </a>


            <!-- NEW: Calendar Events Module -->

            <a href="<%= contextPath %>/calendar-events"
               class="module-card">

                <div class="module-icon module-cyan">
                    🗓️
                </div>

                <div class="module-content">

                    <div class="module-title">
                        Calendar Events
                    </div>

                    <div class="module-description">
                        View and manage scheduled calendar events.
                    </div>

                </div>

                <div class="module-arrow">
                    ›
                </div>

            </a>


        </div>

    </section>


    <div class="dashboard-footer">

        Scheduling and Dispatching System
        &nbsp; | &nbsp;
        Dashboard

    </div>


</main>


</body>

</html>