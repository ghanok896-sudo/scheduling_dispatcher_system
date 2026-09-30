package com.schedulingdispatch.controller;

import java.io.IOException;
import java.util.List;

import com.schedulingdispatch.model.Customer;
import com.schedulingdispatch.model.User;
import com.schedulingdispatch.service.CustomerService;
import com.schedulingdispatch.service.impl.CustomerServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/customer-management")
public class CustomerManagementServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private CustomerService customerService;

    @Override
    public void init() throws ServletException {
        customerService = new CustomerServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        User loggedInUser = getLoggedInUser(session);

        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access denied. Administrator privileges are required.");
            return;
        }

        String keyword = request.getParameter("keyword");
        String editId = request.getParameter("editId");

        try {

            List<Customer> customers;

            if (keyword == null || keyword.trim().isEmpty()) {
                customers = customerService.findAll();
            } else {
                customers = customerService.search(keyword.trim());
            }

            request.setAttribute("customers", customers);
            request.setAttribute("keyword", keyword);

            /*
             * Load customer details when Edit is selected.
             */
            if (editId != null && !editId.trim().isEmpty()) {

                try {

                    Long customerId = Long.parseLong(editId.trim());

                    Customer editCustomer =
                            customerService.findById(customerId);

                    if (editCustomer == null) {
                        request.setAttribute(
                                "error",
                                "Customer not found."
                        );
                    } else {
                        request.setAttribute(
                                "editCustomer",
                                editCustomer
                        );
                    }

                } catch (NumberFormatException exception) {

                    request.setAttribute(
                            "error",
                            "Invalid customer ID."
                    );
                }
            }

            request.getRequestDispatcher("/customer-management.jsp")
                    .forward(request, response);

        } catch (Exception exception) {

            exception.printStackTrace();

            request.setAttribute(
                    "error",
                    "Unable to load customer management data."
            );

            request.setAttribute(
                    "customers",
                    List.of()
            );

            request.getRequestDispatcher("/customer-management.jsp")
                    .forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                           HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        User loggedInUser = getLoggedInUser(session);

        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!"ADMIN".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access denied. Administrator privileges are required.");
            return;
        }

        String action = request.getParameter("action");

        try {

            if ("create".equalsIgnoreCase(action)) {

                createCustomer(request);

                response.sendRedirect(
                        request.getContextPath()
                                + "/customer-management?success="
                                + "Customer+created+successfully."
                );

            } else if ("update".equalsIgnoreCase(action)) {

                updateCustomer(request);

                response.sendRedirect(
                        request.getContextPath()
                                + "/customer-management?success="
                                + "Customer+updated+successfully."
                );

            } else if ("status".equalsIgnoreCase(action)) {

                changeCustomerStatus(request);

                response.sendRedirect(
                        request.getContextPath()
                                + "/customer-management?success="
                                + "Customer+status+updated+successfully."
                );

            } else {

                request.setAttribute(
                        "error",
                        "Invalid customer management action."
                );

                doGet(request, response);
            }

        } catch (IllegalArgumentException exception) {

            request.setAttribute(
                    "error",
                    exception.getMessage()
            );

            doGet(request, response);

        } catch (Exception exception) {

            exception.printStackTrace();

            request.setAttribute(
                    "error",
                    "An unexpected error occurred while processing the request."
            );

            doGet(request, response);
        }
    }

    private void createCustomer(HttpServletRequest request) {

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String serviceDetails = request.getParameter("serviceDetails");
        String status = request.getParameter("status");

        Customer customer = new Customer();

        customer.setName(name);
        customer.setEmail(email);
        customer.setPhone(phone);
        customer.setAddress(address);
        customer.setServiceDetails(serviceDetails);
        customer.setStatus(status);

        customerService.createCustomer(customer);
    }

    private void updateCustomer(HttpServletRequest request) {

        Long id = parseId(request.getParameter("id"));

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String serviceDetails = request.getParameter("serviceDetails");
        String status = request.getParameter("status");

        Customer customer = new Customer();

        customer.setId(id);
        customer.setName(name);
        customer.setEmail(email);
        customer.setPhone(phone);
        customer.setAddress(address);
        customer.setServiceDetails(serviceDetails);
        customer.setStatus(status);

        customerService.updateCustomer(customer);
    }

    private void changeCustomerStatus(HttpServletRequest request) {

        Long id = parseId(request.getParameter("id"));

        String status = request.getParameter("status");

        customerService.changeStatus(id, status);
    }

    private Long parseId(String value) {

        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(
                    "Customer ID is required."
            );
        }

        try {
            return Long.parseLong(value.trim());

        } catch (NumberFormatException exception) {

            throw new IllegalArgumentException(
                    "Invalid customer ID."
            );
        }
    }

    private User getLoggedInUser(HttpSession session) {

        if (session == null) {
            return null;
        }

        Object userObject =
                session.getAttribute("loggedInUser");

        if (userObject instanceof User) {
            return (User) userObject;
        }

        return null;
    }
}