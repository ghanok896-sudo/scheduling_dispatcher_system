package com.schedulingdispatch.dao.impl;

import com.schedulingdispatch.dao.NotificationDAO;
import com.schedulingdispatch.model.Notification;
import com.schedulingdispatch.util.HibernateUtil;

import org.hibernate.Session;
import org.hibernate.Transaction;

import java.util.List;

public class NotificationDAOImpl implements NotificationDAO {

    @Override
    public List<Notification> findAll() {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                    """
                    FROM Notification n
                    ORDER BY n.id DESC
                    """,
                    Notification.class
            ).getResultList();
        }
    }

    @Override
    public List<Notification> search(String keyword) {

        String searchKeyword =
                keyword == null
                        ? ""
                        : keyword.trim().toLowerCase();

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                    """
                    FROM Notification n
                    WHERE LOWER(n.title) LIKE :keyword
                       OR LOWER(n.message) LIKE :keyword
                       OR LOWER(n.notificationType) LIKE :keyword
                    ORDER BY n.id DESC
                    """,
                    Notification.class
            )
            .setParameter(
                    "keyword",
                    "%" + searchKeyword + "%"
            )
            .getResultList();
        }
    }

    @Override
    public Notification findById(Long id) {

        if (id == null) {
            return null;
        }

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.get(
                    Notification.class,
                    id
            );
        }
    }

    @Override
    public List<Notification> findByUserId(Long userId) {

        if (userId == null) {
            return List.of();
        }

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                    """
                    FROM Notification n
                    WHERE n.userId = :userId
                    ORDER BY n.id DESC
                    """,
                    Notification.class
            )
            .setParameter("userId", userId)
            .getResultList();
        }
    }

    @Override
    public List<Notification> findUnreadByUserId(Long userId) {

        if (userId == null) {
            return List.of();
        }

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                    """
                    FROM Notification n
                    WHERE n.userId = :userId
                      AND n.read = false
                    ORDER BY n.id DESC
                    """,
                    Notification.class
            )
            .setParameter("userId", userId)
            .getResultList();
        }
    }

    @Override
    public long countUnreadByUserId(Long userId) {

        if (userId == null) {
            return 0L;
        }

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                    """
                    SELECT COUNT(n)
                    FROM Notification n
                    WHERE n.userId = :userId
                      AND n.read = false
                    """,
                    Long.class
            )
            .setParameter("userId", userId)
            .getSingleResult();
        }
    }

    @Override
    public void save(Notification notification) {

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.persist(notification);

            transaction.commit();

        } catch (Exception exception) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw exception;
        }
    }

    @Override
    public void update(Notification notification) {

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.merge(notification);

            transaction.commit();

        } catch (Exception exception) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw exception;
        }
    }

    @Override
    public void delete(Notification notification) {

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            Notification managedNotification =
                    session.contains(notification)
                            ? notification
                            : session.merge(notification);

            session.remove(managedNotification);

            transaction.commit();

        } catch (Exception exception) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw exception;
        }
    }

    @Override
    public void markAsRead(Long id) {

        if (id == null) {
            return;
        }

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            int updatedRows = session.createMutationQuery(
                    """
                    UPDATE Notification n
                    SET n.read = true
                    WHERE n.id = :id
                      AND n.read = false
                    """
            )
            .setParameter("id", id)
            .executeUpdate();

            if (updatedRows == 0) {

                Notification notification =
                        session.get(
                                Notification.class,
                                id
                        );

                if (notification == null) {
                    throw new IllegalArgumentException(
                            "Notification not found."
                    );
                }

                if (!notification.isRead()) {
                    notification.setRead(true);
                }
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
    public void markAllAsRead(Long userId) {

        if (userId == null) {
            return;
        }

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.createMutationQuery(
                    """
                    UPDATE Notification n
                    SET n.read = true
                    WHERE n.userId = :userId
                      AND n.read = false
                    """
            )
            .setParameter("userId", userId)
            .executeUpdate();

            transaction.commit();

        } catch (Exception exception) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw exception;
        }
    }
}