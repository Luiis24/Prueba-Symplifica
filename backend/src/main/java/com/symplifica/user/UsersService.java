package com.symplifica.user;

import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Simple service layer over the users repository.
 */
@Service
public class UsersService {

    private final UsersRepository usersRepository;

    public UsersService(UsersRepository usersRepository) {
        this.usersRepository = usersRepository;
    }

    public List<User> getAllUsers() {
        return usersRepository.findAll();
    }

    public Optional<User> getUserById(UUID id) {
        return usersRepository.findById(id);
    }

    public User createUser(User user) {
        return usersRepository.save(user);
    }

    public Optional<User> updateUser(UUID id, User updatedUser) {
        return usersRepository.findById(id)
                .map(existingUser -> {
                    User userToSave = new User(
                        id,
                        updatedUser.name(),
                        updatedUser.lastName(),
                        updatedUser.email(),
                        updatedUser.gender(),
                        updatedUser.phone(),
                        updatedUser.birthDate(),
                        existingUser.createdAt(),
                        LocalDateTime.now()
                    );   
                    return usersRepository.save(userToSave);
                });
    }

    public void deleteUser(UUID id) {
        usersRepository.deleteById(id);
    }

}
