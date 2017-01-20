import RxSwift

/// An Observable Unit that emits no elements during its life
/// But upon completion of the underlying Observable, it emits
/// a single Void value, and then immediately completes.

public struct CompletionObservable: ObservableType {
    public typealias E = Void
    
    private let _events: Observable<Void>
    
    public init<Ev: ObservableType>(_ events: Ev) {
        _events = .create { observer in
            events.subscribe { event in
                switch event {
                case .next(_):
                    break
                case let .error(e):
                    observer.onError(e)
                case .completed:
                    observer.onNext()
                    observer.onCompleted()
                }
            }
        }
    }
    
    public func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == Void {
        return _events.subscribe(observer)
    }
    
    public func asObservable() -> Observable<Void> {
        return _events
    }
}

extension ObservableType {
    public func justCompletion() -> CompletionObservable {
        return CompletionObservable(self)
    }
}
