package com.schedulingdispatch.service;

import java.util.List;

import com.schedulingdispatch.model.User;

public interface UserService {

    User authenticate(String username, String password);

    User findByUsername(String username);

    User findById(Long id);

    List<User> findAll();

    List<User> search(String keyword);

    void createUser(User user);

    void updateUser(User user, String newPassword);

    void changeStatus(Long userId, String status);

    void changeRole(Long userId, String role);

    boolean usernameExists(String username);

    boolean emailExists(String email);
}