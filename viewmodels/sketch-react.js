username_rx = Variable()

initialState() {
  return {
    username: '',
    password: '',
    repeatPassword: '',
    
    usernameValidation: empty,
    signingIn: false,
  }
}

init {
  username_rx
    .flatMapLatest(username => {
      return validateUsername(username)
        .catchErrorJustReturn(failed)
    })
    .subscribeNext(usernameValidation => {
      this.state.usernameValidation = usernameValidation
    })
}

usernameChanged(username) {
  this.state.username = username
  username_rx.value = username
}

render() {
  usernameValid = this.state.usernameValidation
  passwordValid = passwordValidation(this.state.password)
  repeatPasswordValid = repeatPasswordValidation(this.state.password, this.state.repeatPassword)
  
  signupEnabled = usernameValid && passwordValid && repeatPasswordValid && !signingIn
  
  return (
    <Input onChange={this.usernameChanged}>
    <Text>{usernameValid}</Text>
    
    <Input onChange={ password => this.setState({ password }) }>
    <Text>{passwordValid}</Text>
    
    <Input onChange={ repeatPassword => this.setState({ repeatPassword }) }>
    <Text>{repeatPasswordValid}</Text>
    
    <Button enabled={signupEnabled}>
  )
}