package com.schedulingdispatch.service.impl;

import java.time.LocalDateTime;
import java.util.List;

import com.schedulingdispatch.dao.UserDAO;
import com.schedulingdispatch.dao.impl.UserDAOImpl;
import com.schedulingdispatch.model.User;
import com.schedulingdispatch.service.UserService;

import org.mindrot.jbcrypt.BCrypt;

public class UserServiceImpl implements UserService {

    private final UserDAO userDAO;

    public UserServiceImpl() {
        this.userDAO = new UserDAOImpl();
    }

    @Override
    public User authenticate(String username, String password) {

        if (username == null || username.trim().isEmpty()) {
            return null;
        }

        if (password == null || password.isEmpty()) {
            return null;
        }

        User user = userDAO.findByUsername(username.trim());

        if (user == null) {
            return null;
        }

        if (!"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            return null;
        }

        if (!BCrypt.checkpw(password, user.getPassword())) {
            return null;
        }

        return user;
    }

    @Override
    public User findByUsername(String username) {

        if (username == null || username.trim().isEmpty()) {
            return null;
        }

        return userDAO.findByUsername(username.trim());
    }

    @Override
    public User findById(Long id) {

        if (id == null) {
            return null;
        }

        return userDAO.findById(id);
    }

    @Override
    public List<User> findAll() {
        return userDAO.findAll();
    }

    @Override
    public List<User> search(String keyword) {
        return userDAO.search(keyword);
    }

    @Override
    public void createUser(User user) {

        if (user == null) {
            throw new IllegalArgumentException(
                    "User cannot be null.");
        }

        validateCommonFields(user);

        String username = user.getUsername().trim();
        String email = user.getEmail().trim();

        if (userDAO.existsByUsername(username)) {

            throw new IllegalArgumentException(
                    "Username already exists.");
        }

        if (userDAO.existsByEmail(email)) {

            throw new IllegalArgumentException(
                    "Email already exists.");
        }

        validateRole(user.getRole());

        if (user.getStatus() == null
                || user.getStatus().trim().isEmpty()) {

            user.setStatus("ACTIVE");
        }

        validateStatus(user.getStatus());

        user.setUsername(username);
        user.setEmail(email);

        user.setPassword(
                BCrypt.hashpw(
                        user.getPassword(),
                        BCrypt.gensalt(12)
                )
        );

        user.setCreatedAt(LocalDateTime.now());

        userDAO.save(user);
    }

    @Override
    public void updateUser(
            User user,
            String newPassword) {

        if (user == null || user.getId() == null) {

            throw new IllegalArgumentException(
                    "Invalid user.");
        }

        validateCommonFields(user);

        String username = user.getUsername().trim();
        String email = user.getEmail().trim();

        if (userDAO.existsByUsernameExcludingId(
                username,
                user.getId())) {

            throw new IllegalArgumentException(
                    "Username already exists.");
        }

        if (userDAO.existsByEmailExcludingId(
                email,
                user.getId())) {

            throw new IllegalArgumentException(
                    "Email already exists.");
        }

        validateRole(user.getRole());
        validateStatus(user.getStatus());

        User existingUser =
                userDAO.findById(user.getId());

        if (existingUser == null) {

            throw new IllegalArgumentException(
                    "User not found.");
        }

        existingUser.setUsername(username);
        existingUser.setFullName(
                user.getFullName().trim());
        existingUser.setEmail(email);
        existingUser.setPhone(user.getPhone());
        existingUser.setRole(user.getRole().trim().toUpperCase());
        existingUser.setStatus(
                user.getStatus().trim().toUpperCase());

        /*
         * Password is changed only when the administrator
         * enters a new password.
         */
        if (newPassword != null
                && !newPassword.trim().isEmpty()) {

            if (newPassword.length() < 6) {

                throw new IllegalArgumentException(
                        "Password must contain at least 6 characters.");
            }

            existingUser.setPassword(
                    BCrypt.hashpw(
                            newPassword,
                            BCrypt.gensalt(12)
                    )
            );
        }

        userDAO.update(existingUser);
    }

    @Override
    public void changeStatus(
            Long userId,
            String status) {

        if (userId == null) {

            throw new IllegalArgumentException(
                    "User ID is required.");
        }

        validateStatus(status);

        User user = userDAO.findById(userId);

        if (user == null) {

            throw new IllegalArgumentException(
                    "User not found.");
        }

        user.setStatus(
                status.trim().toUpperCase());

        userDAO.update(user);
    }

    @Override
    public void changeRole(
            Long userId,
            String role) {

        if (userId == null) {

            throw new IllegalArgumentException(
                    "User ID is required.");
        }

        validateRole(role);

        User user = userDAO.findById(userId);

        if (user == null) {

            throw new IllegalArgumentException(
                    "User not found.");
        }

        user.setRole(
                role.trim().toUpperCase());

        userDAO.update(user);
    }

    @Override
    public boolean usernameExists(String username) {
        return userDAO.existsByUsername(username);
    }

    @Override
    public boolean emailExists(String email) {
        return userDAO.existsByEmail(email);
    }

    private void validateCommonFields(User user) {

        if (user.getUsername() == null
                || user.getUsername().trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Username is required.");
        }

        if (user.getFullName() == null
                || user.getFullName().trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Full name is required.");
        }

        if (user.getEmail() == null
                || user.getEmail().trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Email is required.");
        }

        if (!user.getEmail().matches(
                "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {

            throw new IllegalArgumentException(
                    "Enter a valid email address.");
        }
    }

    private void validateRole(String role) {

        if (role == null
                || role.trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Role is required.");
        }

        String normalizedRole =
                role.trim().toUpperCase();

        if (!normalizedRole.equals("ADMIN")
                && !normalizedRole.equals("MANAGER")
                && !normalizedRole.equals("DISPATCHER")
                && !normalizedRole.equals("EMPLOYEE")) {

            throw new IllegalArgumentException(
                    "Invalid user role.");
        }
    }

    private void validateStatus(String status) {

        if (status == null
                || status.trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Status is required.");
        }

        String normalizedStatus =
                status.trim().toUpperCase();

        if (!normalizedStatus.equals("ACTIVE")
                && !normalizedStatus.equals("INACTIVE")) {

            throw new IllegalArgumentException(
                    "Invalid user status.");
        }
    }
}