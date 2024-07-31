//firebase realtime
import Foundation
import FirebaseAuth
import FirebaseDatabase

class DBManager {
    
    // Singleton instance of DBManager
    static let shared = DBManager()
    private let db = Database.database().reference()
    
    // Private initializer to ensure only one instance is created
    private init() {}
    
    func registerUser(name: String, email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        print("Attempting to create user with email: \(email)")
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                completion(.failure(error))
            } else if let authResult = authResult {
                print("User created successfully with userID: \(authResult.user.uid)")
                let user = User(name: name, userID: authResult.user.uid, userEmail: email, password: password)
                self.saveUserToDB(user: user, completion: completion)
            }
        }
    }
    
    func loginUser(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        print("Attempting to login with email: \(email) , password: \(password)")
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error logging in: \(error.localizedDescription)")
                completion(.failure(error))
            } else if let authResult = authResult {
                print("Login successful for userID: \(authResult.user.uid)")
                self.getUserFromDB(userID: authResult.user.uid, completion: completion)
            }
        }
    }
    
    func logoutUser(completion: @escaping (Result<Void, Error>) -> Void) {
        print("Attempting to logout")
        do {
            try Auth.auth().signOut()
            print("Logout successful")
            completion(.success(()))
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
            completion(.failure(signOutError))
        }
    }
    
    func saveUserToDB(user: User, completion: @escaping (Result<User, Error>) -> Void) {
        print("Saving user to database with userID: \(user.userID)")
        let userDict: [String: Any] = [
            "name": user.name,
            "email": user.userEmail,
            "password": user.password
        ]
        db.child("users").child(user.userID).setValue(userDict) { error, _ in
            if let error = error {
                print("Error saving user to DB: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("User saved to DB successfully")
                completion(.success(user))
            }
        }
    }
    
    func getUserFromDB(userID: String, completion: @escaping (Result<User, Error>) -> Void) {
        print("Fetching user from database with userID: \(userID)")
        db.child("users").child(userID).observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                let user = User(
                    name: value["name"] as? String ?? "",
                    userID: userID,
                    userEmail: value["email"] as? String ?? "",
                    password: value["password"] as? String ?? "",
                    tasks: [] // Tasks will be fetched separately
                )
                self.getTasks(userID: userID) { result in
                    switch result {
                    case .success(let tasks):
                        var userWithTasks = user
                        userWithTasks.tasks = tasks
                        print("User fetched successfully with tasks: \(userWithTasks)")
                        completion(.success(userWithTasks))
                    case .failure(let error):
                        print("Failed to fetch tasks: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }
        } withCancel: { error in
            let fetchError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
            print("User not found")
            completion(.failure(fetchError))
        }
    }
    
    func addTask(userID: String, task: ToDo, completion: @escaping (Result<Void, Error>) -> Void) {
        print("Adding task with taskID: \(task.taskID) for userID: \(userID)")
        let taskDict: [String: Any] = [
            "taskID": task.taskID,
            "name": task.name,
            "description": task.description,
            "status": -1,
            "createdBy": task.createdBy
        ]
        db.child("users").child(userID).child("tasks").child(task.taskID).setValue(taskDict) { error, _ in
            if let error = error {
                print("Error adding task: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Task added successfully")
                completion(.success(()))
            }
        }
    }
    
    func getTasks(userID: String, completion: @escaping (Result<[ToDo], Error>) -> Void) {
        print("Fetching tasks for userID: \(userID)")
        db.child("users").child(userID).child("tasks").observeSingleEvent(of: .value) { snapshot in
            var tasks: [ToDo] = []
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if let value = child.value as? [String: Any],
                   let taskID = value["taskID"] as? String,
                   let name = value["name"] as? String,
                   let description = value["description"] as? String,
                   let status = value["status"] as? Int,
                   let createdBy = value["createdBy"] as? String {
                    let task = ToDo(taskID: taskID, name: name, description: description, status: status, createdBy: createdBy)
                    tasks.append(task.self)
                }
            }
            print("Tasks fetched successfully: \(tasks.count) tasks found: \(tasks)")
            completion(.success(tasks))
        } withCancel: { error in
            print("Error fetching tasks: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    func updateTask(task: ToDo, completion: @escaping (Result<Void, Error>) -> Void) {
        let taskDict: [String: Any] = [
            "taskID": task.taskID,
            "name": task.name,
            "description": task.description,
            "status": task.status,
            "createdBy": task.createdBy
        ]
        db.child("users").child(task.createdBy).child("tasks").child(task.taskID).setValue(taskDict) { error, _ in
            if let error = error {
                print("Error adding task: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Task added successfully")
                completion(.success(()))
            }
        }
    }
    
    
}
    //firebase store
    //import Foundation
    //import FirebaseFirestore
    //import FirebaseAuth
    //
    //class DBManager {
    //
    //    // Singleton instance of DBManager
    //    static let shared = DBManager()
    //    private let db = Firestore.firestore()
    //
    //    // Private initializer to ensure only one instance is created
    //    private init() {}
    //
    //    func registerUser(name: String, email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
    //        print("Attempting to create user with email: \(email)")
    //        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
    //            if let error = error {
    //                print("Error creating user: \(error.localizedDescription)")
    //                // If there's an error, call the completion handler with the error
    //                completion(.failure(error))
    //            } else if let authResult = authResult {
    //                print("User created successfully with userID: \(authResult.user.uid)")
    //                let user = User(name: name, userID: authResult.user.uid, userEmail: email, password: password)
    //                self.saveUserToDB(user: user, completion: completion)
    //            }
    //        }
    //    }
    //
    //    func loginUser(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
    //        print("Attempting to login with email: \(email)")
    //        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
    //            if let error = error {
    //                print("Error logging in: \(error.localizedDescription)")
    //                completion(.failure(error))
    //            } else if let authResult = authResult {
    //                print("Login successful for userID: \(authResult.user.uid)")
    //                self.getUserFromDB(userID: authResult.user.uid, completion: completion)
    //            }
    //        }
    //    }
    //
    //    func saveUserToDB(user: User, completion: @escaping (Result<User, Error>) -> Void) {
    //        print("Saving user to database with userID: \(user.userID)")
    //        do {
    //            // Use Firestore's setData(from:) method to save the user object
    //            try db.collection("users").document(user.userID).setData(from: user) { error in
    //                if let error = error {
    //                    print("Error saving user to DB: \(error.localizedDescription)")
    //                    completion(.failure(error))
    //                } else {
    //                    print("User saved to DB successfully")
    //                    completion(.success(user))
    //                }
    //            }
    //        } catch {
    //            print("Error during saveUserToDB: \(error.localizedDescription)")
    //            completion(.failure(error))
    //        }
    //    }
    //
    //    func getUserFromDB(userID: String, completion: @escaping (Result<User, Error>) -> Void) {
    //        print("Fetching user from database with userID: \(userID)")
    //        // Use Firestore's getDocument method to retrieve the user document
    //        db.collection("users").document(userID).getDocument { snapshot, error in
    //            if let error = error {
    //                print("Error fetching user: \(error.localizedDescription)")
    //                completion(.failure(error))
    //            } else if let snapshot = snapshot, let user = try? snapshot.data(as: User.self) {
    //                print("User fetched successfully: \(user)")
    //                completion(.success(user))
    //            } else {
    //                let fetchError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
    //                print("User not found")
    //                completion(.failure(fetchError))
    //            }
    //        }
    //    }
    //
    //    func addTask(userID: String, task: ToDo, completion: @escaping (Result<Void, Error>) -> Void) {
    //        print("Adding task with taskID: \(task.taskID) for userID: \(userID)")
    //        do {
    //            try db.collection("users").document(userID).collection("tasks").document(task.taskID).setData(from: task) { error in
    //                if let error = error {
    //                    print("Error adding task: \(error.localizedDescription)")
    //                    completion(.failure(error))
    //                } else {
    //                    print("Task added successfully")
    //                    completion(.success(()))
    //                }
    //            }
    //        } catch {
    //            print("Error during addTask: \(error.localizedDescription)")
    //            completion(.failure(error))
    //        }
    //    }
    //
    //    func getTasks(userID: String, completion: @escaping (Result<[ToDo], Error>) -> Void) {
    //        print("Fetching tasks for userID: \(userID)")
    //        db.collection("users").document(userID).collection("tasks").getDocuments { snapshot, error in
    //            if let error = error {
    //                print("Error fetching tasks: \(error.localizedDescription)")
    //                completion(.failure(error))
    //            } else {
    //                let tasks = snapshot?.documents.compactMap { try? $0.data(as: ToDo.self) } ?? []
    //                print("Tasks fetched successfully: \(tasks.count) tasks found")
    //                completion(.success(tasks))
    //            }
    //        }
    //    }
    //}

