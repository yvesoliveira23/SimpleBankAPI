import Vapor
import CryptoKit
import Foundation
import Logging

/// Service responsible for user-related operations
struct UserService {
    // MARK: - Private Properties
    
    private var logger: Logger {
        Logger(label: "com.simplebank.userservice")
    }
    
    // MARK: - Types
    
    /// Errors that can occur during user operations
    enum UserServiceError: LocalizedError {
        case negativeBalance
        case encryptionFailed
        case decryptionFailed
        
        var errorDescription: String? {
            switch self {
            case .negativeBalance:
                return "Cannot set negative balance"
            case .encryptionFailed:
                return "Failed to encrypt data"
            case .decryptionFailed:
                return "Failed to decrypt data"
            }
        }
    }
    
    // MARK: - Encryption Operations
    
    /// Decrypts the given CPF using AES-GCM
    /// - Parameter encryptedCpf: The encrypted CPF string in base64 format
    /// - Returns: The decrypted CPF string
    /// - Throws: `UserServiceError.decryptionFailed` if decryption fails
    func decryptCpf(_ encryptedCpf: String) throws -> String {
        guard let data = Data(base64Encoded: encryptedCpf) else {
            throw UserServiceError.decryptionFailed
        }
        
        do {
            // TODO: Implement proper AES-GCM decryption
            // This is a placeholder implementation
            guard let result = String(data: data, encoding: .utf8) else {
                throw UserServiceError.decryptionFailed
            }
            return result
        } catch {
            logger.error("Decryption error: \(error.localizedDescription)")
            throw UserServiceError.decryptionFailed
        }
    }
    
    /// Encrypts the given CPF using AES-GCM
    /// - Parameter cpf: The CPF string to encrypt
    /// - Returns: The encrypted CPF string in base64 format
    /// - Throws: `UserServiceError.encryptionFailed` if encryption fails
    func encryptCpf(_ cpf: String) throws -> String {
        let key = SymmetricKey(size: .bits256)
        let data = Data(cpf.utf8)
        
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            guard let combined = sealedBox.combined else {
                throw UserServiceError.encryptionFailed
            }
            return combined.base64EncodedString()
        } catch {
            logger.error("Encryption error: \(error.localizedDescription)")
            throw UserServiceError.encryptionFailed
        }
    }
    
    /// Verifies if a password matches its hash
    /// - Parameters:
    ///   - password: The password to verify
    ///   - hash: The hash to verify against
    /// - Returns: Boolean indicating if the password matches
    /// - Throws: Bcrypt verification errors
    func verifyPassword(_ password: String, hash: String) throws -> Bool {
        try Bcrypt.verify(password, created: hash)
    }
    
    // MARK: - User Operations
    
    /// Sets the user's balance
    /// - Parameter newBalance: The new balance to set
    /// - Returns: The updated balance
    /// - Throws: `UserServiceError.negativeBalance` if balance is negative
    func setBalance(_ newBalance: Double) throws -> Double {
        guard newBalance >= 0 else {
            logger.warning("Attempted to set negative balance: \(newBalance)")
            throw UserServiceError.negativeBalance
        }
        return newBalance
    }
    
    /// Updates the user's merchant status
    /// - Parameters:
    ///   - isMerchant: The new merchant status
    ///   - user: The user to update
    /// - Returns: The updated user
    func updateMerchantStatus(_ isMerchant: Bool, for user: inout UserModel) -> UserModel {
        user.isMerchant = isMerchant
        return user
    }
}