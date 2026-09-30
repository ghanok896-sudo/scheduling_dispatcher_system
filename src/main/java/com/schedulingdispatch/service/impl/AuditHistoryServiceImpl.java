package com.schedulingdispatch.service.impl;

import com.schedulingdispatch.dao.AuditHistoryDAO;
import com.schedulingdispatch.dao.impl.AuditHistoryDAOImpl;
import com.schedulingdispatch.model.AuditHistory;
import com.schedulingdispatch.service.AuditHistoryService;

import java.time.LocalDateTime;
import java.util.List;

public class AuditHistoryServiceImpl
        implements AuditHistoryService {

    private final AuditHistoryDAO auditHistoryDAO;

    public AuditHistoryServiceImpl() {
        this.auditHistoryDAO =
                new AuditHistoryDAOImpl();
    }

    @Override
    public List<AuditHistory> findAll() {
        return auditHistoryDAO.findAll();
    }

    @Override
    public List<AuditHistory> search(String keyword) {

        if (keyword == null
                || keyword.trim().isEmpty()) {

            return auditHistoryDAO.findAll();
        }

        return auditHistoryDAO.search(
                keyword.trim()
        );
    }

    @Override
    public AuditHistory findById(Long id) {

        if (id == null || id <= 0) {
            return null;
        }

        return auditHistoryDAO.findById(id);
    }

    @Override
    public List<AuditHistory> findByScheduleId(
            Long scheduleId) {

        if (scheduleId == null
                || scheduleId <= 0) {

            return List.of();
        }

        return auditHistoryDAO.findByScheduleId(
                scheduleId
        );
    }

    @Override
    public void recordAudit(
            Long scheduleId,
            Long userId,
            String action,
            String oldStatus,
            String newStatus,
            String description) {

        if (scheduleId == null
                || scheduleId <= 0) {

            throw new IllegalArgumentException(
                    "Valid schedule ID is required."
            );
        }

        if (action == null
                || action.trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Audit action is required."
            );
        }

        if (action.trim().length() > 100) {

            throw new IllegalArgumentException(
                    "Audit action cannot exceed 100 characters."
            );
        }

        if (oldStatus != null
                && oldStatus.trim().length() > 30) {

            throw new IllegalArgumentException(
                    "Old status cannot exceed 30 characters."
            );
        }

        if (newStatus != null
                && newStatus.trim().length() > 30) {

            throw new IllegalArgumentException(
                    "New status cannot exceed 30 characters."
            );
        }

        if (description != null
                && description.trim().length() > 1000) {

            throw new IllegalArgumentException(
                    "Audit description cannot exceed 1000 characters."
            );
        }

        AuditHistory auditHistory =
                new AuditHistory();

        auditHistory.setScheduleId(scheduleId);

        auditHistory.setUserId(userId);

        auditHistory.setAction(
                action.trim().toUpperCase()
        );

        auditHistory.setOldStatus(
                normalize(oldStatus)
        );

        auditHistory.setNewStatus(
                normalize(newStatus)
        );

        auditHistory.setDescription(
                normalize(description)
        );

        auditHistory.setCreatedAt(
                LocalDateTime.now()
        );

        auditHistoryDAO.save(
                auditHistory
        );
    }

    private String normalize(String value) {

        if (value == null) {
            return null;
        }

        String normalized =
                value.trim();

        return normalized.isEmpty()
                ? null
                : normalized;
    }
}