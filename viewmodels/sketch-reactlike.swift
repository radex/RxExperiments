struct State {
    let username = ""
    let password = ""
    let repeatPassword = ""
    
    let usernameValidation = .empty
    let signingIn = false
}

class VC {
    let state = State() {
        didSet { triggerRender() }
    }
    
    let username_rx = Variable("")
    
    init {
        username_rx
            .flatMapLatest { username in
                return validateUsername(username)
                    .catchErrorJustReturn(.failed)
            }.subscribe(onNext: {
                self.state.usernameValidation = $0
            })
            .addDisposableTo(disposeBag)
    }
    
    func setUp() {
        usernameInput.onChange = {
            self.state.username = $0
            username_rx.value = $0
        }
        passwordInput.onChange = { self.state.password = $0 }
        repeatPasswordInput.onChange = { self.state.repeatPassword = $0 }
    }
    
    func render() {
        let usernameValid = state.usernameValidation
        let passwordValid = passwordValidation(state.password)
        let repeatPasswordValid = passwordValidation(state.password, state.repeatPassword)
        
        let signupEnabled = usernameValid && passwordValid && repeatPasswordValid && !state.signingIn
        
        usernameValidLabel.state = usernameValid
        passwordValidLabel.state = passwordValid
        repeatPasswordValid.state = repeatPasswordValid
        signupButton.enabled = signupEnabled
    }
}