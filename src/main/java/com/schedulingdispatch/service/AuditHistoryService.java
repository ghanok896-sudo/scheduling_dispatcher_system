package com.schedulingdispatch.service;

import com.schedulingdispatch.model.AuditHistory;

import java.util.List;

public interface AuditHistoryService {

    List<AuditHistory> findAll();

    List<AuditHistory> search(String keyword);

    AuditHistory findById(Long id);

    List<AuditHistory> findByScheduleId(Long scheduleId);

    void recordAudit(
            Long scheduleId,
            Long userId,
            String action,
            String oldStatus,
            String newStatus,
            String description
    );
}