package com.schedulingdispatch.dao.impl;

import com.schedulingdispatch.dao.TaskDAO;
import com.schedulingdispatch.model.Task;
import com.schedulingdispatch.util.HibernateUtil;

import org.hibernate.Session;
import org.hibernate.Transaction;

import java.util.List;

public class TaskDAOImpl implements TaskDAO {

    @Override
    public List<Task> findAll() {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                    "FROM Task t ORDER BY t.id DESC",
                    Task.class
            ).getResultList();
        }
    }

    @Override
    public List<Task> search(String keyword) {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            String searchKeyword = keyword == null
                    ? ""
                    : keyword.trim().toLowerCase();

            return session.createQuery(
                    """
                    FROM Task t
                    WHERE LOWER(t.title) LIKE :keyword
                       OR LOWER(t.description) LIKE :keyword
                       OR LOWER(t.priority) LIKE :keyword
                       OR LOWER(t.status) LIKE :keyword
                    ORDER BY t.id DESC
                    """,
                    Task.class
            )
            .setParameter(
                    "keyword",
                    "%" + searchKeyword + "%"
            )
            .getResultList();
        }
    }

    @Override
    public Task findById(Long id) {

        if (id == null) {
            return null;
        }

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.get(Task.class, id);
        }
    }

    @Override
    public void save(Task task) {

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.persist(task);

            transaction.commit();

        } catch (Exception e) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw e;
        }
    }

    @Override
    public void update(Task task) {

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.merge(task);

            transaction.commit();

        } catch (Exception e) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw e;
        }
    }

    @Override
    public void delete(Task task) {

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.remove(
                    session.contains(task)
                            ? task
                            : session.merge(task)
            );

            transaction.commit();

        } catch (Exception e) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw e;
        }
    }
}