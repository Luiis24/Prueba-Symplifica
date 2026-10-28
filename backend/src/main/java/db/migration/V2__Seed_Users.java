package db.migration;

import org.flywaydb.core.api.migration.BaseJavaMigration;
import org.flywaydb.core.api.migration.Context;

import java.sql.PreparedStatement;
import java.time.LocalDate;
import java.util.UUID;

/**
 * Seeds the users table with fixed, deterministic data so it can be
 * verified in tests and shown in the frontend table right after startup.
 */
public class V2__Seed_Users extends BaseJavaMigration {

    private static final String INSERT_SQL =
            "INSERT INTO users (id, name, last_name, email, gender, phone, birth_date) VALUES (?, ?, ?, ?, ?, ?, ?)";

    @Override
    public void migrate(Context context) throws Exception {
        try (PreparedStatement statement = context.getConnection().prepareStatement(INSERT_SQL)) {
            insert(statement, "11111111-1111-1111-1111-111111111111", "Juan", "Perez",
                    "juan.perez@symplifica.com", "Male", "+57 300 123 4567", LocalDate.of(1990, 1, 15));

            insert(statement, "22222222-2222-2222-2222-222222222222", "Maria", "Gomez",
                    "maria.gomez@symplifica.com", "Female", "+57 301 234 5678", LocalDate.of(1988, 5, 22));

            insert(statement, "33333333-3333-3333-3333-333333333333", "Carlos", "Rodriguez",
                    "carlos.rodriguez@symplifica.com", "Male", "+57 302 345 6789", LocalDate.of(1995, 11, 30));
        }
    }

    private void insert(PreparedStatement statement, String id, String name, String lastName,
                         String email, String gender, String phone, LocalDate birthDate) throws Exception {
        statement.setObject(1, UUID.fromString(id));
        statement.setString(2, name);
        statement.setString(3, lastName);
        statement.setString(4, email);
        statement.setString(5, gender);
        statement.setString(6, phone);
        statement.setObject(7, birthDate);
        statement.executeUpdate();
    }
}
