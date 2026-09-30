package com.schedulingdispatch.dao.impl;

import java.util.List;

import com.schedulingdispatch.dao.UserDAO;
import com.schedulingdispatch.model.User;
import com.schedulingdispatch.util.HibernateUtil;

import org.hibernate.Session;
import org.hibernate.Transaction;

public class UserDAOImpl implements UserDAO {

    @Override
    public User findByUsername(String username) {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                            "FROM User u WHERE u.username = :username",
                            User.class)
                    .setParameter("username", username)
                    .uniqueResult();
        }
    }

    @Override
    public User findById(Long id) {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.get(User.class, id);
        }
    }

    @Override
    public List<User> findAll() {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                            "FROM User u ORDER BY u.id ASC",
                            User.class)
                    .getResultList();
        }
    }

    @Override
    public List<User> search(String keyword) {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            if (keyword == null || keyword.trim().isEmpty()) {

                return session.createQuery(
                                "FROM User u ORDER BY u.id ASC",
                                User.class)
                        .getResultList();
            }

            String searchValue =
                    "%" + keyword.trim().toLowerCase() + "%";

            return session.createQuery(
                            """
                            FROM User u
                            WHERE LOWER(u.username) LIKE :keyword
                               OR LOWER(u.fullName) LIKE :keyword
                               OR LOWER(u.email) LIKE :keyword
                               OR LOWER(u.role) LIKE :keyword
                               OR LOWER(u.status) LIKE :keyword
                            ORDER BY u.id ASC
                            """,
                            User.class)
                    .setParameter("keyword", searchValue)
                    .getResultList();
        }
    }

    @Override
    public void save(User user) {

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.persist(user);

            transaction.commit();

        } catch (Exception exception) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw exception;
        }
    }

    @Override
    public void update(User user) {

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.merge(user);

            transaction.commit();

        } catch (Exception exception) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw exception;
        }
    }

    @Override
    public boolean existsByUsername(String username) {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            Long count = session.createQuery(
                            "SELECT COUNT(u) FROM User u " +
                            "WHERE u.username = :username",
                            Long.class)
                    .setParameter("username", username)
                    .uniqueResult();

            return count != null && count > 0;
        }
    }

    @Override
    public boolean existsByUsernameExcludingId(
            String username,
            Long id) {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            Long count = session.createQuery(
                            """
                            SELECT COUNT(u)
                            FROM User u
                            WHERE LOWER(u.username) = LOWER(:username)
                              AND u.id <> :id
                            """,
                            Long.class)
                    .setParameter("username", username)
                    .setParameter("id", id)
                    .uniqueResult();

            return count != null && count > 0;
        }
    }

    @Override
    public boolean existsByEmail(String email) {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            Long count = session.createQuery(
                            "SELECT COUNT(u) FROM User u " +
                            "WHERE u.email = :email",
                            Long.class)
                    .setParameter("email", email)
                    .uniqueResult();

            return count != null && count > 0;
        }
    }

    @Override
    public boolean existsByEmailExcludingId(
            String email,
            Long id) {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            Long count = session.createQuery(
                            """
                            SELECT COUNT(u)
                            FROM User u
                            WHERE LOWER(u.email) = LOWER(:email)
                              AND u.id <> :id
                            """,
                            Long.class)
                    .setParameter("email", email)
                    .setParameter("id", id)
                    .uniqueResult();

            return count != null && count > 0;
        }
    }
}