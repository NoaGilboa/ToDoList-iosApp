import UIKit

class ToDoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var user: User?
    var tasks: [ToDo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        if let user = user {
            DBManager.shared.getTasks(userID: user.userID) { result in
                switch result {
                case .success(let tasks):
                    self.tasks = tasks
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Failed to fetch tasks: \(error.localizedDescription)")
                }
            }
        }
    }

    @IBAction func addTaskTapped(_ sender: UIBarButtonItem) {
        // Present a UI to add a new task
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.description
        return cell
    }
}
