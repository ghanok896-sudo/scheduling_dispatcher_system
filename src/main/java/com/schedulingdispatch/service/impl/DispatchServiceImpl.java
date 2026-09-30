package com.schedulingdispatch.service.impl;

import com.schedulingdispatch.dao.DispatchDAO;
import com.schedulingdispatch.dao.impl.DispatchDAOImpl;
import com.schedulingdispatch.model.Dispatch;
import com.schedulingdispatch.model.Employee;
import com.schedulingdispatch.model.Schedule;
import com.schedulingdispatch.service.DispatchService;
import com.schedulingdispatch.util.HibernateUtil;

import org.hibernate.Session;

import java.time.LocalDateTime;
import java.util.List;

public class DispatchServiceImpl implements DispatchService {

    private final DispatchDAO dispatchDAO;

    public DispatchServiceImpl() {
        this.dispatchDAO = new DispatchDAOImpl();
    }

    @Override
    public List<Dispatch> findAll() {
        return dispatchDAO.findAll();
    }

    @Override
    public List<Dispatch> search(String keyword) {

        if (keyword == null || keyword.trim().isEmpty()) {
            return dispatchDAO.findAll();
        }

        return dispatchDAO.search(keyword.trim());
    }

    @Override
    public Dispatch findById(Long id) {

        if (id == null || id <= 0) {
            return null;
        }

        return dispatchDAO.findById(id);
    }

    @Override
    public Dispatch findByScheduleId(Long scheduleId) {

        if (scheduleId == null || scheduleId <= 0) {
            return null;
        }

        return dispatchDAO.findByScheduleId(scheduleId);
    }

    @Override
    public void createDispatch(Dispatch dispatch) {

        if (dispatch == null) {
            throw new IllegalArgumentException(
                    "Dispatch information is required."
            );
        }

        validateDispatch(dispatch);

        if (dispatchDAO.existsByScheduleId(
                dispatch.getScheduleId())) {

            throw new IllegalArgumentException(
                    "A dispatch already exists for this schedule."
            );
        }

        if (isBlank(dispatch.getDispatchStatus())) {
            dispatch.setDispatchStatus("ASSIGNED");
        }

        dispatch.setDispatchStatus(
                dispatch.getDispatchStatus()
                        .trim()
                        .toUpperCase()
        );

        validateStatus(dispatch.getDispatchStatus());

        if (dispatch.getCreatedAt() == null) {
            dispatch.setCreatedAt(LocalDateTime.now());
        }

        dispatch.setUpdatedAt(LocalDateTime.now());

        dispatchDAO.save(dispatch);
    }

    @Override
    public void updateDispatch(Dispatch dispatch) {

        if (dispatch == null || dispatch.getId() == null) {
            throw new IllegalArgumentException(
                    "Valid dispatch information is required."
            );
        }

        Dispatch existing =
                dispatchDAO.findById(dispatch.getId());

        if (existing == null) {
            throw new IllegalArgumentException(
                    "Dispatch not found."
            );
        }

        validateDispatch(dispatch);

        if (isBlank(dispatch.getDispatchStatus())) {
            dispatch.setDispatchStatus(
                    existing.getDispatchStatus()
            );
        }

        dispatch.setDispatchStatus(
                dispatch.getDispatchStatus()
                        .trim()
                        .toUpperCase()
        );

        validateStatus(dispatch.getDispatchStatus());

        if (dispatch.getCreatedAt() == null) {
            dispatch.setCreatedAt(
                    existing.getCreatedAt()
            );
        }

        dispatch.setUpdatedAt(LocalDateTime.now());

        dispatchDAO.update(dispatch);
    }

    @Override
    public void changeStatus(Long id, String status) {

        if (id == null || id <= 0) {
            throw new IllegalArgumentException(
                    "Invalid dispatch ID."
            );
        }

        if (isBlank(status)) {
            throw new IllegalArgumentException(
                    "Dispatch status is required."
            );
        }

        String newStatus =
                status.trim().toUpperCase();

        validateStatus(newStatus);

        Dispatch dispatch =
                dispatchDAO.findById(id);

        if (dispatch == null) {
            throw new IllegalArgumentException(
                    "Dispatch not found."
            );
        }

        LocalDateTime now = LocalDateTime.now();

        dispatch.setDispatchStatus(newStatus);

        if ("DISPATCHED".equals(newStatus)
                && dispatch.getDispatchedAt() == null) {

            dispatch.setDispatchedAt(now);
        }

        if ("IN_PROGRESS".equals(newStatus)
                && dispatch.getStartedAt() == null) {

            dispatch.setStartedAt(now);
        }

        if ("COMPLETED".equals(newStatus)
                && dispatch.getCompletedAt() == null) {

            dispatch.setCompletedAt(now);

            if (dispatch.getStartedAt() == null) {
                dispatch.setStartedAt(now);
            }
        }

        dispatch.setUpdatedAt(now);

        dispatchDAO.update(dispatch);
    }

    @Override
    public void deleteDispatch(Long id) {

        if (id == null || id <= 0) {
            throw new IllegalArgumentException(
                    "Invalid dispatch ID."
            );
        }

        Dispatch dispatch =
                dispatchDAO.findById(id);

        if (dispatch == null) {
            throw new IllegalArgumentException(
                    "Dispatch not found."
            );
        }

        dispatchDAO.delete(dispatch);
    }

    private void validateDispatch(Dispatch dispatch) {

        if (dispatch.getScheduleId() == null
                || dispatch.getScheduleId() <= 0) {

            throw new IllegalArgumentException(
                    "Valid schedule is required."
            );
        }

        if (dispatch.getEmployeeId() == null
                || dispatch.getEmployeeId() <= 0) {

            throw new IllegalArgumentException(
                    "Valid employee is required."
            );
        }

        validateSchedule(
                dispatch.getScheduleId()
        );

        validateEmployee(
                dispatch.getEmployeeId()
        );

        if (!isBlank(dispatch.getRemarks())
                && dispatch.getRemarks().trim().length() > 1000) {

            throw new IllegalArgumentException(
                    "Remarks cannot exceed 1000 characters."
            );
        }
    }

    private void validateSchedule(Long scheduleId) {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            Schedule schedule =
                    session.get(
                            Schedule.class,
                            scheduleId
                    );

            if (schedule == null) {
                throw new IllegalArgumentException(
                        "Selected schedule does not exist."
                );
            }

            if ("CANCELLED".equalsIgnoreCase(
                    schedule.getStatus())) {

                throw new IllegalArgumentException(
                        "A cancelled schedule cannot be dispatched."
                );
            }
        }
    }

    private void validateEmployee(Long employeeId) {

        try (Session session =
                     HibernateUtil.getSessionFactory().openSession()) {

            Employee employee =
                    session.get(
                            Employee.class,
                            employeeId
                    );

            if (employee == null) {
                throw new IllegalArgumentException(
                        "Selected employee does not exist."
                );
            }

            if (!"ACTIVE".equalsIgnoreCase(
                    employee.getStatus())) {

                throw new IllegalArgumentException(
                        "Selected employee is not active."
                );
            }
        }
    }

    private void validateStatus(String status) {

        String value =
                status.trim().toUpperCase();

        if (!value.equals("ASSIGNED")
                && !value.equals("DISPATCHED")
                && !value.equals("IN_PROGRESS")
                && !value.equals("COMPLETED")
                && !value.equals("CANCELLED")) {

            throw new IllegalArgumentException(
                    "Invalid dispatch status."
            );
        }
    }

    private boolean isBlank(String value) {

        return value == null
                || value.trim().isEmpty();
    }
}