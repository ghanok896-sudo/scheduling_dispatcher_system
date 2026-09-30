package com.schedulingdispatch.dao.impl;

import com.schedulingdispatch.dao.DispatchDAO;
import com.schedulingdispatch.model.Dispatch;
import com.schedulingdispatch.util.HibernateUtil;

import org.hibernate.Session;
import org.hibernate.Transaction;

import java.util.List;

public class DispatchDAOImpl implements DispatchDAO {

    @Override
    public List<Dispatch> findAll() {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                    """
                    FROM Dispatch d
                    ORDER BY d.id DESC
                    """,
                    Dispatch.class
            ).getResultList();
        }
    }

    @Override
    public List<Dispatch> search(String keyword) {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            String searchKeyword =
                    keyword == null
                            ? ""
                            : keyword.trim().toLowerCase();

            return session.createQuery(
                    """
                    FROM Dispatch d
                    WHERE LOWER(d.dispatchStatus) LIKE :keyword
                       OR LOWER(d.remarks) LIKE :keyword
                    ORDER BY d.id DESC
                    """,
                    Dispatch.class
            )
            .setParameter(
                    "keyword",
                    "%" + searchKeyword + "%"
            )
            .getResultList();
        }
    }

    @Override
    public Dispatch findById(Long id) {

        if (id == null) {
            return null;
        }

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.get(Dispatch.class, id);
        }
    }

    @Override
    public Dispatch findByScheduleId(Long scheduleId) {

        if (scheduleId == null) {
            return null;
        }

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                    """
                    FROM Dispatch d
                    WHERE d.scheduleId = :scheduleId
                    ORDER BY d.id DESC
                    """,
                    Dispatch.class
            )
            .setParameter("scheduleId", scheduleId)
            .setMaxResults(1)
            .uniqueResult();
        }
    }

    @Override
    public boolean existsByScheduleId(Long scheduleId) {

        if (scheduleId == null) {
            return false;
        }

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            Long count = session.createQuery(
                    """
                    SELECT COUNT(d)
                    FROM Dispatch d
                    WHERE d.scheduleId = :scheduleId
                    """,
                    Long.class
            )
            .setParameter("scheduleId", scheduleId)
            .uniqueResult();

            return count != null && count > 0;
        }
    }

    @Override
    public void save(Dispatch dispatch) {

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.persist(dispatch);

            transaction.commit();

        } catch (Exception exception) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw exception;
        }
    }

    @Override
    public void update(Dispatch dispatch) {

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.merge(dispatch);

            transaction.commit();

        } catch (Exception exception) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw exception;
        }
    }

    @Override
    public void delete(Dispatch dispatch) {

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            Dispatch managedDispatch =
                    session.contains(dispatch)
                            ? dispatch
                            : session.merge(dispatch);

            session.remove(managedDispatch);

            transaction.commit();

        } catch (Exception exception) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw exception;
        }
    }
}