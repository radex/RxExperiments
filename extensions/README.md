Some extensions to RxSwift I wrote and use. Some of these are experimental and not necessarily a good idea — use at your own peril.

- `perform` and `when` are just a pinch of syntactic sugar
- `retryNetworkRequest` retries the underlying observable but only on network or server errors
- `OneObservable` and `CompletionObservable` are an attempt to convey more guarantees about observables in the type system
