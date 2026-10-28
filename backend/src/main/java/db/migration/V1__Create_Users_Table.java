package db.migration;

import org.flywaydb.core.api.migration.BaseJavaMigration;
import org.flywaydb.core.api.migration.Context;

import java.sql.Statement;

/**
 * Creates the users table. Java-based Flyway migration: Flyway discovers it
 * automatically because it sits in the package matching spring.flyway.locations
 * (classpath:db/migration -> package db.migration) and follows the
 * V<version>__<description> naming convention.
 */
public class V1__Create_Users_Table extends BaseJavaMigration {

    @Override
    public void migrate(Context context) throws Exception {
        try (Statement statement = context.getConnection().createStatement()) {
            statement.execute("""
                    CREATE TABLE users (
                        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                        name VARCHAR(100) NOT NULL,
                        last_name VARCHAR(100) NOT NULL,
                        email VARCHAR(255) NOT NULL UNIQUE,
                        gender VARCHAR(50),
                        phone VARCHAR(20),
                        birth_date DATE,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    )
                    """);

            statement.execute("CREATE INDEX idx_users_email ON users(email)");
            statement.execute("CREATE INDEX idx_users_created_at ON users(created_at DESC)");

            statement.execute("COMMENT ON TABLE users IS 'Users table containing user profile information'");
            statement.execute("COMMENT ON COLUMN users.id IS 'Unique identifier for the user (UUID)'");
            statement.execute("COMMENT ON COLUMN users.name IS 'User first name'");
            statement.execute("COMMENT ON COLUMN users.last_name IS 'User last name or surname'");
            statement.execute("COMMENT ON COLUMN users.email IS 'User email address (must be unique)'");
            statement.execute("COMMENT ON COLUMN users.gender IS 'User gender'");
            statement.execute("COMMENT ON COLUMN users.phone IS 'User phone number'");
            statement.execute("COMMENT ON COLUMN users.birth_date IS 'User date of birth'");
            statement.execute("COMMENT ON COLUMN users.created_at IS 'Timestamp when user was created'");
            statement.execute("COMMENT ON COLUMN users.updated_at IS 'Timestamp when user was last updated'");
        }
    }
}
