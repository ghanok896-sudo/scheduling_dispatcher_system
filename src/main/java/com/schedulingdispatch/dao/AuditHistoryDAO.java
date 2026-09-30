package com.schedulingdispatch.dao;

import com.schedulingdispatch.model.AuditHistory;

import java.util.List;

public interface AuditHistoryDAO {

    List<AuditHistory> findAll();

    List<AuditHistory> search(String keyword);

    AuditHistory findById(Long id);

    List<AuditHistory> findByScheduleId(Long scheduleId);

    void save(AuditHistory auditHistory);
}