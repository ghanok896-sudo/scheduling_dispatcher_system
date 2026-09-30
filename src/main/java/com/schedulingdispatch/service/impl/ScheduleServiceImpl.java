package com.schedulingdispatch.service.impl;

import com.schedulingdispatch.dao.ScheduleDAO;
import com.schedulingdispatch.dao.impl.ScheduleDAOImpl;
import com.schedulingdispatch.model.Schedule;
import com.schedulingdispatch.service.ScheduleService;
import com.schedulingdispatch.util.HibernateUtil;

import org.hibernate.Session;

import java.time.LocalDateTime;
import java.util.List;

public class ScheduleServiceImpl implements ScheduleService {

    private final ScheduleDAO scheduleDAO;

    public ScheduleServiceImpl() {
        this.scheduleDAO = new ScheduleDAOImpl();
    }

    @Override
    public List<Schedule> findAll() {
        return scheduleDAO.findAll();
    }

    @Override
    public List<Schedule> search(String keyword) {
        return scheduleDAO.search(keyword);
    }

    @Override
    public Schedule findById(Long id) {

        if (id == null) {
            return null;
        }

        return scheduleDAO.findById(id);
    }

    @Override
    public void createSchedule(Schedule schedule) {

        if (schedule == null) {
            throw new IllegalArgumentException(
                    "Schedule information is required."
            );
        }

        validateSchedule(schedule);

        if (schedule.getCreatedAt() == null) {
            schedule.setCreatedAt(LocalDateTime.now());
        }

        if (schedule.getUpdatedAt() == null) {
            schedule.setUpdatedAt(LocalDateTime.now());
        }

        if (schedule.getPriority() == null
                || schedule.getPriority().trim().isEmpty()) {

            schedule.setPriority("MEDIUM");
        }

        if (schedule.getStatus() == null
                || schedule.getStatus().trim().isEmpty()) {

            schedule.setStatus("SCHEDULED");
        }

        schedule.setPriority(
                schedule.getPriority().trim().toUpperCase()
        );

        schedule.setStatus(
                schedule.getStatus().trim().toUpperCase()
        );

        checkEmployeeOverlap(schedule);

        /*
         * Save schedule first.
         * Hibernate generates the schedule ID.
         */
        scheduleDAO.save(schedule);

        /*
         * After successful schedule creation:
         *
         * 1. Create audit history
         * 2. Create internal calendar event
         */
        createAuditHistory(
                schedule,
                "CREATED",
                "N/A",
                schedule.getStatus(),
                "Schedule #" + schedule.getId()
                        + " was created successfully."
        );

        createCalendarEvent(schedule);
    }

    @Override
    public void updateSchedule(Schedule schedule) {

        if (schedule == null || schedule.getId() == null) {
            throw new IllegalArgumentException(
                    "Schedule information is required."
            );
        }

        Schedule existingSchedule =
                scheduleDAO.findById(schedule.getId());

        if (existingSchedule == null) {
            throw new IllegalArgumentException(
                    "Schedule not found."
            );
        }

        /*
         * Preserve existing values when the update request
         * does not provide them.
         */
        if (schedule.getCreatedAt() == null) {
            schedule.setCreatedAt(
                    existingSchedule.getCreatedAt()
            );
        }

        if (schedule.getStatus() == null
                || schedule.getStatus().trim().isEmpty()) {

            schedule.setStatus(
                    existingSchedule.getStatus()
            );
        }

        if (schedule.getPriority() == null
                || schedule.getPriority().trim().isEmpty()) {

            schedule.setPriority(
                    existingSchedule.getPriority()
            );
        }

        validateSchedule(schedule);

        schedule.setPriority(
                schedule.getPriority().trim().toUpperCase()
        );

        schedule.setStatus(
                schedule.getStatus().trim().toUpperCase()
        );

        schedule.setUpdatedAt(LocalDateTime.now());

        checkEmployeeOverlap(schedule);

        scheduleDAO.update(schedule);

        /*
         * Audit the update.
         */
        String action = existingSchedule.getStatus()
                .equalsIgnoreCase(schedule.getStatus())
                ? "UPDATED"
                : "STATUS_CHANGED";

        createAuditHistory(
                schedule,
                action,
                existingSchedule.getStatus(),
                schedule.getStatus(),
                "Schedule #" + schedule.getId()
                        + " was updated successfully."
        );

        /*
         * Keep calendar event synchronized with the
         * latest schedule information.
         */
        updateCalendarEvent(schedule);
    }

    @Override
    public void deleteSchedule(Long id) {

        if (id == null) {
            throw new IllegalArgumentException(
                    "Schedule ID is required."
            );
        }

        Schedule schedule = scheduleDAO.findById(id);

        if (schedule == null) {
            throw new IllegalArgumentException(
                    "Schedule not found."
            );
        }

        /*
         * Record the deletion before deleting the schedule.
         */
        createAuditHistory(
                schedule,
                "DELETED",
                schedule.getStatus(),
                "DELETED",
                "Schedule #" + schedule.getId()
                        + " was deleted."
        );

        /*
         * Remove related calendar event first.
         */
        deleteCalendarEvent(schedule.getId());

        /*
         * Delete schedule.
         */
        scheduleDAO.delete(schedule);
    }

    @Override
    public void changeStatus(Long id, String status) {

        if (id == null) {
            throw new IllegalArgumentException(
                    "Schedule ID is required."
            );
        }

        if (status == null || status.trim().isEmpty()) {
            throw new IllegalArgumentException(
                    "Schedule status is required."
            );
        }

        String normalizedStatus =
                status.trim().toUpperCase();

        if (!normalizedStatus.equals("SCHEDULED")
                && !normalizedStatus.equals("IN_PROGRESS")
                && !normalizedStatus.equals("COMPLETED")
                && !normalizedStatus.equals("CANCELLED")) {

            throw new IllegalArgumentException(
                    "Invalid schedule status."
            );
        }

        Schedule schedule = scheduleDAO.findById(id);

        if (schedule == null) {
            throw new IllegalArgumentException(
                    "Schedule not found."
            );
        }

        String oldStatus = schedule.getStatus();

        schedule.setStatus(normalizedStatus);
        schedule.setUpdatedAt(LocalDateTime.now());

        scheduleDAO.update(schedule);

        /*
         * Record status change in audit history.
         */
        createAuditHistory(
                schedule,
                "STATUS_CHANGED",
                oldStatus,
                normalizedStatus,
                "Schedule #" + schedule.getId()
                        + " status changed from "
                        + oldStatus
                        + " to "
                        + normalizedStatus
                        + "."
        );

        /*
         * Keep calendar event synchronized.
         */
        if ("CANCELLED".equals(normalizedStatus)) {
            updateCalendarEvent(schedule);
        } else {
            updateCalendarEvent(schedule);
        }
    }

    /*
     * ============================================================
     * VALIDATION
     * ============================================================
     */

    private void validateSchedule(Schedule schedule) {

        if (schedule.getTaskId() == null) {
            throw new IllegalArgumentException(
                    "Task is required."
            );
        }

        if (schedule.getCustomerId() == null) {
            throw new IllegalArgumentException(
                    "Customer is required."
            );
        }

        if (schedule.getScheduledStart() == null) {
            throw new IllegalArgumentException(
                    "Scheduled start date and time are required."
            );
        }

        if (schedule.getScheduledEnd() == null) {
            throw new IllegalArgumentException(
                    "Scheduled end date and time are required."
            );
        }

        if (!schedule.getScheduledEnd()
                .isAfter(schedule.getScheduledStart())) {

            throw new IllegalArgumentException(
                    "Scheduled end must be after scheduled start."
            );
        }

        String priority = schedule.getPriority();

        if (priority != null && !priority.trim().isEmpty()) {

            priority = priority.trim().toUpperCase();

            if (!priority.equals("LOW")
                    && !priority.equals("MEDIUM")
                    && !priority.equals("HIGH")
                    && !priority.equals("URGENT")) {

                throw new IllegalArgumentException(
                        "Invalid schedule priority."
                );
            }

            schedule.setPriority(priority);
        }

        String status = schedule.getStatus();

        if (status != null && !status.trim().isEmpty()) {

            status = status.trim().toUpperCase();

            if (!status.equals("SCHEDULED")
                    && !status.equals("IN_PROGRESS")
                    && !status.equals("COMPLETED")
                    && !status.equals("CANCELLED")) {

                throw new IllegalArgumentException(
                        "Invalid schedule status."
                );
            }

            schedule.setStatus(status);
        }

        if (schedule.getNotes() != null) {

            String notes = schedule.getNotes().trim();

            if (notes.length() > 500) {
                throw new IllegalArgumentException(
                        "Notes must not exceed 500 characters."
                );
            }

            schedule.setNotes(
                    notes.isEmpty() ? null : notes
            );
        }
    }

    /*
     * ============================================================
     * EMPLOYEE OVERLAP VALIDATION
     * ============================================================
     */

    private void checkEmployeeOverlap(Schedule schedule) {

        /*
         * Employee assignment is optional.
         */
        if (schedule.getEmployeeId() == null) {
            return;
        }

        /*
         * Cancelled schedules do not need overlap validation.
         */
        if ("CANCELLED".equalsIgnoreCase(schedule.getStatus())) {
            return;
        }

        boolean overlapping =
                scheduleDAO.hasEmployeeOverlap(
                        schedule.getEmployeeId(),
                        schedule.getScheduledStart(),
                        schedule.getScheduledEnd(),
                        schedule.getId()
                );

        if (overlapping) {
            throw new IllegalArgumentException(
                    "The selected employee already has an overlapping schedule."
            );
        }
    }

    /*
     * ============================================================
     * AUDIT HISTORY
     * ============================================================
     */

    private void createAuditHistory(
            Schedule schedule,
            String action,
            String oldStatus,
            String newStatus,
            String description) {

        if (schedule == null || schedule.getId() == null) {
            return;
        }

        TransactionWrapper transactionWrapper =
                new TransactionWrapper();

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transactionWrapper.begin(session);

            session.createNativeMutationQuery(
                    """
                    INSERT INTO audit_history
                    (
                        schedule_id,
                        user_id,
                        action,
                        old_status,
                        new_status,
                        description
                    )
                    VALUES
                    (
                        :scheduleId,
                        :userId,
                        :action,
                        :oldStatus,
                        :newStatus,
                        :description
                    )
                    """
            )
            .setParameter("scheduleId", schedule.getId())
            .setParameter("userId", schedule.getCreatedBy())
            .setParameter("action", action)
            .setParameter("oldStatus", oldStatus)
            .setParameter("newStatus", newStatus)
            .setParameter("description", description)
            .executeUpdate();

            transactionWrapper.commit();

        } catch (Exception exception) {

            transactionWrapper.rollback();

            /*
             * Audit failure should not hide the already completed
             * schedule operation.
             */
            System.err.println(
                    "Audit history creation failed: "
                            + exception.getMessage()
            );
        }
    }

    /*
     * ============================================================
     * CALENDAR EVENT - CREATE
     * ============================================================
     */

    private void createCalendarEvent(Schedule schedule) {

        if (schedule == null || schedule.getId() == null) {
            return;
        }

        String externalEventId =
                "INTERNAL-SCHEDULE-" + schedule.getId();

        TransactionWrapper transactionWrapper =
                new TransactionWrapper();

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transactionWrapper.begin(session);

            session.createNativeMutationQuery(
                    """
                    INSERT INTO calendar_events
                    (
                        schedule_id,
                        external_event_id,
                        calendar_provider,
                        event_title,
                        event_start,
                        event_end,
                        sync_status
                    )
                    VALUES
                    (
                        :scheduleId,
                        :externalEventId,
                        :calendarProvider,
                        :eventTitle,
                        :eventStart,
                        :eventEnd,
                        :syncStatus
                    )
                    """
            )
            .setParameter("scheduleId", schedule.getId())
            .setParameter(
                    "externalEventId",
                    externalEventId
            )
            .setParameter(
                    "calendarProvider",
                    "INTERNAL"
            )
            .setParameter(
                    "eventTitle",
                    "Schedule #" + schedule.getId()
            )
            .setParameter(
                    "eventStart",
                    schedule.getScheduledStart()
            )
            .setParameter(
                    "eventEnd",
                    schedule.getScheduledEnd()
            )
            .setParameter(
                    "syncStatus",
                    "PENDING"
            )
            .executeUpdate();

            transactionWrapper.commit();

        } catch (Exception exception) {

            transactionWrapper.rollback();

            System.err.println(
                    "Calendar event creation failed: "
                            + exception.getMessage()
            );
        }
    }

    /*
     * ============================================================
     * CALENDAR EVENT - UPDATE
     * ============================================================
     */

    private void updateCalendarEvent(Schedule schedule) {

        if (schedule == null || schedule.getId() == null) {
            return;
        }

        String externalEventId =
                "INTERNAL-SCHEDULE-" + schedule.getId();

        TransactionWrapper transactionWrapper =
                new TransactionWrapper();

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transactionWrapper.begin(session);

            int updatedRows =
                    session.createNativeMutationQuery(
                            """
                            UPDATE calendar_events
                            SET
                                external_event_id = :externalEventId,
                                calendar_provider = :calendarProvider,
                                event_title = :eventTitle,
                                event_start = :eventStart,
                                event_end = :eventEnd,
                                sync_status = :syncStatus
                            WHERE schedule_id = :scheduleId
                            """
                    )
                    .setParameter(
                            "externalEventId",
                            externalEventId
                    )
                    .setParameter(
                            "calendarProvider",
                            "INTERNAL"
                    )
                    .setParameter(
                            "eventTitle",
                            "Schedule #" + schedule.getId()
                    )
                    .setParameter(
                            "eventStart",
                            schedule.getScheduledStart()
                    )
                    .setParameter(
                            "eventEnd",
                            schedule.getScheduledEnd()
                    )
                    .setParameter(
                            "syncStatus",
                            "PENDING"
                    )
                    .setParameter(
                            "scheduleId",
                            schedule.getId()
                    )
                    .executeUpdate();

            /*
             * If an older schedule does not have a calendar event,
             * create it instead.
             */
            if (updatedRows == 0) {
                session.createNativeMutationQuery(
                        """
                        INSERT INTO calendar_events
                        (
                            schedule_id,
                            external_event_id,
                            calendar_provider,
                            event_title,
                            event_start,
                            event_end,
                            sync_status
                        )
                        VALUES
                        (
                            :scheduleId,
                            :externalEventId,
                            :calendarProvider,
                            :eventTitle,
                            :eventStart,
                            :eventEnd,
                            :syncStatus
                        )
                        """
                )
                .setParameter(
                        "scheduleId",
                        schedule.getId()
                )
                .setParameter(
                        "externalEventId",
                        externalEventId
                )
                .setParameter(
                        "calendarProvider",
                        "INTERNAL"
                )
                .setParameter(
                        "eventTitle",
                        "Schedule #" + schedule.getId()
                )
                .setParameter(
                        "eventStart",
                        schedule.getScheduledStart()
                )
                .setParameter(
                        "eventEnd",
                        schedule.getScheduledEnd()
                )
                .setParameter(
                        "syncStatus",
                        "PENDING"
                )
                .executeUpdate();
            }

            transactionWrapper.commit();

        } catch (Exception exception) {

            transactionWrapper.rollback();

            System.err.println(
                    "Calendar event update failed: "
                            + exception.getMessage()
            );
        }
    }

    /*
     * ============================================================
     * CALENDAR EVENT - DELETE
     * ============================================================
     */

    private void deleteCalendarEvent(Long scheduleId) {

        if (scheduleId == null) {
            return;
        }

        TransactionWrapper transactionWrapper =
                new TransactionWrapper();

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            transactionWrapper.begin(session);

            session.createNativeMutationQuery(
                    """
                    DELETE FROM calendar_events
                    WHERE schedule_id = :scheduleId
                    """
            )
            .setParameter(
                    "scheduleId",
                    scheduleId
            )
            .executeUpdate();

            transactionWrapper.commit();

        } catch (Exception exception) {

            transactionWrapper.rollback();

            System.err.println(
                    "Calendar event deletion failed: "
                            + exception.getMessage()
            );
        }
    }

    /*
     * ============================================================
     * SIMPLE TRANSACTION WRAPPER
     * ============================================================
     *
     * Keeps transaction handling inside this service without
     * changing your existing DAO classes.
     */

    private static class TransactionWrapper {

        private org.hibernate.Transaction transaction;

        void begin(Session session) {
            transaction = session.beginTransaction();
        }

        void commit() {
            if (transaction != null
                    && transaction.isActive()) {
                transaction.commit();
            }
        }

        void rollback() {
            if (transaction != null
                    && transaction.isActive()) {
                transaction.rollback();
            }
        }
    }
}