package com.schedulingdispatch.dao.impl;

import java.util.List;

import org.hibernate.Session;
import org.hibernate.Transaction;

import com.schedulingdispatch.dao.EmployeeDAO;
import com.schedulingdispatch.model.Employee;
import com.schedulingdispatch.util.HibernateUtil;

public class EmployeeDAOImpl implements EmployeeDAO {

    @Override
    public List<Employee> findAll() {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.createQuery(
                    "FROM Employee e ORDER BY e.id ASC",
                    Employee.class
            ).getResultList();
        }
    }

    @Override
    public List<Employee> search(String keyword) {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            if (keyword == null || keyword.trim().isEmpty()) {

                return session.createQuery(
                        "FROM Employee e ORDER BY e.id ASC",
                        Employee.class
                ).getResultList();
            }

            String searchValue =
                    "%" + keyword.trim().toLowerCase() + "%";

            return session.createQuery(
                    """
                    FROM Employee e
                    WHERE LOWER(e.employeeCode) LIKE :keyword
                       OR LOWER(e.name) LIKE :keyword
                       OR LOWER(e.email) LIKE :keyword
                       OR LOWER(e.phone) LIKE :keyword
                       OR LOWER(e.designation) LIKE :keyword
                       OR LOWER(e.availabilityStatus) LIKE :keyword
                       OR LOWER(e.status) LIKE :keyword
                    ORDER BY e.id ASC
                    """,
                    Employee.class
            )
            .setParameter("keyword", searchValue)
            .getResultList();
        }
    }

    @Override
    public Employee findById(Long id) {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            return session.get(Employee.class, id);
        }
    }

    @Override
    public Employee findByEmployeeCode(String employeeCode) {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            if (employeeCode == null
                    || employeeCode.trim().isEmpty()) {

                return null;
            }

            return session.createQuery(
                    """
                    FROM Employee e
                    WHERE LOWER(e.employeeCode) = :employeeCode
                    """,
                    Employee.class
            )
            .setParameter(
                    "employeeCode",
                    employeeCode.trim().toLowerCase()
            )
            .uniqueResult();
        }
    }

    @Override
    public Employee findByUserId(Long userId) {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            if (userId == null) {
                return null;
            }

            return session.createQuery(
                    """
                    FROM Employee e
                    WHERE e.userId = :userId
                    """,
                    Employee.class
            )
            .setParameter("userId", userId)
            .uniqueResult();
        }
    }

    @Override
    public void save(Employee employee) {

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.persist(employee);

            transaction.commit();

        } catch (Exception exception) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw exception;
        }
    }

    @Override
    public void update(Employee employee) {

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            session.merge(employee);

            transaction.commit();

        } catch (Exception exception) {

            if (transaction != null) {
                transaction.rollback();
            }

            throw exception;
        }
    }

    @Override
    public void delete(Employee employee) {

        Transaction transaction = null;

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            Employee managedEmployee =
                    session.get(Employee.class, employee.getId());

            if (managedEmployee != null) {
                session.remove(managedEmployee);
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