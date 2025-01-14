import Vapor
import Crypto

struct UserService {
    enum BalanceError: Error {
        case negativeBalance
    }

    // Decrypts the given CPF using AES256
    func decryptCpf(_ encryptedCpf: String) -> String {
        do {
            return try AES256.decrypt(encryptedCpf)
        } catch let error as AES256.Error {
            print("Decryption error for CPF \(encryptedCpf): \(error.localizedDescription)")
            return ""
        } catch let error as CryptoKitError {
            print("CryptoKit error during decryption: \(error.localizedDescription)")
            return ""
        } catch {
            print("Unexpected error during decryption: \(error.localizedDescription)")
            return ""
        }
    }

    // Encrypts the given CPF using AES256
    func encryptCpf(_ cpf: String) throws -> String {
        do {
            return try AES256.encrypt(cpf)
        } catch let error as AES256.Error {
            print("Encryption error for CPF \(cpf): \(error.localizedDescription)")
            var attempts = 0
            let maxAttempts = 3
            while attempts < maxAttempts {
                do {
                    return try AES256.encrypt(cpf)
                } catch {
                    attempts += 1
                    if attempts == maxAttempts {
                        print("Failed to encrypt CPF after \(maxAttempts) attempts: \(error.localizedDescription)")
                        throw error
                    }
                }
            }
        } catch {
            print("Unexpected error during encryption: \(error.localizedDescription)")
            throw error
        }
        print("Failed to encrypt CPF: \(error.localizedDescription)")
        throw error
    }

    // Hashes the given password using Bcrypt
    func setPassword(_ password: String) throws -> String {
        return try Bcrypt.hash(password)
    }

    // Verifies the given password against the stored hash
    func verifyPassword(_ password: String, hash: String) throws -> Bool {
        return try Bcrypt.verify(password, created: hash)
    }

    // Sets the user's balance, ensuring it is not negative
    func setBalance(_ newBalance: Double) throws -> Double {
        if newBalance < 0 {
            print("Attempted to set a negative balance")
            throw BalanceError.negativeBalance
        }
        return newBalance
    }

    // Sets the user's merchant status
    func setIsMerchant(_ isMerchant: Bool, user: UserModel) -> UserModel {
        user.isMerchant = isMerchant
        return user
    }

    // Updates the user's merchant status
    func updateIsMerchant(_ isMerchant: Bool, user: UserModel) {
        user.isMerchant = isMerchant
    }
}