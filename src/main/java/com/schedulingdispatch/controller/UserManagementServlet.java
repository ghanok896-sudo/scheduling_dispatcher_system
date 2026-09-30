package com.schedulingdispatch.controller;

import java.io.IOException;
import java.util.List;

import com.schedulingdispatch.model.User;
import com.schedulingdispatch.service.UserService;
import com.schedulingdispatch.service.impl.UserServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/user-management")
public class UserManagementServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UserService userService;

    @Override
    public void init() throws ServletException {

        userService = new UserServiceImpl();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        User loggedInUser = getLoggedInUser(session);

        /*
         * Check whether the user is logged in.
         */
        if (loggedInUser == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login"
            );

            return;
        }

        /*
         * Only ADMIN users can access User Management.
         */
        if (!"ADMIN".equalsIgnoreCase(
                loggedInUser.getRole())) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied."
            );

            return;
        }

        String keyword =
                request.getParameter("keyword");

        String editId =
                request.getParameter("editId");

        List<User> users;

        /*
         * Load all users when there is no search keyword.
         */
        if (keyword == null
                || keyword.trim().isEmpty()) {

            users = userService.findAll();

        } else {

            /*
             * Search users using the supplied keyword.
             */
            users = userService.search(keyword);
        }

        request.setAttribute("users", users);
        request.setAttribute("keyword", keyword);

        /*
         * Load the selected user for editing.
         */
        if (editId != null
                && !editId.trim().isEmpty()) {

            try {

                Long id =
                        Long.parseLong(editId);

                User editUser =
                        userService.findById(id);

                request.setAttribute(
                        "editUser",
                        editUser
                );

            } catch (NumberFormatException exception) {

                request.setAttribute(
                        "error",
                        "Invalid user ID."
                );
            }
        }

        /*
         * Forward the request to the User Management JSP.
         */
        request.getRequestDispatcher(
                "/user-management.jsp"
        ).forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session =
                request.getSession(false);

        User loggedInUser =
                getLoggedInUser(session);

        /*
         * Check login.
         */
        if (loggedInUser == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login"
            );

            return;
        }

        /*
         * Only ADMIN users can perform
         * User Management operations.
         */
        if (!"ADMIN".equalsIgnoreCase(
                loggedInUser.getRole())) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied."
            );

            return;
        }

        String action =
                request.getParameter("action");

        try {

            /*
             * Create user.
             */
            if ("create".equals(action)) {

                createUser(request);

                response.sendRedirect(
                        request.getContextPath()
                                + "/user-management?success="
                                + "User+created+successfully."
                );

                return;
            }

            /*
             * Update user.
             */
            if ("update".equals(action)) {

                updateUser(request);

                response.sendRedirect(
                        request.getContextPath()
                                + "/user-management?success="
                                + "User+updated+successfully."
                );

                return;
            }

            /*
             * Change user status.
             */
            if ("status".equals(action)) {

                changeStatus(
                        request,
                        loggedInUser
                );

                response.sendRedirect(
                        request.getContextPath()
                                + "/user-management?success="
                                + "User+status+updated+successfully."
                );

                return;
            }

            /*
             * Change user role.
             */
            if ("role".equals(action)) {

                changeRole(
                        request,
                        loggedInUser
                );

                response.sendRedirect(
                        request.getContextPath()
                                + "/user-management?success="
                                + "User+role+updated+successfully."
                );

                return;
            }

            /*
             * Invalid action.
             */
            response.sendRedirect(
                    request.getContextPath()
                            + "/user-management?error="
                            + "Invalid+action."
            );

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
                    "Unable to process the request. Please try again."
            );

            doGet(request, response);
        }
    }

    /*
     * Create a new user.
     */
    private void createUser(
            HttpServletRequest request) {

        String username =
                request.getParameter("username");

        String password =
                request.getParameter("password");

        String fullName =
                request.getParameter("fullName");

        String email =
                request.getParameter("email");

        String phone =
                request.getParameter("phone");

        String role =
                request.getParameter("role");

        String status =
                request.getParameter("status");

        User user = new User(
                username,
                password,
                fullName,
                email,
                phone,
                role,
                status
        );

        userService.createUser(user);
    }

    /*
     * Update an existing user.
     */
    private void updateUser(
            HttpServletRequest request) {

        Long id =
                parseId(
                        request.getParameter("id")
                );

        String username =
                request.getParameter("username");

        String fullName =
                request.getParameter("fullName");

        String email =
                request.getParameter("email");

        String phone =
                request.getParameter("phone");

        String role =
                request.getParameter("role");

        String status =
                request.getParameter("status");

        String newPassword =
                request.getParameter("password");

        User user = new User();

        user.setId(id);
        user.setUsername(username);
        user.setFullName(fullName);
        user.setEmail(email);
        user.setPhone(phone);
        user.setRole(role);
        user.setStatus(status);

        userService.updateUser(
                user,
                newPassword
        );
    }

    /*
     * Change user status.
     */
    private void changeStatus(
            HttpServletRequest request,
            User loggedInUser) {

        Long userId =
                parseId(
                        request.getParameter("id")
                );

        String status =
                request.getParameter("status");

        /*
         * Prevent an administrator from
         * deactivating their own account.
         */
        if (loggedInUser.getId().equals(userId)
                && "INACTIVE".equalsIgnoreCase(status)) {

            throw new IllegalArgumentException(
                    "You cannot deactivate your own account."
            );
        }

        userService.changeStatus(
                userId,
                status
        );
    }

    /*
     * Change user role.
     */
    private void changeRole(
            HttpServletRequest request,
            User loggedInUser) {

        Long userId =
                parseId(
                        request.getParameter("id")
                );

        String role =
                request.getParameter("role");

        /*
         * Prevent an administrator from
         * removing their own ADMIN role.
         */
        if (loggedInUser.getId().equals(userId)
                && !"ADMIN".equalsIgnoreCase(role)) {

            throw new IllegalArgumentException(
                    "You cannot remove your own ADMIN role."
            );
        }

        userService.changeRole(
                userId,
                role
        );
    }

    /*
     * Convert request parameter to Long ID.
     */
    private Long parseId(String value) {

        if (value == null
                || value.trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "User ID is required."
            );
        }

        try {

            return Long.parseLong(value);

        } catch (NumberFormatException exception) {

            throw new IllegalArgumentException(
                    "Invalid user ID."
            );
        }
    }

    /*
     * Get the currently logged-in user.
     *
     * Authentication recovery order:
     *
     * 1. loggedInUser
     * 2. userId
     * 3. username
     *
     * The username and userId are already stored
     * by LoginServlet, so no other functionality
     * is changed.
     */
    private User getLoggedInUser(
            HttpSession session) {

        /*
         * There must be an existing session.
         */
        if (session == null) {
            return null;
        }

        /*
         * -------------------------------------------------
         * 1. Try the complete User object.
         * -------------------------------------------------
         */
        Object userObject =
                session.getAttribute("loggedInUser");

        if (userObject instanceof User) {

            return (User) userObject;
        }

        /*
         * -------------------------------------------------
         * 2. Try the existing userId session attribute.
         * -------------------------------------------------
         */
        Object userIdObject =
                session.getAttribute("userId");

        if (userIdObject != null) {

            try {

                Long userId;

                if (userIdObject instanceof Long) {

                    userId =
                            (Long) userIdObject;

                } else {

                    userId =
                            Long.parseLong(
                                    userIdObject.toString()
                            );
                }

                User user =
                        userService.findById(userId);

                if (user != null) {

                    session.setAttribute(
                            "loggedInUser",
                            user
                    );

                    return user;
                }

            } catch (Exception exception) {

                exception.printStackTrace();
            }
        }

        /*
         * -------------------------------------------------
         * 3. Try the existing username session attribute.
         * -------------------------------------------------
         */
        Object usernameObject =
                session.getAttribute("username");

        if (usernameObject != null) {

            try {

                String username =
                        usernameObject.toString().trim();

                if (!username.isEmpty()) {

                    User user =
                            userService.findByUsername(
                                    username
                            );

                    if (user != null) {

                        session.setAttribute(
                                "loggedInUser",
                                user
                        );

                        /*
                         * Keep the existing session data
                         * synchronized.
                         */
                        session.setAttribute(
                                "userId",
                                user.getId()
                        );

                        session.setAttribute(
                                "userRole",
                                user.getRole()
                        );

                        session.setAttribute(
                                "fullName",
                                user.getFullName()
                        );

                        return user;
                    }
                }

            } catch (Exception exception) {

                exception.printStackTrace();
            }
        }

        /*
         * No authenticated user could be recovered.
         */
        return null;
    }
}