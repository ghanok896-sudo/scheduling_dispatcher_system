package com.schedulingdispatch.dao;

import com.schedulingdispatch.model.Notification;

import java.util.List;

public interface NotificationDAO {

    List<Notification> findAll();

    List<Notification> search(String keyword);

    Notification findById(Long id);

    List<Notification> findByUserId(Long userId);

    List<Notification> findUnreadByUserId(Long userId);

    long countUnreadByUserId(Long userId);

    void save(Notification notification);

    void update(Notification notification);

    void delete(Notification notification);

    void markAsRead(Long id);

    void markAllAsRead(Long userId);
}