import Foundation
import FirebaseFirestore
import FirebaseAuth

class DBManager {
    
    // Singleton instance of DBManager
    static let shared = DBManager()
    private let db = Firestore.firestore()
    
    // Private initializer to ensure only one instance is created
    private init() {}

    func registerUser(name: String, email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // If there's an error, call the completion handler with the error
                completion(.failure(error))
            } else if let authResult = authResult {
                let user = User(name: name, userID: authResult.user.uid, userEmail: email, password: password)
                self.saveUserToDB(user: user, completion: completion)
            }
        }
    }
    
    func loginUser(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let authResult = authResult {
                self.getUserFromDB(userID: authResult.user.uid, completion: completion)
            }
        }
    }
    
    func saveUserToDB(user: User, completion: @escaping (Result<User, Error>) -> Void) {
        do {
            // Use Firestore's setData(from:) method to save the user object
            try db.collection("users").document(user.userID).setData(from: user) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(user))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func getUserFromDB(userID: String, completion: @escaping (Result<User, Error>) -> Void) {
        // Use Firestore's getDocument method to retrieve the user document
        db.collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot, let user = try? snapshot.data(as: User.self) {
                completion(.success(user))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
            }
        }
    }
    
    func addTask(userID: String, task: ToDo, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("users").document(userID).collection("tasks").document(task.taskID).setData(from: task) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func getTasks(userID: String, completion: @escaping (Result<[ToDo], Error>) -> Void) {
        db.collection("users").document(userID).collection("tasks").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let tasks = snapshot?.documents.compactMap { try? $0.data(as: ToDo.self) } ?? []
                completion(.success(tasks))
            }
        }
    }
}
