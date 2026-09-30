<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.schedulingdispatch.model.Customer"%>

<%
    String contextPath = request.getContextPath();

    List<Customer> customers =
            (List<Customer>) request.getAttribute("customers");

    Customer editCustomer =
            (Customer) request.getAttribute("editCustomer");

    String keyword =
            (String) request.getAttribute("keyword");

    String success =
            request.getParameter("success");

    String error =
            (String) request.getAttribute("error");

    if (customers == null) {
        customers = List.of();
    }

    boolean editMode = editCustomer != null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Customer Management</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, Helvetica, sans-serif;
            background: #f4f6f9;
            color: #333;
        }

        .header {
            background: #1f2937;
            color: white;
            padding: 18px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header h1 {
            margin: 0;
            font-size: 24px;
        }

        .back-btn {
            text-decoration: none;
            color: white;
            background: #374151;
            padding: 9px 15px;
            border-radius: 5px;
        }

        .back-btn:hover {
            background: #4b5563;
        }

        .container {
            width: 95%;
            max-width: 1400px;
            margin: 25px auto;
        }

        .message {
            padding: 12px 15px;
            border-radius: 5px;
            margin-bottom: 18px;
        }

        .success {
            background: #d1fae5;
            color: #065f46;
            border: 1px solid #a7f3d0;
        }

        .error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }

        .card {
            background: white;
            border-radius: 8px;
            padding: 22px;
            margin-bottom: 25px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
        }

        .card h2 {
            margin-top: 0;
            margin-bottom: 20px;
            color: #1f2937;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 16px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group.full {
            grid-column: 1 / -1;
        }

        label {
            font-weight: bold;
            margin-bottom: 7px;
            color: #374151;
        }

        input,
        textarea,
        select {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #d1d5db;
            border-radius: 5px;
            font-size: 14px;
        }

        textarea {
            min-height: 90px;
            resize: vertical;
        }

        input:focus,
        textarea:focus,
        select:focus {
            outline: none;
            border-color: #2563eb;
        }

        .button-row {
            margin-top: 20px;
            display: flex;
            gap: 10px;
        }

        button,
        .btn {
            border: none;
            cursor: pointer;
            text-decoration: none;
            padding: 10px 16px;
            border-radius: 5px;
            font-size: 14px;
            display: inline-block;
        }

        .primary {
            background: #2563eb;
            color: white;
        }

        .primary:hover {
            background: #1d4ed8;
        }

        .secondary {
            background: #6b7280;
            color: white;
        }

        .secondary:hover {
            background: #4b5563;
        }

        .warning {
            background: #d97706;
            color: white;
        }

        .warning:hover {
            background: #b45309;
        }

        .search-row {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
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
            min-width: 1000px;
        }

        th {
            background: #1f2937;
            color: white;
            padding: 12px;
            text-align: left;
            white-space: nowrap;
        }

        td {
            padding: 11px 12px;
            border-bottom: 1px solid #e5e7eb;
            vertical-align: middle;
        }

        tr:hover {
            background: #f9fafb;
        }

        .status {
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
            display: inline-block;
        }

        .status-active {
            background: #d1fae5;
            color: #065f46;
        }

        .status-inactive {
            background: #fee2e2;
            color: #991b1b;
        }

        .action-form {
            display: inline;
        }

        .action-buttons {
            display: flex;
            gap: 6px;
            align-items: center;
        }

        .edit-btn {
            background: #2563eb;
            color: white;
        }

        .edit-btn:hover {
            background: #1d4ed8;
        }

        .activate-btn {
            background: #059669;
            color: white;
        }

        .activate-btn:hover {
            background: #047857;
        }

        .deactivate-btn {
            background: #dc2626;
            color: white;
        }

        .deactivate-btn:hover {
            background: #b91c1c;
        }

        .empty {
            text-align: center;
            padding: 30px;
            color: #6b7280;
        }

        @media (max-width: 768px) {

            .header {
                padding: 15px;
            }

            .header h1 {
                font-size: 20px;
            }

            .container {
                width: 95%;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }

            .form-group.full {
                grid-column: auto;
            }

            .search-row {
                flex-direction: column;
            }

            .button-row {
                flex-direction: column;
            }

            .button-row .btn,
            .button-row button {
                width: 100%;
            }
        }
    </style>
</head>

<body>

<div class="header">

    <h1>Customer Management</h1>

    <a href="<%= contextPath %>/dashboard"
       class="back-btn">
        Back to Dashboard
    </a>

</div>

<div class="container">

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


    <!-- Add / Edit Customer -->

    <div class="card">

        <h2>
            <%= editMode ? "Edit Customer" : "Add Customer" %>
        </h2>

        <form method="post"
              action="<%= contextPath %>/customer-management">

            <input type="hidden"
                   name="action"
                   value="<%= editMode ? "update" : "create" %>">

            <% if (editMode) { %>

                <input type="hidden"
                       name="id"
                       value="<%= editCustomer.getId() %>">

            <% } %>

            <div class="form-grid">

                <div class="form-group">

                    <label for="name">
                        Customer Name *
                    </label>

                    <input type="text"
                           id="name"
                           name="name"
                           maxlength="100"
                           required
                           value="<%= editMode && editCustomer.getName() != null
                                   ? editCustomer.getName()
                                   : "" %>">

                </div>


                <div class="form-group">

                    <label for="email">
                        Email
                    </label>

                    <input type="email"
                           id="email"
                           name="email"
                           maxlength="100"
                           value="<%= editMode && editCustomer.getEmail() != null
                                   ? editCustomer.getEmail()
                                   : "" %>">

                </div>


                <div class="form-group">

                    <label for="phone">
                        Phone *
                    </label>

                    <input type="text"
                           id="phone"
                           name="phone"
                           maxlength="20"
                           required
                           value="<%= editMode && editCustomer.getPhone() != null
                                   ? editCustomer.getPhone()
                                   : "" %>">

                </div>


                <div class="form-group">

                    <label for="status">
                        Status
                    </label>

                    <select id="status"
                            name="status">

                        <option value="ACTIVE"
                            <%= editMode
                                && "ACTIVE".equalsIgnoreCase(editCustomer.getStatus())
                                ? "selected"
                                : (!editMode ? "selected" : "") %>>
                            ACTIVE
                        </option>

                        <option value="INACTIVE"
                            <%= editMode
                                && "INACTIVE".equalsIgnoreCase(editCustomer.getStatus())
                                ? "selected"
                                : "" %>>
                            INACTIVE
                        </option>

                    </select>

                </div>


                <div class="form-group full">

                    <label for="address">
                        Address
                    </label>

                    <textarea id="address"
                              name="address"
                              maxlength="255"><%= editMode && editCustomer.getAddress() != null
                                      ? editCustomer.getAddress()
                                      : "" %></textarea>

                </div>


                <div class="form-group full">

                    <label for="serviceDetails">
                        Service Details
                    </label>

                    <textarea id="serviceDetails"
                              name="serviceDetails"
                              maxlength="500"><%= editMode && editCustomer.getServiceDetails() != null
                                      ? editCustomer.getServiceDetails()
                                      : "" %></textarea>

                </div>

            </div>


            <div class="button-row">

                <button type="submit"
                        class="primary">
                    <%= editMode ? "Update Customer" : "Add Customer" %>
                </button>

                <% if (editMode) { %>

                    <a href="<%= contextPath %>/customer-management"
                       class="btn secondary">
                        Cancel
                    </a>

                <% } %>

            </div>

        </form>

    </div>


    <!-- Search -->

    <div class="card">

        <h2>Search Customers</h2>

        <form method="get"
              action="<%= contextPath %>/customer-management"
              class="search-row">

            <input type="text"
                   name="keyword"
                   placeholder="Search by name, email, phone, address, service or status"
                   value="<%= keyword != null ? keyword : "" %>">

            <button type="submit"
                    class="primary">
                Search
            </button>

            <a href="<%= contextPath %>/customer-management"
               class="btn secondary">
                Clear
            </a>

        </form>


        <!-- Customer List -->

        <h2>Customer List</h2>

        <div class="table-container">

            <table>

                <thead>

                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Address</th>
                        <th>Service Details</th>
                        <th>Status</th>
                        <th>Created At</th>
                        <th>Actions</th>
                    </tr>

                </thead>

                <tbody>

                <% if (customers.isEmpty()) { %>

                    <tr>

                        <td colspan="9"
                            class="empty">
                            No customers found.
                        </td>

                    </tr>

                <% } else { %>

                    <% for (Customer customer : customers) { %>

                        <tr>

                            <td>
                                <%= customer.getId() %>
                            </td>

                            <td>
                                <%= customer.getName() != null
                                        ? customer.getName()
                                        : "" %>
                            </td>

                            <td>
                                <%= customer.getEmail() != null
                                        ? customer.getEmail()
                                        : "" %>
                            </td>

                            <td>
                                <%= customer.getPhone() != null
                                        ? customer.getPhone()
                                        : "" %>
                            </td>

                            <td>
                                <%= customer.getAddress() != null
                                        ? customer.getAddress()
                                        : "" %>
                            </td>

                            <td>
                                <%= customer.getServiceDetails() != null
                                        ? customer.getServiceDetails()
                                        : "" %>
                            </td>

                            <td>

                                <% if ("ACTIVE".equalsIgnoreCase(customer.getStatus())) { %>

                                    <span class="status status-active">
                                        ACTIVE
                                    </span>

                                <% } else { %>

                                    <span class="status status-inactive">
                                        INACTIVE
                                    </span>

                                <% } %>

                            </td>

                            <td>
                                <%= customer.getCreatedAt() != null
                                        ? customer.getCreatedAt()
                                        : "" %>
                            </td>

                            <td>

                                <div class="action-buttons">

                                    <a href="<%= contextPath %>/customer-management?editId=<%= customer.getId() %>"
                                       class="btn edit-btn">
                                        Edit
                                    </a>


                                    <% if ("ACTIVE".equalsIgnoreCase(customer.getStatus())) { %>

                                        <form method="post"
                                              action="<%= contextPath %>/customer-management"
                                              class="action-form">

                                            <input type="hidden"
                                                   name="action"
                                                   value="status">

                                            <input type="hidden"
                                                   name="id"
                                                   value="<%= customer.getId() %>">

                                            <input type="hidden"
                                                   name="status"
                                                   value="INACTIVE">

                                            <button type="submit"
                                                    class="btn deactivate-btn">
                                                Deactivate
                                            </button>

                                        </form>

                                    <% } else { %>

                                        <form method="post"
                                              action="<%= contextPath %>/customer-management"
                                              class="action-form">

                                            <input type="hidden"
                                                   name="action"
                                                   value="status">

                                            <input type="hidden"
                                                   name="id"
                                                   value="<%= customer.getId() %>">

                                            <input type="hidden"
                                                   name="status"
                                                   value="ACTIVE">

                                            <button type="submit"
                                                    class="btn activate-btn">
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

    </div>

</div>

</body>
</html>