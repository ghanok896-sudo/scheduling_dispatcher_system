package com.schedulingdispatch.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "calendar_events")
public class CalendarEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(
            name = "schedule_id",
            nullable = false,
            unique = true
    )
    private Long scheduleId;

    @Column(
            name = "external_event_id",
            length = 255
    )
    private String externalEventId;

    @Column(
            name = "calendar_provider",
            length = 50
    )
    private String calendarProvider;

    @Column(
            name = "event_title",
            length = 255
    )
    private String eventTitle;

    @Column(
            name = "event_start"
    )
    private LocalDateTime eventStart;

    @Column(
            name = "event_end"
    )
    private LocalDateTime eventEnd;

    @Column(
            name = "sync_status",
            length = 30
    )
    private String syncStatus;

    @Column(
            name = "created_at"
    )
    private LocalDateTime createdAt;

    @Column(
            name = "updated_at"
    )
    private LocalDateTime updatedAt;

    public CalendarEvent() {
    }

    public CalendarEvent(
            Long scheduleId,
            String externalEventId,
            String calendarProvider,
            String eventTitle,
            LocalDateTime eventStart,
            LocalDateTime eventEnd,
            String syncStatus,
            LocalDateTime createdAt,
            LocalDateTime updatedAt) {

        this.scheduleId = scheduleId;
        this.externalEventId = externalEventId;
        this.calendarProvider = calendarProvider;
        this.eventTitle = eventTitle;
        this.eventStart = eventStart;
        this.eventEnd = eventEnd;
        this.syncStatus = syncStatus;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(Long scheduleId) {
        this.scheduleId = scheduleId;
    }

    public String getExternalEventId() {
        return externalEventId;
    }

    public void setExternalEventId(
            String externalEventId) {

        this.externalEventId =
                externalEventId;
    }

    public String getCalendarProvider() {
        return calendarProvider;
    }

    public void setCalendarProvider(
            String calendarProvider) {

        this.calendarProvider =
                calendarProvider;
    }

    public String getEventTitle() {
        return eventTitle;
    }

    public void setEventTitle(
            String eventTitle) {

        this.eventTitle =
                eventTitle;
    }

    public LocalDateTime getEventStart() {
        return eventStart;
    }

    public void setEventStart(
            LocalDateTime eventStart) {

        this.eventStart =
                eventStart;
    }

    public LocalDateTime getEventEnd() {
        return eventEnd;
    }

    public void setEventEnd(
            LocalDateTime eventEnd) {

        this.eventEnd =
                eventEnd;
    }

    public String getSyncStatus() {
        return syncStatus;
    }

    public void setSyncStatus(
            String syncStatus) {

        this.syncStatus =
                syncStatus;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(
            LocalDateTime createdAt) {

        this.createdAt =
                createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(
            LocalDateTime updatedAt) {

        this.updatedAt =
                updatedAt;
    }
}