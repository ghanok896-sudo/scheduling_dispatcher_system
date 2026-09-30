package com.schedulingdispatch.service;

import com.schedulingdispatch.model.Notification;

import java.util.List;

public interface NotificationService {

    List<Notification> findAll();

    List<Notification> search(String keyword);

    Notification findById(Long id);

    List<Notification> findByUserId(Long userId);

    List<Notification> findUnreadByUserId(Long userId);

    long countUnreadByUserId(Long userId);

    void createNotification(Notification notification);

    void updateNotification(Notification notification);

    void deleteNotification(Long id);

    void markAsRead(Long id);

    void markAllAsRead(Long userId);
}