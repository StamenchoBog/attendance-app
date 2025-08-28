--liquibase formatted sql
--changeset stamencho-bogdanovski:create-device-link-request-table

CREATE TABLE IF NOT EXISTS device_link_request (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_index VARCHAR(255) NOT NULL,
    device_id VARCHAR(255) NOT NULL,
    device_name VARCHAR(255),
    device_os VARCHAR(255),
    request_timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING'
        CONSTRAINT chk_device_link_status CHECK (status IN ('PENDING', 'AUTO_APPROVED', 'FLAGGED_FOR_REVIEW', 'MANUALLY_APPROVED', 'REJECTED')),
    notes TEXT,
    reviewed_by VARCHAR(255),
    reviewed_at TIMESTAMP,
    CONSTRAINT fk_device_link_student FOREIGN KEY (student_index) REFERENCES student (student_index) ON DELETE CASCADE
);

-- Essential indexes only
CREATE INDEX IF NOT EXISTS idx_device_link_request_student_index ON device_link_request(student_index);
CREATE INDEX IF NOT EXISTS idx_device_link_request_status ON device_link_request(status);

--rollback DROP TABLE IF EXISTS device_link_request;
