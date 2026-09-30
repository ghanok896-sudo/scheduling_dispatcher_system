package com.schedulingdispatch.dao.impl;

import java.util.List;

import com.schedulingdispatch.dao.CustomerDAO;
import com.schedulingdispatch.model.Customer;
import com.schedulingdispatch.util.HibernateUtil;

import org.hibernate.Session;
import org.hibernate.Transaction;

public class CustomerDAOImpl implements CustomerDAO {

    @Override
    public List<Customer> findAll() {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                            "FROM Customer c ORDER BY c.id ASC",
                            Customer.class)
                    .getResultList();
        }
    }

    @Override
    public List<Customer> search(String keyword) {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            if (keyword == null || keyword.trim().isEmpty()) {

                return session.createQuery(
                                "FROM Customer c ORDER BY c.id ASC",
                                Customer.class)
                        .getResultList();
            }

            String searchValue =
                    "%" + keyword.trim().toLowerCase() + "%";

            return session.createQuery(
                            """
                            FROM Customer c
                            WHERE LOWER(c.name) LIKE :keyword
                               OR LOWER(c.email) LIKE :keyword
                               OR LOWER(c.phone) LIKE :keyword
                               OR LOWER(c.address) LIKE :keyword
                               OR LOWER(c.serviceDetails) LIKE :keyword
                               OR LOWER(c.status) LIKE :keyword
                            ORDER BY c.id ASC
                            """,
                            Customer.class)
                    .setParameter("keyword", searchValue)
                    .getResultList();
        }
    }

    @Override
    public Customer findById(Long id) {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.get(Customer.class, id);
        }
    }

    @Override
    public void save(Customer customer) {

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.persist(customer);

            transaction.commit();

        } catch (Exception exception) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw exception;
        }
    }

    @Override
    public void update(Customer customer) {

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.merge(customer);

            transaction.commit();

        } catch (Exception exception) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw exception;
        }
    }

    @Override
    public void delete(Customer customer) {

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            Customer managedCustomer =
                    session.get(Customer.class, customer.getId());

            if (managedCustomer != null) {
                session.remove(managedCustomer);
            }

            transaction.commit();

        } catch (Exception exception) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw exception;
        }
    }
}