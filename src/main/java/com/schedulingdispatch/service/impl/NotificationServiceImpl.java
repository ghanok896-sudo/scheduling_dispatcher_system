package com.schedulingdispatch.service.impl;

import com.schedulingdispatch.dao.NotificationDAO;
import com.schedulingdispatch.dao.impl.NotificationDAOImpl;
import com.schedulingdispatch.model.Notification;
import com.schedulingdispatch.service.NotificationService;

import java.time.LocalDateTime;
import java.util.List;

public class NotificationServiceImpl
        implements NotificationService {

    private final NotificationDAO notificationDAO;

    public NotificationServiceImpl() {
        this.notificationDAO =
                new NotificationDAOImpl();
    }

    @Override
    public List<Notification> findAll() {
        return notificationDAO.findAll();
    }

    @Override
    public List<Notification> search(String keyword) {

        if (keyword == null
                || keyword.trim().isEmpty()) {

            return notificationDAO.findAll();
        }

        return notificationDAO.search(
                keyword.trim()
        );
    }

    @Override
    public Notification findById(Long id) {

        if (id == null || id <= 0) {
            return null;
        }

        return notificationDAO.findById(id);
    }

    @Override
    public List<Notification> findByUserId(Long userId) {

        if (userId == null || userId <= 0) {
            return List.of();
        }

        return notificationDAO.findByUserId(userId);
    }

    @Override
    public List<Notification> findUnreadByUserId(Long userId) {

        if (userId == null || userId <= 0) {
            return List.of();
        }

        return notificationDAO.findUnreadByUserId(userId);
    }

    @Override
    public long countUnreadByUserId(Long userId) {

        if (userId == null || userId <= 0) {
            return 0L;
        }

        return notificationDAO.countUnreadByUserId(userId);
    }

    @Override
    public void createNotification(
            Notification notification) {

        if (notification == null) {
            throw new IllegalArgumentException(
                    "Notification information is required."
            );
        }

        validateNotification(notification);

        if (notification.getCreatedAt() == null) {
            notification.setCreatedAt(
                    LocalDateTime.now()
            );
        }

        notificationDAO.save(notification);
    }

    @Override
    public void updateNotification(
            Notification notification) {

        if (notification == null
                || notification.getId() == null) {

            throw new IllegalArgumentException(
                    "Valid notification information is required."
            );
        }

        Notification existing =
                notificationDAO.findById(
                        notification.getId()
                );

        if (existing == null) {
            throw new IllegalArgumentException(
                    "Notification not found."
            );
        }

        validateNotification(notification);

        if (notification.getCreatedAt() == null) {
            notification.setCreatedAt(
                    existing.getCreatedAt()
            );
        }

        notificationDAO.update(notification);
    }

    @Override
    public void deleteNotification(Long id) {

        if (id == null || id <= 0) {
            throw new IllegalArgumentException(
                    "Invalid notification ID."
            );
        }

        Notification notification =
                notificationDAO.findById(id);

        if (notification == null) {
            throw new IllegalArgumentException(
                    "Notification not found."
            );
        }

        notificationDAO.delete(notification);
    }

    @Override
    public void markAsRead(Long id) {

        if (id == null || id <= 0) {
            throw new IllegalArgumentException(
                    "Invalid notification ID."
            );
        }

        Notification notification =
                notificationDAO.findById(id);

        if (notification == null) {
            throw new IllegalArgumentException(
                    "Notification not found."
            );
        }

        notificationDAO.markAsRead(id);
    }

    @Override
    public void markAllAsRead(Long userId) {

        if (userId == null || userId <= 0) {
            throw new IllegalArgumentException(
                    "Invalid user ID."
            );
        }

        notificationDAO.markAllAsRead(userId);
    }

    private void validateNotification(
            Notification notification) {

        if (isBlank(notification.getTitle())) {

            throw new IllegalArgumentException(
                    "Notification title is required."
            );
        }

        if (notification.getTitle().trim().length() > 150) {

            throw new IllegalArgumentException(
                    "Notification title cannot exceed 150 characters."
            );
        }

        if (isBlank(notification.getMessage())) {

            throw new IllegalArgumentException(
                    "Notification message is required."
            );
        }

        if (notification.getMessage().trim().length() > 500) {

            throw new IllegalArgumentException(
                    "Notification message cannot exceed 500 characters."
            );
        }

        if (!isBlank(notification.getNotificationType())
                && notification.getNotificationType()
                        .trim().length() > 50) {

            throw new IllegalArgumentException(
                    "Notification type cannot exceed 50 characters."
            );
        }
    }

    private boolean isBlank(String value) {

        return value == null
                || value.trim().isEmpty();
    }
}