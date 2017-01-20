import RxSwift

/// An Observable Unit that emits exactly one value during its life
/// If the underlying observable emits more than one value, or completes
/// without emitting any values, this unit will terminate with an error

public struct OneObservable<T>: ObservableType {
    public typealias E = T
    
    private let _events: Observable<T>
    
    public init<Ev: ObservableType>(_ events: Ev) where Ev.E == T {
        _events = events.single()
    }
    
    public func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == T {
        return _events.subscribe(observer)
    }
    
    public func asObservable() -> Observable<T> {
        return _events
    }
}

extension ObservableType {
    public func justOne() -> OneObservable<E> {
        return OneObservable(self)
    }
}
