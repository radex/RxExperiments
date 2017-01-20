import RxSwift

extension ObservableType {
    /// Same as `subscribe()`, but conveys the intention of simply kicking off
    /// an asynchronous task without caring about the result
    
    public func perform() -> Disposable {
        return subscribe()
    }
}
