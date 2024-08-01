import UIKit
import FirebaseStorage
import SideMenu

class ToDoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!

    var user: User?
    var tasks: [ToDo] = []
    var menu: SideMenuNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        print("ToDoViewController loaded")
        
        setupSideMenu()
        fetchTasks()
    }
    
   func setupSideMenu() {
       let storyboard = UIStoryboard(name: "Main", bundle: nil)
       let menuVC = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
       menuVC.user = user
       menu = SideMenuNavigationController(rootViewController: menuVC)
       menu?.leftSide = true
       SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)
       SideMenuManager.default.leftMenuNavigationController = menu
   }
    
    @IBAction func menuTapped(_ sender: UIBarButtonItem) {
          present(menu!, animated: true, completion: nil)
      }

    private func fetchTasks() {
        guard let user = user else { return }
        DBManager.shared.getTasks(userID: user.userID) { result in
            switch result {
            case .success(let tasks):
                self.tasks = tasks
                self.collectionView.reloadData()
            case .failure(let error):
                print("Failed to fetch tasks: \(error.localizedDescription)")
            }
        }
    }

//    private func fetchProfileImage() {
//        guard let user = user, let profileImageUrl = user.profileImageUrl else { return }
//        let storageRef = Storage.storage().reference(forURL: profileImageUrl)
//        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
//            if let error = error {
//                print("Failed to fetch profile image: \(error.localizedDescription)")
//            } else if let data = data, let image = UIImage(data: data) {
//                self.profileImageView.image = image
//            }
//        }
//    }

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
    
//    @IBAction func logoutTapped(_ sender: UIButton) {
//        print("Logout button tapped")
//        DBManager.shared.logoutUser { result in
//            switch result {
//            case .success:
//                print("Logout successful")
//                if let loginVC = self.presentingViewController as? LoginViewController {
//                     loginVC.clearTextFields()
//                }
//                // Navigate back to the login screen
//                self.dismiss(animated: true, completion: nil)
//            case .failure(let error):
//                print("Logout failed: \(error.localizedDescription)")
//            }
//        }
//    }
}
