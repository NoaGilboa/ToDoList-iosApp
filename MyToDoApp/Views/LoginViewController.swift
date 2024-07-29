import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        DBManager.shared.loginUser(email: email, password: password) { result in
            switch result {
            case .success(let user):
                // Handle successful login, navigate to ToDoViewController
                self.performSegue(withIdentifier: "showToDo", sender: user)
            case .failure(let error):
                print("Login failed: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func dontHaveAccountTapped(_ sender: UIButton) {
        // Navigate to the register screen
        self.performSegue(withIdentifier: "showRegister", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showToDo" {
            if let todoVC = segue.destination as? ToDoViewController, let user = sender as? User {
                todoVC.user = user
            }
        }
        
        
    }
}
