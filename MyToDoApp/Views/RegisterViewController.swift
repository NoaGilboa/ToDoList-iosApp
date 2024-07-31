import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        print("nameTextField: \(String(describing: nameTextField))")
        print("emailTextField: \(String(describing: emailTextField))")
        print("passwordTextField: \(String(describing: passwordTextField))")
    }

    @IBAction func registerTapped(_ sender: UIButton) {
        print("Register button tapped")

        guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, !name.isEmpty, !email.isEmpty, !password.isEmpty else {
                    print("One or more text fields are empty")
                    self.showToast(message: "One or more text fields are empty")
                    return
                }
        print("Attempting to register user with name: \(name), email: \(email)")
        DBManager.shared.registerUser(name: name, email: email, password: password) { result in
            switch result {
            case .success(let user):
                print("Registration succeeded for user: \(user.name)")
                // Handle successful registration, navigate to ToDoViewController
                self.dismiss(animated: true, completion: nil)
            case .failure(let error):
                print("Registration failed: \(error.localizedDescription)")
                if let authError = error as NSError? {
                                    switch authError.code {
                                    case AuthErrorCode.emailAlreadyInUse.rawValue:
                                        self.showToast(message: "The email address is already in use")
                                        print("The email address is already in use.")
                                    case AuthErrorCode.invalidEmail.rawValue:
                                        self.showToast(message: "The email address is badly formatted")
                                        print("The email address is badly formatted.")
                                    case AuthErrorCode.weakPassword.rawValue:
                                        self.showToast(message: "The password must be at least 6 characters ")
                                        print("The password must be 6 characters long or more.")
                                    default:
                                        self.showToast(message: "Error")
                                        print("Error: \(authError.localizedDescription)")
                                    }
                                }
            }
        }
    }
    
    @IBAction func alreadyHaveAccountTapped(_ sender: UIButton) {
        // Navigate back to the login screen
        print("Already have account tapped")
        self.dismiss(animated: true, completion: nil)
    }
}
