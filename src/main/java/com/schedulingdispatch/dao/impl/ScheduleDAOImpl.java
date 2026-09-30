package com.schedulingdispatch.dao.impl;

import com.schedulingdispatch.dao.ScheduleDAO;
import com.schedulingdispatch.model.Schedule;
import com.schedulingdispatch.util.HibernateUtil;

import org.hibernate.Session;
import org.hibernate.Transaction;

import java.time.LocalDateTime;
import java.util.List;

public class ScheduleDAOImpl implements ScheduleDAO {

    @Override
    public List<Schedule> findAll() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                    "FROM Schedule s ORDER BY s.scheduledStart ASC, s.id ASC",
                    Schedule.class
            ).getResultList();
        }
    }

    @Override
    public List<Schedule> search(String keyword) {

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            if (keyword == null || keyword.trim().isEmpty()) {
                return session.createQuery(
                        "FROM Schedule s ORDER BY s.scheduledStart ASC, s.id ASC",
                        Schedule.class
                ).getResultList();
            }

            String searchValue = "%" + keyword.trim().toLowerCase() + "%";

            return session.createQuery(
                    """
                    FROM Schedule s
                    WHERE LOWER(CAST(s.id AS string)) LIKE :keyword
                       OR LOWER(CAST(s.taskId AS string)) LIKE :keyword
                       OR LOWER(CAST(s.customerId AS string)) LIKE :keyword
                       OR LOWER(CAST(s.employeeId AS string)) LIKE :keyword
                       OR LOWER(s.priority) LIKE :keyword
                       OR LOWER(s.status) LIKE :keyword
                       OR LOWER(s.notes) LIKE :keyword
                    ORDER BY s.scheduledStart ASC, s.id ASC
                    """,
                    Schedule.class
            )
            .setParameter("keyword", searchValue)
            .getResultList();
        }
    }

    @Override
    public Schedule findById(Long id) {

        if (id == null) {
            return null;
        }

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session.get(Schedule.class, id);
        }
    }

    @Override
    public void save(Schedule schedule) {

        Transaction transaction = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.persist(schedule);

            transaction.commit();

        } catch (Exception exception) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw exception;
        }
    }

    @Override
    public void update(Schedule schedule) {

        Transaction transaction = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.merge(schedule);

            transaction.commit();

        } catch (Exception exception) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw exception;
        }
    }

    @Override
    public void delete(Schedule schedule) {

        if (schedule == null || schedule.getId() == null) {
            return;
        }

        Transaction transaction = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            Schedule managedSchedule =
                    session.get(Schedule.class, schedule.getId());

            if (managedSchedule != null) {
                session.remove(managedSchedule);
            }

            transaction.commit();

        } catch (Exception exception) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw exception;
        }
    }

    @Override
    public boolean hasEmployeeOverlap(
            Long employeeId,
            LocalDateTime scheduledStart,
            LocalDateTime scheduledEnd,
            Long excludeScheduleId) {

        if (employeeId == null
                || scheduledStart == null
                || scheduledEnd == null) {
            return false;
        }

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            StringBuilder hql = new StringBuilder(
                    """
                    SELECT COUNT(s)
                    FROM Schedule s
                    WHERE s.employeeId = :employeeId
                      AND s.status <> 'CANCELLED'
                      AND s.scheduledStart < :scheduledEnd
                      AND s.scheduledEnd > :scheduledStart
                    """
            );

            if (excludeScheduleId != null) {
                hql.append(" AND s.id <> :excludeScheduleId");
            }

            var query = session.createQuery(hql.toString(), Long.class)
                    .setParameter("employeeId", employeeId)
                    .setParameter("scheduledStart", scheduledStart)
                    .setParameter("scheduledEnd", scheduledEnd);

            if (excludeScheduleId != null) {
                query.setParameter("excludeScheduleId", excludeScheduleId);
            }

            Long count = query.getSingleResult();

            return count != null && count > 0;
        }
    }
}