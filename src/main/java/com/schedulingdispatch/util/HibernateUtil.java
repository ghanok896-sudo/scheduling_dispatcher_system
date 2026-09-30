package com.schedulingdispatch.util;

import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

import com.schedulingdispatch.model.AuditHistory;
import com.schedulingdispatch.model.CalendarEvent;
import com.schedulingdispatch.model.Customer;
import com.schedulingdispatch.model.Employee;
import com.schedulingdispatch.model.Schedule;
import com.schedulingdispatch.model.Task;
import com.schedulingdispatch.model.User;

public class HibernateUtil {

    private static final SessionFactory sessionFactory =
            buildSessionFactory();

    private static SessionFactory buildSessionFactory() {

        try {

            Configuration configuration =
                    new Configuration();

            configuration.configure(
                    "hibernate.cfg.xml"
            );

            configuration.addAnnotatedClass(
                    User.class
            );

            configuration.addAnnotatedClass(
                    AuditHistory.class
            );

            configuration.addAnnotatedClass(
                    CalendarEvent.class
            );

            configuration.addAnnotatedClass(
                    Customer.class
            );

            configuration.addAnnotatedClass(
                    Employee.class
            );

            configuration.addAnnotatedClass(
                    Schedule.class
            );

            configuration.addAnnotatedClass(
                    Task.class
            );

            return configuration
                    .buildSessionFactory();

        } catch (Throwable exception) {

            System.err.println(
                    "Initial SessionFactory creation failed."
            );

            exception.printStackTrace();

            throw new ExceptionInInitializerError(
                    exception
            );
        }
    }

    public static SessionFactory getSessionFactory() {

        return sessionFactory;
    }

    public static void shutdown() {

        if (sessionFactory != null
                && !sessionFactory.isClosed()) {

            sessionFactory.close();
        }
    }
}