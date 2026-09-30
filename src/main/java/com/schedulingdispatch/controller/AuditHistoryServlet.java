package com.schedulingdispatch.controller;

import com.schedulingdispatch.model.AuditHistory;
import com.schedulingdispatch.model.User;
import com.schedulingdispatch.service.AuditHistoryService;
import com.schedulingdispatch.service.impl.AuditHistoryServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet("/audit-history")
public class AuditHistoryServlet
        extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private AuditHistoryService auditHistoryService;

    @Override
    public void init()
            throws ServletException {

        auditHistoryService =
                new AuditHistoryServiceImpl();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        User loggedInUser =
                getLoggedInUser(session);

        if (loggedInUser == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login"
            );

            return;
        }

        if (!"ADMIN".equalsIgnoreCase(
                loggedInUser.getRole())) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied."
            );

            return;
        }

        String keyword =
                request.getParameter("keyword");

        try {

            List<AuditHistory> auditHistoryList;

            if (keyword == null
                    || keyword.trim().isEmpty()) {

                auditHistoryList =
                        auditHistoryService.findAll();

            } else {

                auditHistoryList =
                        auditHistoryService.search(
                                keyword
                        );
            }

            request.setAttribute(
                    "auditHistoryList",
                    auditHistoryList
            );

            request.setAttribute(
                    "keyword",
                    keyword
            );

        } catch (Exception exception) {

            exception.printStackTrace();

            request.setAttribute(
                    "auditHistoryList",
                    Collections.emptyList()
            );

            request.setAttribute(
                    "error",
                    "Unable to load audit history."
            );
        }

        request.getRequestDispatcher(
                "/audit-history.jsp"
        ).forward(
                request,
                response
        );
    }

    private User getLoggedInUser(
            HttpSession session) {

        if (session == null) {
            return null;
        }

        Object value =
                session.getAttribute(
                        "loggedInUser"
                );

        if (value instanceof User) {
            return (User) value;
        }

        return null;
    }
}