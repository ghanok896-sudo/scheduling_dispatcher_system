package com.schedulingdispatch.listener;

import com.mysql.cj.jdbc.AbandonedConnectionCleanupThread;
import com.schedulingdispatch.util.HibernateUtil;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class ApplicationContextListener
        implements ServletContextListener {

    @Override
    public void contextInitialized(
            ServletContextEvent event) {

        /*
         * Application startup.
         *
         * Hibernate initializes when HibernateUtil
         * is first accessed by the application.
         */
    }

    @Override
    public void contextDestroyed(
            ServletContextEvent event) {

        /*
         * Close Hibernate SessionFactory first.
         */
        try {

            HibernateUtil.shutdown();

        } catch (Exception exception) {

            exception.printStackTrace();
        }

        /*
         * Stop MySQL Connector/J cleanup thread.
         *
         * This prevents messages such as:
         *
         * "Illegal access: this web application instance
         * has been stopped already."
         */
        try {

            AbandonedConnectionCleanupThread
                    .checkedShutdown();

        } catch (Exception exception) {

            exception.printStackTrace();
        }
    }
}