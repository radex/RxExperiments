import Foundation
import UIKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

class GitHubSignupViewController4 : ViewController {
// MARK: - Outlets
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidationOutlet: UILabel!
    
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidationOutlet: UILabel!
    
    @IBOutlet weak var repeatedPasswordOutlet: UITextField!
    @IBOutlet weak var repeatedPasswordValidationOutlet: UILabel!
    
    @IBOutlet weak var signupOutlet: UIButton!
    @IBOutlet weak var signingUpOulet: UIActivityIndicatorView!
    
// MARK: - View model
    
    private lazy var viewModel: GitHubSignupViewModel4 = .init(render: { [unowned self] in self.render($0) })
    
// MARK: - Rendering
    
    private func render(_ state: GitHubSignupViewModel4.Output) {
        print(state)
        
        // Hook up
        usernameValidationOutlet.setValidationState(state.usernameValid)
        passwordValidationOutlet.setValidationState(state.passwordValid)
        repeatedPasswordValidationOutlet.setValidationState(state.repeatPasswordValid)
        signupOutlet.isEnabled = state.signupEnabled
        signupOutlet.alpha = state.signupEnabled ? 1.0 : 0.5
        
        if state.signingIn {
            signingUpOulet.startAnimating()
        } else {
            signingUpOulet.stopAnimating()
        }
    }
    
// MARK: - Hook up UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hookUp()
    }
    
    private func hookUp() {
        Observable.combineLatest(
            usernameOutlet.rx.text.orEmpty,
            passwordOutlet.rx.text.orEmpty,
            repeatedPasswordOutlet.rx.text.orEmpty
        ) { ($0, $1, $2) }
            .subscribe(onNext: { (username, password, repeatPassword) in
                self.viewModel.props.username = username
                self.viewModel.props.password = password
                self.viewModel.props.repeatPassword = repeatPassword
            })
            .addDisposableTo(disposeBag)
    }
    
    @IBAction func signIn(_ sender: Any) {
        viewModel.signIn()
    }
    
// MARK: - Infrastructure
    
    override func didMove(toParentViewController parent: UIViewController?) {
        if let parent = parent {
            if parent as? UINavigationController == nil {
                assert(false, "something")
            }
        }
        else {
            disposeBag = DisposeBag()
            viewModel.end()
        }
    }
    
    deinit {
        print("deinit")
    }
}
