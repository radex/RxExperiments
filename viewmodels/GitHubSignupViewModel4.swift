import Foundation
import UIKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

class GitHubSignupViewModel4 {
// MARK: - Inputs
    struct Props {
        var username = ""
        var password = ""
        var repeatPassword = ""
    }
    
// MARK: - Internal state
    private struct State {
        var usernameValidation: ValidationResult = .empty
        var signingIn = false
    }
    
// MARK: - Outputs
    typealias Output = (
        usernameValid: ValidationResult,
        passwordValid: ValidationResult,
        repeatPasswordValid: ValidationResult,
        signupEnabled: Bool,
        signingIn: Bool
    )
    
// MARK: - Initialize
    typealias Renderer = (Output) -> Void
    private let renderer: Renderer
    
    init(render: @escaping Renderer) {
        self.renderer = render
        rxSetup()
    }
    
// MARK: - Logic
    
    private func rxSetup() {
        username_rx.asObservable()
            .distinctUntilChanged()
            .flatMapLatest { username in // those should all be [unowned self] or weak
                return self.validator.validateUsername(username)
                    .observeOn(MainScheduler.instance)
                    .catchErrorJustReturn(.failed(message: "Error contacting server"))
            }
            .subscribe(onNext: {
                self.state.usernameValidation = $0
            })
            .addDisposableTo(disposeBag)
    }
    
    private func outputState() -> Output {
        let usernameValidation = state.usernameValidation
        let passwordValidation = validator.validatePassword(props.password)
        let repeatPasswordValidation = validator.validateRepeatedPassword(props.password, repeatedPassword: props.repeatPassword)
        let signupEnabled =
            usernameValidation.isValid &&
            passwordValidation.isValid &&
            repeatPasswordValidation.isValid &&
            !state.signingIn
        let signingIn = state.signingIn
        
        return (usernameValidation, passwordValidation, repeatPasswordValidation, signupEnabled, signingIn)
    }
    
// MARK: - Actions
    
    func signIn() {
        state.signingIn = true
        
        API.signup(props.username, password: props.password)
            .observeOn(MainScheduler.instance)
            .catchErrorJustReturn(false)
            .subscribe(onNext: { [unowned self] signedIn in
                self.state.signingIn = false
                print("Signed in? \(signedIn)")
            })
            .addDisposableTo(disposeBag)
    }
    
// MARK: - Dependencies
    
    private let validator = GitHubDefaultValidationService.sharedValidationService
    private let API = GitHubDefaultAPI.sharedAPI
    private let wireframe = DefaultWireframe.sharedInstance
    
// MARK: - Implementation
    
    var props = Props() {
        didSet {
            username_rx.value = props.username
            triggerOutput()
        }
    }
    
    private var state = State() {
        didSet { triggerOutput() }
    }
    
    private let username_rx = Variable("")
    
// MARK: - Infrastructure
    
    private var disposeBag = DisposeBag()
    
    private var outputScheduled = false
    
    private func triggerOutput() {
        guard !outputScheduled else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let _self = self else { return }
            _self.outputScheduled = false
            _self.renderer(_self.outputState())
        }
        
        outputScheduled = true
    }
    
    func end() {
        disposeBag = DisposeBag()
    }
}
