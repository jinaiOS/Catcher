//
//  FirebaseManager.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation
import FirebaseAuth

class FirebaseManager {
    private let auth = Auth.auth()
    
    typealias AuthCompletion = (FirebaseErrors?) -> Void
    
    func createUsers(email: String, password: String, completion: @escaping AuthCompletion) {
        auth.createUser(withEmail: email, password: password) { authResult, error in
            self.handleAuthResult(authResult, error: error, completion: completion)
        }
    }
    
    func emailLogIn(email: String, password: String, completion: @escaping AuthCompletion) {
        auth.signIn(withEmail: email, password: password) { authResult, error in
            self.handleAuthResult(authResult, error: error, completion: completion)
        }
    }
    
    func sendEmailForChangePW(email: String) async -> Bool {
        do {
            try await auth.sendPasswordReset(withEmail: email)
            return true
        } catch {
            CommonUtil.print(output:"error: \(error.localizedDescription)")
            return false
        }
    }
    
    var checkLoginState: Bool {
        if auth.currentUser != nil {
            return true
        } else { return false }
    }
    
    var logOut: Void {
        do {
            try auth.signOut()
        } catch {
            CommonUtil.print(output:"error: \(error.localizedDescription)")
        }
    }
    
    var getUserEmail: String {
        guard let currentUserEmail = auth.currentUser?.email else { return "익명" }
        return currentUserEmail
    }
    
    var getUID: String? {
        return auth.currentUser?.uid
    }
}

extension FirebaseManager {
    // 재인증
    func reAuthenticate(password: String) async -> Bool {
        guard let user = auth.currentUser else { return false }
        let credential = EmailAuthProvider.credential(withEmail: getUserEmail, password: password)
        
        do {
            try await user.reauthenticate(with: credential)
            return true
        } catch {
            CommonUtil.print(output:"error: \(error.localizedDescription)")
            return false
        }
    }
    
    func removeUser() async -> Bool {
        guard let user = auth.currentUser else { return false }
        do {
            try await user.delete()
            return true
        } catch {
            CommonUtil.print(output:"error: \(error.localizedDescription)")
            return false
        }
    }
}

private extension FirebaseManager {
    func handleAuthResult(_ authResult: AuthDataResult?, error: Error?, completion: AuthCompletion) {
        if let error = error {
            if let errorCode = (error as NSError?)?.code {
                switch errorCode {
                case 17005:
                    completion(.FIRAuthErrorCodeUserDisabled)
                case 17007:
                    completion(.FIRAuthErrorCodeEmailAlreadyInUse)
                case 17008:
                    completion(.FIRAuthErrorCodeInvalidEmail)
                case 17009:
                    completion(.FIRAuthErrorCodeWrongPassword)
                case 17011:
                    completion(.FIRAuthErrorCodeOperationNotAllowed)
                case 17026:
                    completion(.FIRAuthErrorCodeLeastPasswordLength)
                default:
                    CommonUtil.print(output:"error: \(error.localizedDescription)")
                    completion(.unknown)
                    return
                }
            }
        } else {
            completion(nil)
        }
    }
}
