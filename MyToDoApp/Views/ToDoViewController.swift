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

    @IBAction func addTaskTapped(_ sender: UIBarButtonItem) {
        print("Add task button tapped")
        // Present a UI to add a new task
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tasks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskCell", for: indexPath) as! TaskCollectionViewCell
        let task = tasks[indexPath.row]
        cell.taskNameLabel.text = task.name
        cell.taskDescriptionLabel.text = task.description
        return cell
    }
}
