package com.schedulingdispatch.controller;

import com.schedulingdispatch.model.User;
import com.schedulingdispatch.service.UserService;
import com.schedulingdispatch.service.impl.UserServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UserService userService;

    @Override
    public void init() {

        userService = new UserServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/login.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                           HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || username.trim().isEmpty()
                || password == null || password.isEmpty()) {

            request.setAttribute(
                    "error",
                    "Username and password are required.");

            request.getRequestDispatcher("/login.jsp")
                    .forward(request, response);

            return;
        }

        try {

            User user = userService.authenticate(
                    username,
                    password
            );

            if (user == null) {

                request.setAttribute(
                        "error",
                        "Invalid username or password.");

                request.getRequestDispatcher("/login.jsp")
                        .forward(request, response);

                return;
            }

            HttpSession session = request.getSession(true);

            session.setAttribute("loggedInUser", user);
            session.setAttribute("userId", user.getId());
            session.setAttribute("username", user.getUsername());
            session.setAttribute("userRole", user.getRole());
            session.setAttribute("fullName", user.getFullName());

            response.sendRedirect(
                    request.getContextPath() + "/dashboard"
            );

        } catch (Exception exception) {

            exception.printStackTrace();

            request.setAttribute(
                    "error",
                    "Unable to process login. Please try again.");

            request.getRequestDispatcher("/login.jsp")
                    .forward(request, response);
        }
    }
}