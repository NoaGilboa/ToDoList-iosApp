import UIKit

class TaskCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var taskDescriptionLabel: UILabel!
    @IBOutlet weak var vImage: UIImageView!
    @IBOutlet weak var xImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    var task: ToDo!
    var status: Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGestureRecognizers()
    }
    
    private func setupGestureRecognizers() {
        if status == true {
            vImageTapped()
            return
        }
        
        if status == false {
            xImageTapped()
            return
        }
        
        statusLabel.text = ""
        let vImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(vImageTapped))
        vImage.isUserInteractionEnabled = true
        vImage.addGestureRecognizer(vImageTapGesture)
            
        let xImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(xImageTapped))
        xImage.isUserInteractionEnabled = true
        xImage.addGestureRecognizer(xImageTapGesture)
        
        task.status=status
        
        DBManager.shared.updateTask(task: task){ result in
            switch result {
            case .success:
                print("Task update successfully")
            case .failure(let error):
                print("Failed to update task: \(error.localizedDescription)")
            }
        }
    }

    @objc private func vImageTapped() {
        statusLabel.text = "Done!"
        status=true
        statusLabel.textColor=UIColor(red: 0, green: 0.7, blue: 0.2, alpha: 1)
        xImage.isHidden=true
        vImage.isHidden=true
    }
        
    @objc private func xImageTapped() {
        statusLabel.text = "Canceled!"
        status=false
        statusLabel.textColor=UIColor(red: 1, green: 0, blue: 0, alpha: 1)
            xImage.isHidden=true
            vImage.isHidden=true
        }
    
    func configure(name: String, description: String, task: ToDo){
        taskNameLabel.text=name
        taskDescriptionLabel.text=description+"\t"
        self.task=task
        self.status=task.status
    }
    
    
}
