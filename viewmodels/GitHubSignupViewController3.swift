import Foundation
import UIKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

class GitHubSignupViewController3 : ViewController {
// MARK: - Outlets
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidationOutlet: UILabel!
    
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidationOutlet: UILabel!
    
    @IBOutlet weak var repeatedPasswordOutlet: UITextField!
    @IBOutlet weak var repeatedPasswordValidationOutlet: UILabel!
    
    @IBOutlet weak var signupOutlet: UIButton!
    @IBOutlet weak var signingUpOulet: UIActivityIndicatorView!
    
// MARK: - Dependencies
    
    let validator = GitHubDefaultValidationService.sharedValidationService
    let API = GitHubDefaultAPI.sharedAPI
    let wireframe = DefaultWireframe.sharedInstance
    
// MARK: - State
    
    struct State {
        var username = ""
        var password = ""
        var repeatPassword = ""
        
        var usernameValidation: ValidationResult = .empty
        var signingIn = false
    }
    
    var state = State() {
        didSet { triggerRender() }
    }
    
    let username_rx = Variable("")
    
// MARK: - Actions
    
    @IBAction func signIn(_ sender: Any) {
        state.signingIn = true
        
        API.signup(state.username, password: state.password)
            .observeOn(MainScheduler.instance)
            .catchErrorJustReturn(false)
            .subscribe(onNext: { signedIn in
                self.state.signingIn = false
                print("Signed in? \(signedIn)")
            })
            .addDisposableTo(disposeBag)
    }
    
// MARK: - Rendering
    
    func render() {
        print(state)
        
        // View state
        let usernameValidation = state.usernameValidation
        let passwordValidation = validator.validatePassword(state.password)
        let repeatPasswordValidation = validator.validateRepeatedPassword(state.password, repeatedPassword: state.repeatPassword)
        let signupEnabled =
            usernameValidation.isValid &&
            passwordValidation.isValid &&
            repeatPasswordValidation.isValid &&
            !state.signingIn
        
        // Hook up
        usernameValidationOutlet.setValidationState(usernameValidation)
        passwordValidationOutlet.setValidationState(passwordValidation)
        repeatedPasswordValidationOutlet.setValidationState(repeatPasswordValidation)
        signupOutlet.isEnabled = signupEnabled
        signupOutlet.alpha = signupEnabled ? 1.0 : 0.5
        
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
        setUpRx()
    }
    
    func setUpRx() {
        username_rx.asObservable()
            .distinctUntilChanged()
            .flatMapLatest { username in
                return self.validator.validateUsername(username)
                    .observeOn(MainScheduler.instance)
                    .catchErrorJustReturn(.failed(message: "Error contacting server"))
            }
            .subscribe(onNext: {
                self.state.usernameValidation = $0
            })
            .addDisposableTo(disposeBag)
    }
    
    func hookUp() {
        Observable.combineLatest(
            usernameOutlet.rx.text.orEmpty,
            passwordOutlet.rx.text.orEmpty,
            repeatedPasswordOutlet.rx.text.orEmpty
        ) { ($0, $1, $2) }
            .subscribe(onNext: { (username, password, repeatPassword) in
                self.username_rx.value = username
                self.state.username = username
                self.state.password = password
                self.state.repeatPassword = repeatPassword
            })
            .addDisposableTo(disposeBag)
    }
    
// MARK: - Infrastructure
    
    var renderScheduled = false
    
    func triggerRender() {
        guard !renderScheduled else {
            return
        }
        
        DispatchQueue.main.async {
            self.renderScheduled = false
            self.render()
        }
        
        renderScheduled = true
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if let parent = parent {
            if parent as? UINavigationController == nil {
                assert(false, "something")
            }
        }
        else {
            disposeBag = DisposeBag()
        }
    }
}
