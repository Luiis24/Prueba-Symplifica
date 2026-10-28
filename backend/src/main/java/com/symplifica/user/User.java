package com.symplifica.user;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Immutable Spring Data JDBC entity for the "users" table.
 * Spring Data JDBC maps rows straight into the record's canonical
 * constructor, so there is no separate mutable persistence class needed.
 */
@Table("users")
public record User(
        @Id UUID id,
        String name,
        @Column("last_name") String lastName,
        String email,
        String gender,
        String phone,
        @Column("birth_date") LocalDate birthDate,
        @Column("created_at") LocalDateTime createdAt,
        @Column("updated_at") LocalDateTime updatedAt
) {
}
