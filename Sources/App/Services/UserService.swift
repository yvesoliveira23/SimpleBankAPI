import Vapor
import Crypto

/// Service responsible for user-related operations
struct UserService {
    // MARK: - Types
    
    /// Errors that can occur during balance operations
    enum BalanceError: LocalizedError {
        case negativeBalance
        
        var errorDescription: String? {
            switch self {
            case .negativeBalance:
                return "Cannot set negative balance"
            }
        }
    }
    
    // MARK: - Encryption Operations
    
    /// Decrypts the given CPF using AES256
    /// - Parameter encryptedCpf: The encrypted CPF string
    /// - Returns: The decrypted CPF string
    func decryptCpf(_ encryptedCpf: String) -> String {
        do {
            return try AES256.decrypt(encryptedCpf)
        } catch let error as AES256.Error {
            logger.error("Decryption error: \(error.localizedDescription)")
            return ""
        } catch let error as CryptoKitError {
            logger.error("CryptoKit error: \(error.localizedDescription)")
            return ""
        } catch {
            logger.error("Unexpected error: \(error.localizedDescription)")
            return ""
        }
    }
    
    /// Encrypts the given CPF using AES256
    /// - Parameter cpf: The CPF string to encrypt
    /// - Throws: Encryption related errors
    /// - Returns: The encrypted CPF string
    func encryptCpf(_ cpf: String) throws -> String {
        do {
            return try AES256.encrypt(cpf)
        } catch {
            logger.error("Encryption error: \(error.localizedDescription)")
            var attempts = 0
            let maxAttempts = 3
            
            while attempts < maxAttempts {
                do {
                    return try AES256.encrypt(cpf)
                } catch {
                    attempts += 1
                    if attempts == maxAttempts {
                        logger.critical("Failed to encrypt after \(maxAttempts) attempts")
                        throw error
                    }
                }
            }
            
            throw error
        }
    }
    
    // MARK: - Password Operations
    
    /// Hashes the given password using Bcrypt
    /// - Parameter password: The password to hash
    /// - Throws: Hashing related errors
    /// - Returns: The hashed password
    func setPassword(_ password: String) throws -> String {
        try Bcrypt.hash(password)
    }
    
    /// Verifies the given password against a hash
    /// - Parameters:
    ///   - password: The password to verify
    ///   - hash: The hash to verify against
    /// - Throws: Verification related errors
    /// - Returns: Whether the password matches the hash
    func verifyPassword(_ password: String, hash: String) throws -> Bool {
        try Bcrypt.verify(password, created: hash)
    }
    
    // MARK: - User Operations
    
    /// Sets the user's balance
    /// - Parameter newBalance: The new balance to set
    /// - Throws: BalanceError if balance is negative
    /// - Returns: The new balance
    func setBalance(_ newBalance: Double) throws -> Double {
        guard newBalance >= 0 else {
            logger.warning("Attempted to set negative balance: \(newBalance)")
            throw BalanceError.negativeBalance
        }
        return newBalance
    }
    
    /// Updates the user's merchant status
    /// - Parameters:
    ///   - isMerchant: The new merchant status
    ///   - user: The user to update
    /// - Returns: The updated user
    func setIsMerchant(_ isMerchant: Bool, user: UserModel) -> UserModel {
        user.isMerchant = isMerchant
        return user
    }
}

// MARK: - Private Properties

private extension UserService {
    var logger: Logger {
        Logger(label: "com.simplebank.userservice")
    }
}