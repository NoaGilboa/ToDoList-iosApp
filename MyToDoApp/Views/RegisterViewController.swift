import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func registerTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else { return }
        DBManager.shared.registerUser(name: name, email: email, password: password) { result in
            switch result {
            case .success(let user):
                // Handle successful registration, navigate to ToDoViewController
                self.performSegue(withIdentifier: "showToDo", sender: user)
            case .failure(let error):
                print("Registration failed: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func alreadyHaveAccountTapped(_ sender: UIButton) {
        // Navigate back to the login screen
        self.dismiss(animated: true, completion: nil)
    }
}
