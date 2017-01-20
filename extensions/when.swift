import RxSwift

extension OneObservable {
    /// Returns an Observable which emits a single tuple with elements emitted by passed Observables
    /// and then completes when all underlying Observables complete.
    /// The passed Observables must emit exactly one element
    
    public static func when<A: ObservableType, B: ObservableType>(_ a: A, _ b: B) -> OneObservable<(A.E, B.E)> {
        let o = Observable.combineLatest(a, b) { ($0, $1) }
        return o.justOne()
    }
}
