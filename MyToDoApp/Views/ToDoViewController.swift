import UIKit

class ToDoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    var user: User?
    var tasks: [ToDo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self

        print("ToDoViewController loaded")
        
        if let user = user {
            print("Fetching tasks for user: \(user.name)")
            DBManager.shared.getTasks(userID: user.userID) { result in
                switch result {
                case .success(let tasks):
                    self.tasks = tasks
                    self.collectionView.reloadData()
                   print("Tasks fetched successfully")
                case .failure(let error):
                    print("Failed to fetch tasks: \(error.localizedDescription)")
                }
            }
        } else {
            print("No user provided")
        }
    }

    @IBAction func addTaskTapped(_ sender: UIButton) {
        print("Add task button tapped")
        let alert = UIAlertController(title: "Add New Task", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Task Name"
        }
        alert.addTextField { textField in
            textField.placeholder = "Task Description"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let taskName = alert.textFields?[0].text, !taskName.isEmpty,
                  let taskDescription = alert.textFields?[1].text, !taskDescription.isEmpty,
                  let user = self.user else {
                print("Invalid input or user not set")
                return
            }
            
            let taskID = UUID().uuidString
            let newTask = ToDo(taskID: taskID, name: taskName, description: taskDescription, status: -1, createdBy: user.userID)
            
            DBManager.shared.addTask(userID: user.userID, task: newTask) { result in
                switch result {
                case .success:
                    print("Task added successfully")
                    self.tasks.append(newTask)
                    self.collectionView.reloadData()
                case .failure(let error):
                    print("Failed to add task: \(error.localizedDescription)")
                }
            }
        }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(addAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true)
        }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tasks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskCell", for: indexPath) as! TaskCollectionViewCell
        let task = tasks[indexPath.row]
        print("task: \(task.name) , \(task.description)")
        cell.configure(name: task.name, description: task.description, task: task)
        return cell
    }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        print("Logout button tapped")
        DBManager.shared.logoutUser { result in
            switch result {
            case .success:
                print("Logout successful")
                if let loginVC = self.presentingViewController as? LoginViewController {
                     loginVC.clearTextFields()
                }
                // Navigate back to the login screen
                self.dismiss(animated: true, completion: nil)
            case .failure(let error):
                print("Logout failed: \(error.localizedDescription)")
            }
        }
    }
}
