package com.schedulingdispatch.dao.impl;

import com.schedulingdispatch.dao.AuditHistoryDAO;
import com.schedulingdispatch.model.AuditHistory;
import com.schedulingdispatch.util.HibernateUtil;

import org.hibernate.Session;
import org.hibernate.Transaction;

import java.util.List;

public class AuditHistoryDAOImpl implements AuditHistoryDAO {

    @Override
    public List<AuditHistory> findAll() {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                    """
                    FROM AuditHistory a
                    ORDER BY a.id DESC
                    """,
                    AuditHistory.class
            ).getResultList();
        }
    }

    @Override
    public List<AuditHistory> search(String keyword) {

        String searchKeyword = keyword == null
                ? ""
                : keyword.trim().toLowerCase();

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                    """
                    FROM AuditHistory a
                    WHERE LOWER(COALESCE(a.action, '')) LIKE :keyword
                       OR LOWER(COALESCE(a.oldStatus, '')) LIKE :keyword
                       OR LOWER(COALESCE(a.newStatus, '')) LIKE :keyword
                       OR LOWER(COALESCE(a.description, '')) LIKE :keyword
                       OR CAST(a.scheduleId AS string) LIKE :keyword
                       OR CAST(a.userId AS string) LIKE :keyword
                    ORDER BY a.id DESC
                    """,
                    AuditHistory.class
            )
            .setParameter(
                    "keyword",
                    "%" + searchKeyword + "%"
            )
            .getResultList();
        }
    }

    @Override
    public AuditHistory findById(Long id) {

        if (id == null) {
            return null;
        }

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.get(
                    AuditHistory.class,
                    id
            );
        }
    }

    @Override
    public List<AuditHistory> findByScheduleId(Long scheduleId) {

        if (scheduleId == null) {
            return List.of();
        }

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                    """
                    FROM AuditHistory a
                    WHERE a.scheduleId = :scheduleId
                    ORDER BY a.id DESC
                    """,
                    AuditHistory.class
            )
            .setParameter(
                    "scheduleId",
                    scheduleId
            )
            .getResultList();
        }
    }

    @Override
    public void save(AuditHistory auditHistory) {

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.persist(auditHistory);

            transaction.commit();

        } catch (Exception exception) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw exception;
        }
    }
}