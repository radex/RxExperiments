import RxSwift
import RxCocoa

extension ObservableType {
    /// Retries an underlying network request Observable up to **3 times**.
    /// Only retries on network errors and server (HTTP 5xx) errors
    /// (other errors are re-emitted immediately)
    
    public func retryNetworkRequest() -> Observable<E> {
        return self.retryWhen { errors in
            errors
                .mapWithIndex { (error, i) -> Error in
                    if isNetworkOrServerError(error: error) && i < 2 /* fail on third error */ {
                        return error
                    } else {
                        throw error
                    }
                }
        }
    }
}

// FIXME(Swift4): This should be a property on Error, but Swift doesn't dispatch those dynamically :(

private func isNetworkOrServerError(error: Error) -> Bool {
    switch error {
    case is URLError:
        return true
        
    case RxCocoaURLError.httpRequestFailed(response: let response, data: _)
    where 500..<600 ~= response.statusCode:
        return true
        
    default:
        return false
    }
}
