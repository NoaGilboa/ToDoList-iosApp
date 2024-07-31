import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        print("LoginViewController loaded")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearTextFields() // Clear text fields when the view is about to appear
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        print("Login button tapped")
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty else{
            print("One or more text fields are empty")
            self.showToast(message: "One or more text fields are empty")
            return
        }
            print("Attempting to login with email: \(email) , password: \(password)")
            DBManager.shared.loginUser(email: email, password: password) { result in
                switch result {
                case .success(let user):
                    self.performSegue(withIdentifier: "showToDo", sender: user)
                case .failure(let error):
                    print("Login failed: \(error.localizedDescription)")
                    self.showToast(message: "Login failed")
                }
            }
        }
    
    @IBAction func dontHaveAccountTapped(_ sender: UIButton) {
        // Navigate to the register screen
        print("Don't have account tapped")
        self.performSegue(withIdentifier: "showRegister", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showToDo" {
            if let todoVC = segue.destination as? ToDoViewController, let user = sender as? User {
                todoVC.user = user
            }
        }
    }
    
    func clearTextFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
}
