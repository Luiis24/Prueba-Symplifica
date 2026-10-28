package com.symplifica.user;

import com.symplifica.backend.BackendApplication;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Boots the real Spring context against a throwaway PostgreSQL container,
 * lets Flyway run V1 (schema) and V2 (seed data) - both Java migrations -
 * and verifies the seeded users exist with the expected data.
 */
@SpringBootTest(classes = BackendApplication.class)
@Testcontainers
class UsersServiceTest {

    @Container
    static final PostgreSQLContainer<?> POSTGRES = new PostgreSQLContainer<>("postgres:16-alpine")
            .withDatabaseName("prueba_db")
            .withUsername("prueba_user")
            .withPassword("prueba_password");

    @DynamicPropertySource
    static void datasourceProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", POSTGRES::getJdbcUrl);
        registry.add("spring.datasource.username", POSTGRES::getUsername);
        registry.add("spring.datasource.password", POSTGRES::getPassword);
    }

    @Autowired
    private UsersService usersService;

    @Test
    void seededUsersExistWithExpectedData() {
        List<User> users = usersService.getAllUsers();

        assertThat(users).hasSize(3);

        User juan = usersService.getUserById(UUID.fromString("11111111-1111-1111-1111-111111111111"))
                .orElseThrow();
        assertThat(juan.name()).isEqualTo("Juan");
        assertThat(juan.lastName()).isEqualTo("Perez");
        assertThat(juan.email()).isEqualTo("juan.perez@symplifica.com");
        assertThat(juan.gender()).isEqualTo("Male");
        assertThat(juan.phone()).isEqualTo("+57 300 123 4567");
        assertThat(juan.birthDate()).isEqualTo(LocalDate.of(1990, 1, 15));

        User maria = usersService.getUserById(UUID.fromString("22222222-2222-2222-2222-222222222222"))
                .orElseThrow();
        assertThat(maria.name()).isEqualTo("Maria");
        assertThat(maria.lastName()).isEqualTo("Gomez");
        assertThat(maria.email()).isEqualTo("maria.gomez@symplifica.com");
        assertThat(maria.birthDate()).isEqualTo(LocalDate.of(1988, 5, 22));

        User carlos = usersService.getUserById(UUID.fromString("33333333-3333-3333-3333-333333333333"))
                .orElseThrow();
        assertThat(carlos.name()).isEqualTo("Carlos");
        assertThat(carlos.lastName()).isEqualTo("Rodriguez");
        assertThat(carlos.email()).isEqualTo("carlos.rodriguez@symplifica.com");
        assertThat(carlos.birthDate()).isEqualTo(LocalDate.of(1995, 11, 30));
    }
}
