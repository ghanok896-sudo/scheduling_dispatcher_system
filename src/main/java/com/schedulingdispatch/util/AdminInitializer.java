package com.schedulingdispatch.util;

import com.schedulingdispatch.model.User;
import com.schedulingdispatch.service.UserService;
import com.schedulingdispatch.service.impl.UserServiceImpl;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class AdminInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent event) {

        try {

            UserService userService = new UserServiceImpl();

            String username = "admin";

            if (userService.findByUsername(username) == null) {

                User admin = new User(
                        "admin",
                        "Admin@123",
                        "System Administrator",
                        "admin@scheduling.com",
                        "9999999999",
                        "ADMIN",
                        "ACTIVE"
                );

                userService.createUser(admin);

                System.out.println(
                        "Default admin user created successfully."
                );

                System.out.println(
                        "Username: admin"
                );

                System.out.println(
                        "Password: Admin@123"
                );

            } else {

                System.out.println(
                        "Default admin user already exists."
                );
            }

        } catch (Exception exception) {

            System.err.println(
                    "Unable to initialize default admin user."
            );

            exception.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {
        // No action required.
    }
}