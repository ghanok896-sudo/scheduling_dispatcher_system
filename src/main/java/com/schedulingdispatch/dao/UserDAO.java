package com.schedulingdispatch.dao;

import java.util.List;

import com.schedulingdispatch.model.User;

public interface UserDAO {

    User findByUsername(String username);

    User findById(Long id);

    List<User> findAll();

    List<User> search(String keyword);

    void save(User user);

    void update(User user);

    boolean existsByUsername(String username);

    boolean existsByUsernameExcludingId(String username, Long id);

    boolean existsByEmail(String email);

    boolean existsByEmailExcludingId(String email, Long id);
}