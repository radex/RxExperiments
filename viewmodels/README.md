This is an experimental hybrid approach to building view controllers and view models, combining uses of RxSwift with the simple React-like approach to data flow.

Look at RxSwift's RxExamples -> GitHubSignup to see the original, pure-RxSwift approach to this. It's very clean, but also tedious and repetitive.

So why not use a React-style approach, where you keep all of the state in one struct, and any change to it triggers a full re-render? This makes the plumbing much simpler. And then only use RxSwift for complex asynchronous operations and UI bindings.

- `sketch-*` - pseudocode of me trying to figure out how to go about it
- `GitHubSignupViewController3.swift` - a React-style approach (with dashes of Rx) to building the same view controller as in RxExamples
- `GitHubSignupView{Controller,Model}4.swift` - same as above, but with the split between view controller and view model

This approach seems promising to me, but to be viable would require more work creating infrastructure (to avoid repetitive code). It also lacks all the tools React has to optimize performance, allow animations, etc.

(To use the `GitHubSignup*.swift` files, you'd have to copy them over to RxExamples and hook up to the storyboard)
