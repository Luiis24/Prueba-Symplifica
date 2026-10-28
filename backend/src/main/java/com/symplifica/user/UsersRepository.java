package com.symplifica.user;

import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

/**
 * Simple Spring Data JDBC repository for the users table.
 */
@Repository
public interface UsersRepository extends ListCrudRepository<User, UUID> {
}
