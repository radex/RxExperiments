class VM: ViewModel {
    struct State {
// MARK: - Inputs
        let username = ""
        let password = ""
        let repeatPassword = ""
    
// MARK: - Internal state
        private let usernameValidation = .empty
        private let signingIn = false
    }
    
// MARK: - Outputs
    typealias OutputState = (
        usernameValid: ValidationResult,
        passwordValid: ValidationResult,
        repeatPasswordValid: ValidationResult,
        signupEnabled: Bool
    )
    
// MARK: - Implementation
    var state = State() {
        didSet {
            username_rx.value = state.username
            updateOutput()
        }
    }
    
    private let username_rx = Variable("")
    
    private func setup_rx() {
        username_rx.asObservable()
            .distinctUntilChanged()
            .flatMapLatest { username in
                return validateUsername(username)
                    .catchErrorJustReturn(.failed)
            }.subscribe(onNext: {
                self.state.usernameValidation = $0
            })
            .addDisposableTo(disposeBag)
    }
    
    func outputState() -> Output {
        let usernameValid = state.usernameValidation
        let passwordValid = passwordValidation(state.password)
        let repeatPasswordValid = passwordValidation(state.password, state.repeatPassword)
        
        let signupEnabled = usernameValid && passwordValid && repeatPasswordValid && !state.signingIn
        
        return (usernameValid, passwordValid, repeatPasswordValid, signupEnabled)
    }
}

class VC: ReactyViewController {
    let viewModel = VM(render: self.render)
    
    func setUp() {
        usernameInput.onChange       = { viewModel.state.username = $0 }
        passwordInput.onChange       = { viewModel.state.password = $0 }
        repeatPasswordInput.onChange = { viewModel.state.repeatPassword = $0 }
    }
    
    func render(state: VM.OutputState) {
        usernameValidLabel.state  = state.usernameValid
        passwordValidLabel.state  = state.passwordValid
        repeatPasswordValid.state = state.repeatPasswordValid
        signupButton.enabled      = state.signupEnabled
    }
}