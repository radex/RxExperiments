//: [Previous](@previous)

import RxSwift

let bag = DisposeBag()

let o1 = Observable<String>.create { observer in
    print("starting")
    observer.onNext("hey!")
    print("printed hey")
    observer.onNext("yo!")
    observer.onCompleted()
    print("completed")
    
    return Disposables.create() //???
}

print("subscribing…")

o1.subscribe { event in
    print("1 \(event)")
}.addDisposableTo(bag)

o1.subscribe(onNext: { event in
    print("2 \(event)")
}).addDisposableTo(bag)

print("----------")

func printOut<T>(_ o: Observable<T>) {
    o.subscribe(onNext: { print("Next: ", $0) },
                onError: { print("Error: ", $0) },
                onCompleted: { print("Completed") },
                onDisposed: { print("Disposed") })
        .addDisposableTo(bag)
    print("--")
}

struct CustomError: Error {}

printOut(Observable<Int>.never())
printOut(Observable<Int>.empty())
printOut(Observable<String>.just("Hey!"))
printOut(Observable<String>.of("yo", "this", "shit", "cool"))
printOut(Observable<Int>.from([1, 2, 3]))
printOut(Observable<Int>.from([1, 2, 3] as Set))
//let dictionary = ["foo": 1, "bar": 2]
//let type = type(of: dictionary).Element.self
//printOut(Observable<(String, Int)>.from(dictionary as Sequence)
printOut(Observable<Int>.error(CustomError()))

print("----------")

func myNever<T>() -> Observable<T> {
   return .create { observer in
       return Disposables.create()
   }
}

func myEmpty<T>() -> Observable<T> {
   return .create { observer in
       observer.onCompleted()
       return Disposables.create()
   }
}

func myJust<T>(_ element: T) -> Observable<T> {
   return .create { observer in
       observer.onNext(element)
       observer.onCompleted()
       return Disposables.create()
   }
}

func myFrom<T>(_ xs: [T]) -> Observable<T> {
   return .create { observer in
       for x in xs {
           observer.onNext(x)
       }
       observer.onCompleted()
       return Disposables.create()
   }
}

func myOf<T>(_ xs: T...) -> Observable<T> {
   return myFrom(xs)
}

func myError<T>(_ error: Error) -> Observable<T> {
   return .create { observer in
       observer.onError(error)
       return Disposables.create()
   }
}

printOut(myNever() as Observable<Int>)
printOut(myEmpty() as Observable<Int>)
printOut(myJust("hey"))
printOut(myFrom([1,2,3]))
printOut(myOf("foo", "bar", "baz"))
printOut(myError(CustomError()) as Observable<Int>)

print("-----------")

printOut(Observable.range(start: 0, count: 10))
printOut(Observable.range(start: 0, count: 10).take(3))
printOut(Observable.repeatElement(10).take(5))
printOut(Observable.repeatElement("Foo").take(5))
printOut(Observable.range(start: 0, count: 10).takeLast(3))
printOut(Observable.generate(initialState: 0, condition: { $0 < 10 }, iterate: { $0 + 2 }))
printOut(Observable.generate(initialState: 0, condition: { _ in true }, iterate: { $0 + 10 }).take(3))

print("-----")

let o3 = Observable.repeatElement(1).take(3)

printOut(o3)

var count = 1
let o4 = Observable<Int>.deferred {
   let i = count
   print("Creating copy \(i)")
   count += 1
   return Observable.repeatElement(i).take(3)
}

printOut(o4)
printOut(o4)

print("----")

Observable.repeatElement("Hey!").take(2)
   .do(onNext: { print("Scary side effect for \($0)") },
       onCompleted: { print("Completed but passing through!") })
   .subscribe { print($0) }

// -----

print("----")

let ps = PublishSubject<String>()

ps.onNext("ZERO")

ps.subscribe { print("1: \($0)") }.addDisposableTo(bag)
print("1 subscribed")

ps.onNext("ONE")
ps.onNext("TWO")

ps.subscribe { print("2: \($0)") }.addDisposableTo(bag)
print("2 subscribed")

ps.onNext("THREE")
ps.onNext("FOUR")
ps.onCompleted()

ps.subscribe { print("3: \($0)") }.addDisposableTo(bag)

print("--")

let ps2 = PublishSubject<String>()

ps2.subscribe { print("1: \($0)") }.addDisposableTo(bag)
print("1 subscribed")

ps2.onNext("ONE")

ps2.subscribe { print("2: \($0)") }.addDisposableTo(bag)
print("2 subscribed")

ps2.onError(CustomError())

ps2.subscribe { print("3: \($0)") }.addDisposableTo(bag)
print("3 subscribed")

//---
print("--")

let ps3 = PublishSubject<Int>()

ps3.onNext(0)
ps3.onNext(1)

ps3.take(3).subscribe(onNext: { print("1: \($0)") }).addDisposableTo(bag)

ps3.onNext(2)

ps3.subscribe(onNext: { print("2: \($0)") }).addDisposableTo(bag)

ps3.onNext(3)
ps3.onNext(4)
ps3.onNext(5)
ps3.onNext(6)

//--
print("-------")

let bs = BehaviorSubject(value: 0)

bs.subscribe { print("1: \($0)") }.addDisposableTo(bag)

bs.onNext(1)
bs.onNext(2)

bs.subscribe { print("2: \($0)") }.addDisposableTo(bag)

bs.onNext(3)
bs.onNext(4)

bs.onCompleted()

bs.subscribe { print("3: \($0)") }.addDisposableTo(bag)

//---
print("--")

let bs2 = BehaviorSubject(value: 0)

bs2.onNext(1)
bs2.onNext(2)

bs2.subscribe { print("1: \($0)") }.addDisposableTo(bag)

bs2.onNext(3)
bs2.onNext(4)

bs2.subscribe { print("2: \($0)") }.addDisposableTo(bag)

bs2.onError(CustomError())

bs2.subscribe { print("3: \($0)") }.addDisposableTo(bag)

//---
print("-----")

let rs = ReplaySubject<String>.create(bufferSize: 2)

rs.subscribe { print("1: \($0)") }.addDisposableTo(bag)

rs.onNext("ONE")
rs.onNext("TWO")
rs.onNext("THREE")

rs.subscribe { print("2: \($0)") }.addDisposableTo(bag)

rs.onNext("FOUR")
rs.onCompleted()

rs.subscribe { print("3: \($0)") }.addDisposableTo(bag)

//---
print("--")

let rs2 = ReplaySubject<String>.create(bufferSize: 2)

rs2.onNext("ONE")
rs2.onNext("TWO")
rs2.onNext("THREE")

rs2.subscribe { print("1: \($0)") }.addDisposableTo(bag)

rs2.onNext("FOUR")

rs2.subscribe { print("2: \($0)") }.addDisposableTo(bag)

rs2.onError(CustomError())

rs2.subscribe { print("3: \($0)") }.addDisposableTo(bag)

//---
print("--")

let rs3 = ReplaySubject<Int>.createUnbounded()

rs3.onNext(1)
rs3.onNext(2)
rs3.onNext(3)

rs3.subscribe { print("1: \($0)") }.addDisposableTo(bag)

rs3.onNext(4)
rs3.onNext(5)

rs3.subscribe { print("2: \($0)") }.addDisposableTo(bag)

rs3.onNext(6)
rs3.onCompleted()

rs3.subscribe { print("3: \($0)") }.addDisposableTo(bag)

//---
print("------")

let v = Variable(10)

v.value = 20
v.value += 1

v.asObservable().subscribe { print("1: \($0)") }.addDisposableTo(bag)

v.value /= 2
v.value += 5

v.asObservable().take(2).subscribe { print("2: \($0)") }.addDisposableTo(bag)

v.value = 30
v.value = 40
v.value = 50

v.asObservable().skip(1).take(1).subscribe { print("3: \($0)") }.addDisposableTo(bag)

v.value = 60
v.value = 70

//---
print("--")

var v2:Variable? = Variable(1)

v2!.asObservable().subscribe { print("1: \($0)") }.addDisposableTo(bag)

v2!.value += 1
v2!.value += 1

v2 = nil

//--
print("---")

class MyTakeObserver<T>: ObserverType {
   typealias E = T

   let observer: (Event<T>) -> Void
   var count: Int

   init(count: Int, observer: @escaping (Event<T>) -> Void) {
       self.count = count
       self.observer = observer
   }

   func on(_ event: Event<T>) {
       guard count > 0 else { return observer(.completed) }
       defer { count -= 1 }
       observer(event)
   }
}

func myTake<T>(_ o: Observable<T>, _ n: Int) -> Observable<T> {
   return Observable.create { observer in
       return o.subscribe(MyTakeObserver<T>(count: n, observer: { observer.on($0) }))
   }
}

printOut(myTake(Observable.range(start: 0, count: 10), 3))

// FIXME: not sure it disposes correctly

printOut(Observable.of("foo", "bar"))
printOut(Observable.of("foo", "bar").take(2))
printOut(Observable.of("foo", "bar").take(3))
printOut(myTake(Observable.of("foo", "bar"), 2))
printOut(myTake(Observable.of("foo", "bar"), 3))

print("-------")

printOut(Observable.of("foo", "bar").startWith("0", "1").startWith("_"))

do {
   let s1 = PublishSubject<String>()
   let s2 = PublishSubject<String>()

   Observable.of(s1, s2)
       .merge()
       .subscribe { print($0) }
       .addDisposableTo(bag)

   s1.onNext("1")
   s1.onNext("2")
   s1.onNext("3")
   s2.onNext("ONE")
   s1.onNext("4")
   s2.onNext("TWO")
   s1.onCompleted() // not completed
   s2.onNext("THREE")
   s2.onCompleted() // completed now

   print("--")
}

do {
   let s1 = PublishSubject<String>()
   let s2 = PublishSubject<String>()

   Observable.of(s1, s2)
       .merge()
       .subscribe { print($0) }
       .addDisposableTo(bag)

   s1.onNext("1")
   s2.onNext("ONE")
   s1.onError(CustomError()) // errors out imediately
   s2.onNext("TWO") // ignored
   s2.onCompleted()

   print("--")
}

do {
   let sos = PublishSubject<Observable<String>>()

   sos.merge()
       .subscribe { print($0) }
       .addDisposableTo(bag)

   let s1 = PublishSubject<String>()
   s1.onNext("1") // ignored

   sos.onNext(s1)

   s1.onNext("2")
   s1.onNext("3")

   let s2 = PublishSubject<String>()
   sos.onNext(s2)

   s2.onNext("ONE")
   s1.onNext("4")
   s2.onNext("TWO")

   sos.onNext(.just("Hey!"))

   s2.onCompleted()
   s2.onNext("THREE") // ignored

//    sos.onError(CustomError()) // errors out merged sequence
   sos.onCompleted() // not the end (but can't accept new observables)

   s1.onNext("5")
   s1.onCompleted() // completed now

   print("--")
}

print("-------")

do {
   let s1 = Observable.of(1,2,3,4)
   let s2 = Observable.from(["Foo", "Bar", "Baz"])

   Observable.zip(s1, s2) { ($0, $1) }
       .subscribe { print($0) }
       .addDisposableTo(bag)
}

print("--")

do {
   let s1 = PublishSubject<String>()
   let s2 = PublishSubject<String>()

   Observable.zip(s1, s2) { ($0, $1) }
       .subscribe { print($0) }
       .addDisposableTo(bag)

   s1.onNext("1")
   s1.onNext("2")
   s2.onNext("ONE")
   s1.onNext("3")
   s2.onNext("TWO")
   s2.onNext("THREE")
   s2.onNext("FOUR")
   s2.onCompleted() // doesn't complete
   s1.onCompleted() // completes, because less elements
}

print("--")

do {
   let s1 = PublishSubject<String>()
   let s2 = PublishSubject<String>()

   Observable.combineLatest(s1, s2) { ($0, $1) }
       .subscribe { print($0) }
       .addDisposableTo(bag)

   s1.onNext("1")
   s1.onNext("2")
   s2.onNext("ONE")
   s2.onNext("TWO")
   s1.onNext("3")
   s2.onNext("THREE")
   s2.onCompleted() // no completion
   s1.onNext("4")
   s1.onCompleted() // completion
}

//func myCombineLatest<T>(_ o1: Observable<T>, _ o2: Observable<T>) -> Observable<(T, T)> {
//    return .create { observer in
//        var v1: T?
//        var v2: T?
//
//        func send() {
//            if let v1 = v1, let v2 = v2 {
//                observer.onNext((v1, v2))
//            }
//        }
//
//        let d1 = o1.subscribe { event in
//            switch event {
//            case let .next(el): v1 = el; send()
//            case let .error(er): observer.onError(er)
//            case .completed: break
//            }
//        }
//
//        let d2 = o2.subscribe { event in
//            switch event {
//            case let .next(el): v2 = el; send()
//            case let .error(er): observer.onError(er)
//            case .completed: break
//            }
//        }
//
//        return Disposables.create()
//    }
//}

print("--")

do {
   let o1 = Observable.just("_")
   let o2 = Observable.of("1", "2", "3", "4")
   let o3 = Observable.from(["A", "B", "C"])

   let cl = Observable.combineLatest([o1, o2, o3]) { $0.joined(separator: ",") }
   cl.subscribe { print($0) }
       .addDisposableTo(bag)
}

print("--")

do {
   let logInButton = PublishSubject<Void>()
   let enterPressed = PublishSubject<Void>()
   let logInTrigger = Observable.of(logInButton, enterPressed).merge()
   printOut(logInTrigger)

   print("button x2")
   logInButton.onNext()
   logInButton.onNext()
   print("key")
   enterPressed.onNext()

   let firstNameField = BehaviorSubject<String>(value: "")
   let lastNameField = BehaviorSubject<String>(value: "")

   firstNameField.onNext("Radek")

   let name = Observable.combineLatest(firstNameField, lastNameField) { "\($0) \($1)" }
   printOut(name)

   lastNameField.onNext("P")
   lastNameField.onNext("Pie")
   lastNameField.onNext("Pietruszewski")
   firstNameField.onNext("Radoslaw")

   let logInRequests = logInTrigger.withLatestFrom(name).map { "Log in with \($0)" }
   printOut(logInRequests)

   logInButton.onNext()

   firstNameField.onNext("Radek")
   enterPressed.onNext()
}

print("--")

do {
   typealias Feed = PublishSubject<String>
   let myFollowers = PublishSubject<Feed>()

   let tweetsFromLatestFollower = myFollowers.switchLatest()
   printOut(tweetsFromLatestFollower)

   let a2 = Feed()
   a2.onNext("hey")
   myFollowers.onNext(a2)
   a2.onNext("panda")
   a2.onNext("berlin")

   let maku = Feed()
   myFollowers.onNext(maku)
   a2.onNext("ignored pandas")
   maku.onNext("cats")
   maku.onNext("blah blah")
   a2.onNext("why does no one see me")
   a2.onCompleted()
   maku.onNext("FOOD")
//    maku.onCompleted() // this doesn't complete transformed observable
//    maku.onError(CustomError()) // this does propagate
   myFollowers.onCompleted() // this doesn't complete transformed observable, only stops new followers
   maku.onNext("Huh")
//    maku.onCompleted() // completes because outer observable is also completed
}

print("--")

do {
   let tweets = PublishSubject<String>()

   printOut(tweets.map { "Length: \($0.characters.count)" })

   tweets.onNext("Hey!")
   tweets.onNext("This is kinda cool")
   tweets.onNext("Well what if")
   tweets.onNext("I dunno ..shrug")

   tweets.onCompleted()
}

print("--")

do {
   typealias Feed = PublishSubject<String>
   var people: [String: Feed] = [:]

   let follows = PublishSubject<String>()
   let followsFeeds = follows.map { people[$0]! }
   let feedTweets = followsFeeds.merge()

   printOut(feedTweets)

   let a2 = Feed()
   a2.onNext("panda")
   people["a2"] = a2
   follows.onNext("a2")

   a2.onNext("PANDA")
   a2.onNext("hey panda")

   let maku = Feed()
   people["maku"] = maku
   follows.onNext("maku")

   a2.onNext("seriously panda")
   maku.onNext("cats tho")
   maku.onNext("berlin")
   a2.onNext("yeah berlin")
}

print("--")

do {
   typealias Feed = PublishSubject<String>
   var people: [String: Feed] = [:]

   let follows = PublishSubject<String>()
   let feedTweets = follows.flatMap { people[$0]! }

   printOut(feedTweets)

   let a2 = Feed()
   a2.onNext("panda")
   people["a2"] = a2
   follows.onNext("a2")

   a2.onNext("PANDA")
   a2.onNext("hey panda")

   let maku = Feed()
   people["maku"] = maku
   follows.onNext("maku")

   a2.onNext("seriously panda")
   maku.onNext("cats tho")
   maku.onNext("berlin")
   a2.onNext("yeah berlin")

}

print("--")

do {
   typealias Feed = PublishSubject<String>
   var people: [String: Feed] = [:]

   let follows = PublishSubject<String>()
   let followsFeeds = follows.map { people[$0]! }
   let feedTweets = followsFeeds.switchLatest()

   printOut(feedTweets)

   let a2 = Feed()
   a2.onNext("panda")
   people["a2"] = a2
   follows.onNext("a2")

   a2.onNext("PANDA")
   a2.onNext("hey panda")

   let maku = Feed()
   people["maku"] = maku
   follows.onNext("maku")

   a2.onNext("seriously panda")
   maku.onNext("cats tho")
   maku.onNext("berlin")
   a2.onNext("yeah berlin")

}

print("--")

do {
   typealias Feed = PublishSubject<String>
   var people: [String: Feed] = [:]

   let follows = PublishSubject<String>()
   let feedTweets = follows.flatMapLatest { people[$0]! }

   printOut(feedTweets)

   let a2 = Feed()
   a2.onNext("panda")
   people["a2"] = a2
   follows.onNext("a2")

   a2.onNext("PANDA")
   a2.onNext("hey panda")

   let maku = Feed()
   people["maku"] = maku
   follows.onNext("maku")

   a2.onNext("seriously panda")
   maku.onNext("cats tho")
   maku.onNext("berlin")
   a2.onNext("yeah berlin")
}

print("--")

do {
   struct Player {
       let score: Variable<Int>
   }

   let jack = Player(score: Variable(50))
   let peter = Player(score: Variable(20))

   let allPlayersEver = ReplaySubject<Player>.createUnbounded()
   let newScoresFromAllPlayers = allPlayersEver.flatMap { $0.score.asObservable() }

   printOut(newScoresFromAllPlayers)

   allPlayersEver.onNext(jack)
   peter.score.value = 30 // ignored
   jack.score.value += 5
   jack.score.value = 65

   allPlayersEver.onNext(peter)
   jack.score.value += 1
   peter.score.value = 40
   peter.score.value = 50
   jack.score.value = 100

//    printOut(allPlayersEver) // full replay

   print("--")

   let currentScoresFromAllPlayers = allPlayersEver // full replay
       .flatMap { $0.score.asObservable().take(1) } // don't take more

   printOut(currentScoresFromAllPlayers)
}

print("--")

do {
   struct Player {
       let score: Variable<Int>
   }

   let jack = Player(score: Variable(50))
   let peter = Player(score: Variable(20))

   let allPlayersEver = ReplaySubject<Player>.createUnbounded()
   let newScoresFromLatestPlayer = allPlayersEver.flatMapLatest { $0.score.asObservable() }

   printOut(newScoresFromLatestPlayer)

   allPlayersEver.onNext(jack)
   peter.score.value = 30 // ignored
   jack.score.value += 5
   jack.score.value = 65

   allPlayersEver.onNext(peter)
   jack.score.value += 1 // ignored
   peter.score.value = 40
   peter.score.value = 50
   jack.score.value = 100 // ignored
}

do {
   let feed = ReplaySubject<String>.createUnbounded()

   let withoutDuplicates = feed.distinctUntilChanged()
   printOut(withoutDuplicates)

   feed.onNext("hey")
   feed.onNext("boom")
   feed.onNext("boom")
   feed.onNext("lols")
   feed.onNext("well thats right")
   feed.onNext("boom")
   feed.onCompleted()

   print("--")

   let onlyFourLetters = feed.filter { $0.characters.count == 4 }
   printOut(onlyFourLetters)

   print("--")

   let beforeIGetTiredWithReadingLongTweets = feed.takeWhile { $0.characters.count < 5 }
   printOut(beforeIGetTiredWithReadingLongTweets)

   print("--")

   let onlyLongTweet = feed.single { $0.characters.count > 5 }
   printOut(onlyLongTweet) // error if there's 0 or >1

   print("--")

   let secondTweet = feed.elementAt(1)
   printOut(secondTweet)

   print("--")

   let lastTwo = feed.takeLast(2)
   printOut(lastTwo)

   print("--")

   let twoAfterFirstTwo = feed.skip(2).take(2)
   printOut(twoAfterFirstTwo)
}

do {
   let feed = ReplaySubject<String>.createUnbounded()
   let timeForWork = PublishSubject<Void>()

   let tweets = feed.takeUntil(timeForWork)
   printOut(tweets)

   feed.onNext("hey")
   feed.onNext("yo hey")
   feed.onNext("pandas")

   timeForWork.onNext()

   feed.onNext("oops")
   feed.onNext("ignored")
}

do {
   let feed = ReplaySubject<String>.createUnbounded()
   let timeForBreak = PublishSubject<Void>()

   let tweets = feed.skipUntil(timeForBreak)
   printOut(tweets)

   feed.onNext("hey")
   feed.onNext("yo hey")
   feed.onNext("pandas")

   timeForBreak.onNext()

   feed.onNext("PANDAS")
   feed.onNext("FOOD")
}

do {
   let feed = ReplaySubject<String>.createUnbounded()
   let working = Variable(false)

//    let tweets = Observable.combineLatest(feed, working.asObservable()) { ($0, $1) }
   let tweets = feed.withLatestFrom(working.asObservable()) { ($0, $1) }
       .filter { _, working in !working }
       .map { tweet, _ in tweet }

   printOut(tweets)

   feed.onNext("hey")
   feed.onNext("pandas")

   working.value = true

   feed.onNext("nah")
   feed.onNext("ignoring me!")

   working.value = false

   feed.onNext("lets check out")
   feed.onNext("some spacex newx")
}

do {
   let feed = PublishSubject<String>()

   let allTweets = feed.toArray()
   printOut(allTweets)

   feed.onNext("foo")
   feed.onNext("bar")
   feed.onNext("baz")
   feed.onCompleted()
}

print("--")

do {
   let numbers = Observable.of(5, 10, 800)

   let sum = numbers.reduce(0, accumulator: +)
   printOut(sum)
}

do {
   let feed = PublishSubject<String>()

   let allTweets = feed.reduce([], accumulator: { $0 + [$1] })
   printOut(allTweets)

   feed.onNext("foo")
   feed.onNext("bar")
   feed.onNext("baz")
   feed.onCompleted()
}

print("--")

do {
   let first = Observable.of("foo", "bar", "baz")
   let second = Observable.of("1","2","3")

   let allStrings = first.concat(second)
   printOut(allStrings)
}

print("--")

do {
   let first = Observable.of("foo", "bar", "baz")
   let second = Observable.of("1","2","3")

   let allStrings = Observable.concat([first, second])
   printOut(allStrings)
}

print("--")

do {
   let first = Observable.of("foo", "bar", "baz")
   let second = Observable.of("1","2","3")

   let allStrings = Observable.of(first, second).concat()
   printOut(allStrings)
}

print("--")

do {
   let checklists = PublishSubject<Observable<String>>()

   let taskTimeline = checklists.concat()
   printOut(taskTimeline)

   let preFlight = ReplaySubject<String>.createUnbounded()
   preFlight.onNext("check this")
   preFlight.onNext("check that")

   checklists.onNext(preFlight)

   preFlight.onNext("verify engines")
   preFlight.onNext("verify seatbelts on")

   print("adding second checklist")
   let landing = ReplaySubject<String>.createUnbounded()
   checklists.onNext(landing)

   preFlight.onNext("do this other thing")
//    preFlight.onError(CustomError()) // terminates whole sequence

   landing.onNext("this isn't here yet but will be")
   landing.onNext("flaps")
   landing.onNext("throttle")

   preFlight.onNext("check if landing gear is stowed")
   preFlight.onCompleted()

//    checklists.onError(CustomError()) // terminates sequence
   checklists.onCompleted() // doesn't complete whole sequence, because landing not completed

   landing.onNext("minimums!")
   landing.onCompleted()
//    checklists.onCompleted()
}

print("--")

do {
   let feed = PublishSubject<Int>()

   feed.subscribe { print("First: \($0)") }.addDisposableTo(bag)

   feed.onNext(1)
   feed.onNext(2)
   feed.onNext(3)

   feed.subscribe { print("Second: \($0)") }.addDisposableTo(bag)

   feed.onNext(4)
   feed.onNext(5)

   feed.onCompleted()
}

print("--")

func testInterval() {
   let clock = Observable<Int>.interval(1, scheduler: MainScheduler.instance)

   printOut(clock)

   playgroundShouldContinueIndefinitely()
}

//testInterval()

func testInterval2() {
   let ticker = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
   let stop = PublishSubject<Void>()
   let clock = ticker.takeUntil(stop)

   delay(5) { stop.onNext() }

   print("Subscribing...")
   printOut(clock)

   playgroundShouldContinueIndefinitely()
}

//testInterval2()

func testInterval3() {
   let clock = Observable<Int>.interval(1, scheduler: MainScheduler.instance)

   print("Subscribing...")
   clock.subscribe { print("FIRST: \($0)") }.addDisposableTo(bag)

   delay(3) {
       print("Subscribing to second...")
       clock.subscribe { print("SECOND: \($0)") }.addDisposableTo(bag)
   }

   delay(6) {
       print("Subscribing to third...")
       clock.subscribe { print("THIRD: \($0)") }.addDisposableTo(bag)
   }

   playgroundShouldContinueIndefinitely()
}

//testInterval3()

func testPublishConnect() {
   let ticker = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
   let clock: ConnectableObservable<Int> = ticker.publish()

   print("Subscribing...")
   clock.subscribe { print("FIRST: \($0)") }.addDisposableTo(bag)

   delay(4) {
       print("Connecting...")
       clock.connect().addDisposableTo(bag)
   }

   playgroundShouldContinueIndefinitely()
}

//testPublishConnect()

func testPublishConnect2() {
   let ticker = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
   let clock: ConnectableObservable<Int> = ticker.publish()

   print("Subscribing...")
   let first = clock.subscribe { print("FIRST: \($0)") }

   delay(3) {
       print("Connecting...")
       clock.connect().addDisposableTo(bag)
   }

   delay(6) {
       print("Disposing first")
       first.dispose()
   }

   delay(9) {
       print("Subscribing second")
       clock.subscribe { print("SECOND: \($0)") }.addDisposableTo(bag)
   }

   playgroundShouldContinueIndefinitely()
}

//testPublishConnect2()

func testPublishConnect3() {
   let ticker = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
   let clock: ConnectableObservable<Int> = ticker.publish()

   print("Subscribing...")
   let first = clock.subscribe { print("FIRST: \($0)") }
   var clockConnection: Disposable?

   delay(3) {
       print("Connecting...")
       clockConnection = clock.connect()
   }

   delay(6) {
       print("Disposing connection")
       clockConnection?.dispose()
   }

   delay(9) {
       print("Subscribing second")
       clock.subscribe { print("SECOND: \($0)") }.addDisposableTo(bag)
   }

   playgroundShouldContinueIndefinitely()
}

func testPublishConnect4() {
   let ticker = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
   let clock: ConnectableObservable<Int> = ticker.publish()

   print("Subscribing...")
   clock.subscribe { print("FIRST: \($0)") }.addDisposableTo(bag)

   delay(2) {
       print("Connecting...")
       clock.connect().addDisposableTo(bag)
   }

   delay(5) {
       print("Subscribing second")
       clock.subscribe { print("SECOND: \($0)") }.addDisposableTo(bag)
   }

   delay(8) {
       print("Subscribing third")
       clock.subscribe { print("SECOND: \($0)") }.addDisposableTo(bag)
   }

   playgroundShouldContinueIndefinitely()
}

//testPublishConnect4()

func testReplay() {
   let ticker = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
   let clock: ConnectableObservable<Int> = ticker.replay(1)

   clock.connect().addDisposableTo(bag)

   print("Subscribing...")
   clock.subscribe { print("FIRST: \($0)") }.addDisposableTo(bag)

   delay(5) {
       print("Subscribing second")
       clock.subscribe { print("SECOND: \($0)") }.addDisposableTo(bag)
   }

   playgroundShouldContinueIndefinitely()
}

//testReplay()

func testReplay2() {
   let ticker = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
   let clock: ConnectableObservable<Int> = ticker.replayAll()

   clock.connect().addDisposableTo(bag)

   print("Subscribing...")
   clock.subscribe { print("FIRST: \($0)") }.addDisposableTo(bag)

   delay(5) {
       print("Subscribing second")
       clock.subscribe { print("SECOND: \($0)") }.addDisposableTo(bag)
   }

   playgroundShouldContinueIndefinitely()
}

//testReplay2()

func testMulticast() {
   let subject = PublishSubject<Int>()
   let ticker = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
   let clock = ticker.multicast(subject)

   print("Subscribing to subject")
   subject.subscribe { print("\($0)") }.addDisposableTo(bag)

   print("Subscribing first…")
   clock.subscribe { print("\tfirst: \($0)") }.addDisposableTo(bag)

   delay(2) {
       print("Connecting…")
       clock.connect().addDisposableTo(bag)
   }

   delay(5) {
       print("Subscribing second…")
       clock.subscribe { print("\tsecond: \($0)") }.addDisposableTo(bag)
   }

   playgroundShouldContinueIndefinitely()
}

//testMulticast()

func testMulticast2() {
   let subject = ReplaySubject<Int>.createUnbounded()
   let ticker = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
   let clock = ticker.multicast(subject)

   print("Subscribing to subject")
   subject.subscribe { print("\($0)") }.addDisposableTo(bag)

   print("Subscribing first…")
   clock.subscribe { print("\tfirst: \($0)") }.addDisposableTo(bag)

   delay(2) {
       print("Connecting…")
       clock.connect().addDisposableTo(bag)
   }

   delay(7) {
       print("Subscribing second…")
       clock.subscribe { print("\tsecond: \($0)") }.addDisposableTo(bag)
   }

   playgroundShouldContinueIndefinitely()
}

//testMulticast2()

func refCount() {
    let ticker = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
    let clock = ticker.publish().refCount() // same as ticker.share()
    
    print("Subscribing first…")
    let first = clock.subscribe { print("first: \($0)") }
    var second: Disposable?
    
    delay(3) {
        print("Subscribing second…")
        second = clock.subscribe { print("second: \($0)") }
    }
    
    delay(6) {
        print("disposing first")
        first.dispose()
    }
    
    delay(9) {
        print("disposing second")
        second!.dispose()
    }
    
    delay(12) {
        print("Subscribing third…")
        clock.subscribe { print("third: \($0)") }.addDisposableTo(bag)
    }
    
    playgroundShouldContinueIndefinitely()
}

//refCount()

func shareReplay() {
   let ticker = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
   let clock = ticker.shareReplay(1)

   print("Subscribing first…")
   let first = clock.subscribe { print("first: \($0)") }
   var second: Disposable?

   delay(3) {
       print("Subscribing second…")
       second = clock.subscribe { print("second: \($0)") }
   }

   delay(6) {
       print("disposing first")
       first.dispose()
   }

   delay(9) {
       print("disposing second")
       second!.dispose()
   }

   delay(12) {
       print("Subscribing third…")
       clock.subscribe { print("third: \($0)") }.addDisposableTo(bag)
   }

   playgroundShouldContinueIndefinitely()
}

//shareReplay()

func shareReplayLatestWhileConnected() {
   let ticker = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
   let clock = ticker.shareReplayLatestWhileConnected()

   print("Subscribing first…")
   let first = clock.subscribe { print("first: \($0)") }
   var second: Disposable?

   delay(3) {
       print("Subscribing second…")
       second = clock.subscribe { print("second: \($0)") }
   }

   delay(6) {
       print("disposing first")
       first.dispose()
   }

   delay(9) {
       print("disposing second")
       second!.dispose()
   }

   delay(12) {
       print("Subscribing third…")
       clock.subscribe { print("third: \($0)") }.addDisposableTo(bag)
   }

   playgroundShouldContinueIndefinitely()
}

//shareReplayLatestWhileConnected()

do {
   let failingSequence = PublishSubject<String>()

   let sequence = failingSequence
       .catchError {
           return .of("Huh", "\($0) doesn't look good", "send help")
       }
   printOut(sequence)

   failingSequence.onNext("Hey")
   failingSequence.onNext("Whats")
   failingSequence.onNext("Up")
   failingSequence.onError(CustomError())
}

do {
   let failingSequence = PublishSubject<String>()
   let sequence = failingSequence.catchErrorJustReturn("Don't worry!")
   printOut(sequence)

   failingSequence.onNext("Hey")
   failingSequence.onNext("Whats")
   failingSequence.onNext("Up")
   failingSequence.onError(CustomError())
}

print("--")

do {
   let fetchTweetsMock = Observable<[String]>.error(CustomError())
   let safeFetchTweets = fetchTweetsMock.catchErrorJustReturn([])
   printOut(safeFetchTweets)
}

do {
   let fetchedTweets: [String] = ["foo", "bar", "baz"]
   let fetchTweets: Observable<[String]> = .just(fetchedTweets)
   printOut(fetchTweets)
   let individualTweets: Observable<String> = fetchTweets.flatMap { Observable.from($0) }
   printOut(individualTweets)
}

do {
   var count = 0
   let mockNetworkCall = Observable<String>.create { observer in
       count += 1

       if count == 3 {
           observer.onNext("Hey, something from the 'net!")
           observer.onCompleted()
       } else {
           observer.onError(CustomError())
       }

       return Disposables.create()
   }

   let betterCall = mockNetworkCall
       .do(onError: { print("Ooops, an error:", $0) })
       .retry(3)

   printOut(betterCall)
}

func timerTest() {
   let timer = Observable<Int>.timer(3, scheduler: MainScheduler.instance)

   print("Not even subscribed yet")

   delay(3) {
       print("okay, subscribing…")
       printOut(timer)
   }

   playgroundShouldContinueIndefinitely()
}

//timerTest()

func timerTest2() {
   let timer = Observable<Int>.timer(3, period: 1, scheduler: MainScheduler.instance)

   print("subscribing…")
   printOut(timer)

   playgroundShouldContinueIndefinitely()
}

//timerTest2()

func timerTest3() {
   let timer = Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance)

   print("subscribing…")
   printOut(timer)

   playgroundShouldContinueIndefinitely()
}

//timerTest3()

func intervalTest() {
   let timer = Observable<Int>.interval(1, scheduler: MainScheduler.instance)

   print("subscribing…")
   printOut(timer.take(3))

   playgroundShouldContinueIndefinitely()
}

//intervalTest()

func takeTime() {
   let ticker = Observable<Int>.interval(0.5, scheduler: MainScheduler.instance)

   print("subscribing…")
   printOut(ticker.take(5, scheduler: MainScheduler.instance))

   playgroundShouldContinueIndefinitely()
}

//takeTime()

func skipTime() {
   let ticker = Observable<Int>.timer(0, period: 0.5, scheduler: MainScheduler.instance)

   print("Subscribing…")
   printOut(ticker.skip(3, scheduler: MainScheduler.instance))

   playgroundShouldContinueIndefinitely()
}

//skipTime()

func skipTakeTime() {
   let ticker = Observable<Int>.timer(0, period: 0.5, scheduler: MainScheduler.instance)

   print("Subscribing…")
   printOut(ticker
       .skip(3, scheduler: MainScheduler.instance)
       .take(6, scheduler: MainScheduler.instance)) // starts counting now, so need to be 3+3

   playgroundShouldContinueIndefinitely()
}

//skipTakeTime()

import CoreGraphics

func randomNumers() {
   let streamOfRandom = Observable<Int>.timer(0, period: 0.1, scheduler: MainScheduler.instance)
       .map { _ in Int(arc4random_uniform(UInt32(10_000))) }

   print("Subscribing…")
//    printOut(streamOfRandom)

   let sampler = Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance)
   printOut(streamOfRandom.sample(sampler))

   playgroundShouldContinueIndefinitely()
}

//randomNumers()

func throttleRandom() {
   let streamOfRandom = Observable<Int>.timer(0, period: 0.1, scheduler: MainScheduler.instance)
       .map { _ in Int(arc4random_uniform(UInt32(10_000))) }

   print("Subscribing…")
   printOut(streamOfRandom.throttle(1.0, scheduler: MainScheduler.instance))

   playgroundShouldContinueIndefinitely()
}

//throttleRandom()

func randomStream() -> Observable<Int> {
   func random() -> Int {
       return Int(arc4random_uniform(UInt32(10_000)))
   }

   func nextTick(observer: AnyObserver<Int>, next: @escaping () -> Void) {
       let delayTime = Double(random()) / 5_000

       delay(delayTime + 0.1) {
           observer.onNext(random())
           next()
       }
   }

   return .create { observer in
       var disposed = false
       var next: () -> Void = { }
       next = {
           if !disposed {
               nextTick(observer: observer, next: next)
           }
       }
       next()
       return Disposables.create {
           disposed = true
       }
   }
}

func testRandomStream() {
   let random = randomStream()

//    printOut(random)
   printOut(random.take(10, scheduler: MainScheduler.instance))

   playgroundShouldContinueIndefinitely()
}

//testRandomStream()

func testRandomStreamSample() {
   let startTime = Date()
   let time = { () -> String in
       let time = "\(Date().timeIntervalSince(startTime))"
       return time.substring(to: time.index(time.startIndex, offsetBy: 4))
   }
   let random = randomStream().share()

   random.subscribe { print("\(time()): \($0)") }
       .addDisposableTo(bag)

   let sampler = Observable<Int>.interval(1, scheduler: MainScheduler.instance)

   random.sample(sampler)
       .subscribe { print("\(time()): \tSample: \($0)") }
       .addDisposableTo(bag)

   playgroundShouldContinueIndefinitely()
}

//testRandomStreamSample()

import Foundation

func testRandomStreamThrottle() {
   let startTime = Date()
   let time = { () -> String in
       let time = "\(Date().timeIntervalSince(startTime))"
       return time.substring(to: time.index(time.startIndex, offsetBy: 4))
   }
   let random = randomStream().share()

   random.subscribe { print("\(time()): \($0)") }
       .addDisposableTo(bag)

   random.throttle(1.0, scheduler: MainScheduler.instance)
       .subscribe { print("\(time()): \tThrottled: \($0)") }
       .addDisposableTo(bag)

   playgroundShouldContinueIndefinitely()
}

//testRandomStreamThrottle()

func testRandomStreamDebounce() {
   let startTime = Date()
   let time = { () -> String in
       let time = "\(Date().timeIntervalSince(startTime))"
       return time.substring(to: time.index(time.startIndex, offsetBy: 4))
   }
   let random = randomStream().share()

   random.subscribe { print("\(time()): \($0)") }
       .addDisposableTo(bag)

   random.debounce(1.0, scheduler: MainScheduler.instance)
       .subscribe { print("\(time()): \tDebounced: \($0)") }
       .addDisposableTo(bag)

   playgroundShouldContinueIndefinitely()
}

//testRandomStreamDebounce()

func testIgnoreElements() {
   let ticker = Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance)
   let stream = ticker.take(6)

   stream.subscribe { print($0) }
       .addDisposableTo(bag)

   let ignoring = stream.ignoreElements()

   ignoring.subscribe { print("\t\($0)") }
       .addDisposableTo(bag)

   playgroundShouldContinueIndefinitely()
}

//testIgnoreElements()

func testIgnoreElements2() {
   let ticker = Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance)
   let stream = ticker
       .map { i -> Int in
           if i == 5 {
               throw CustomError()
           } else {
               return i
           }
       }

   stream.subscribe { print($0) }
       .addDisposableTo(bag)

   let ignoring = stream.ignoreElements()

   ignoring.subscribe { print("\t\($0)") }
       .addDisposableTo(bag)

   playgroundShouldContinueIndefinitely()
}

//testIgnoreElements2()

func testRandomStreamBuffer() {
   let startTime = Date()
   let time = { () -> String in
       let time = "\(Date().timeIntervalSince(startTime))"
       return time.substring(to: time.index(time.startIndex, offsetBy: 4))
   }
   let random = randomStream().share()

   random.subscribe { print("\(time()): \($0)") }
       .addDisposableTo(bag)

   random.buffer(timeSpan: 1, count: 2, scheduler: MainScheduler.instance)
       .subscribe { print("\(time()): \tBuffered: \($0)") }
       .addDisposableTo(bag)

   playgroundShouldContinueIndefinitely()
}

//testRandomStreamBuffer()

func testRandomStreamWindow() {
   let startTime = Date()
   let time = { () -> String in
       let time = "\(Date().timeIntervalSince(startTime))"
       return time.substring(to: time.index(time.startIndex, offsetBy: 4))
   }
   let random = randomStream().share()

   random.subscribe { print("\(time()): \($0)") }
       .addDisposableTo(bag)

   random.window(timeSpan: 1, count: 2, scheduler: MainScheduler.instance)
       .do(onNext: { print("\(time()): \tNew window: \($0)") })
       .flatMap { $0.toArray() }
       .subscribe { print("\(time()): \tWindow: \($0)") }
       .addDisposableTo(bag)

   // window + map toArray + merge is the same as:
//    random.buffer(timeSpan: 1, count: 2, scheduler: MainScheduler.instance)
//        .subscribe { print("\(time()): \tBuffered: \($0)") }
//        .addDisposableTo(bag)

   playgroundShouldContinueIndefinitely()
}

//testRandomStreamWindow()

func testTimeout() {
   let ticker = Observable<Int>.interval(5, scheduler: MainScheduler.instance)

//    let timeout = ticker.timeout(3, scheduler: MainScheduler.instance)
   let timeout = ticker.timeout(3, other: Observable.just(1000), scheduler: MainScheduler.instance)

   print("Subscribing…")
   printOut(timeout)

   playgroundShouldContinueIndefinitely()
}

//testTimeout()

func testTimeout2() {
   func fakeRequest(_ n: Int) -> Observable<String> {
       switch n {
       case 0: return Observable.just("Pretty 0").delay(2, scheduler: MainScheduler.instance)
       case 1: return Observable.just("Pretty 1").delay(10, scheduler: MainScheduler.instance)
       case 2: return Observable.just("Pretty 2").delay(1, scheduler: MainScheduler.instance)
       case 3: return Observable.error(CustomError()).delay(3, scheduler: MainScheduler.instance)
       case 4: return Observable.just("Pretty 4").delay(3, scheduler: MainScheduler.instance)
       default: return .error(CustomError())
       }
   }

   let userInput = Observable<Int>.interval(2.5, scheduler: MainScheduler.instance)
       .takeWhile { $0 < 5 }

   let niceNumbers = userInput
       .do(onNext: { print("Fetching for \($0)") })
       .map {
           fakeRequest($0)
               .timeout(4.0, scheduler: MainScheduler.instance)
               .catchErrorJustReturn("Not sure but originally \($0)")
       }
       .concat()

   print("Starting…")
   niceNumbers
       .subscribe { print("\t\($0)") }
       .addDisposableTo(bag)

   playgroundShouldContinueIndefinitely()
}

//testTimeout2()

do {
   let sequence = Observable<Int>.range(start: 0, count: 5)
       .concat(Observable<Int>.error(CustomError()))

   let dontGiveUp = sequence.retryWhen({ errors in
           errors.take(2)
       })

   printOut(dontGiveUp)
}

func testRetryWhen() {
   let sequence = Observable<Int>.range(start: 0, count: 5)
       .concat(Observable<Int>.error(CustomError()))

   let dontGiveUp = sequence.retryWhen({ errors in
       errors
           .do(onNext: { print("Huh, error: \($0)") })
           .take(2)
           .delay(2, scheduler: MainScheduler.instance)
           .concat(Observable<Error>.error(CustomError()))
   })

   print("Lets try...")
   dontGiveUp
       .subscribe { print($0) }
       .addDisposableTo(bag)

   playgroundShouldContinueIndefinitely()
}

//testRetryWhen()

class ImportantResource: Disposable {
   init() {
       print("Resource: init")
   }

   var name: String { return "bleep bloop" }

   func dispose() {
       print("Resource: dispose")
   }

   deinit {
       print("Resource: deinit")
   }
}

do {
   let sequenceUsingResource = Observable<String>
       .using({ ImportantResource() }) { resource in
           return Observable<Int>.range(start: 0, count: 5)
               .map { "\($0), \(resource.name)" }
       }

   printOut(sequenceUsingResource)
}

func testDelaySubscription() {
   let sequence = Observable<String>.deferred {
       print("Subscribed…")
       return .of("hey", "you")
   }

   print("Starting…")
   printOut(sequence.delaySubscription(2, scheduler: MainScheduler.instance))

   playgroundShouldContinueIndefinitely()
}

//testDelaySubscription()

func isMainThread() -> Bool {
   return Thread.isMainThread
}

do {
   let sequence = Observable<Int>
       .generate(
           initialState: 0,
           condition: {
               print("Condition (\($0)). \(isMainThread())")
               return $0 < 5
           }, iterate: {
               print("Iterate (\($0)). \(isMainThread())")
               return $0 + 1
           })

   let sequenceWithChecks = sequence
       .do(onNext: { i in
           print("Do. \(i) \(isMainThread())")
       })
       .map { i -> Int in
           print("Map. \(isMainThread())")
           return i * 3
       }
       .filter {
           print("Filter. \(isMainThread())")
           return $0 % 2 == 0
       }

   func defaultTest() {
       print("Before main thread test… \(isMainThread())")

       sequenceWithChecks
           .subscribe {
               print("\($0) \(isMainThread())")
           }
   }

   defaultTest()

   func subscribeBackgroundTest() {
       print("---\nBefore subscribe-on-background test… \(isMainThread())")

       sequenceWithChecks
           .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
           .subscribe {
               print("\($0) \(isMainThread())")
           }
   }

//    subscribeBackgroundTest()

   func observeBackgroundTest() {
       print("---\nBefore observe-on-background test… \(isMainThread())")

       sequenceWithChecks
           .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
           .map { i -> Int in
               print("Map2 \(isMainThread())")
               return i + 1
           }
           .subscribe {
               print("\($0) \(isMainThread())")
           }
   }

//    observeBackgroundTest()

   func subscribeBackgroundObserveMainTest() {
       print("---\nBefore subscribe-background/observe-main test… \(isMainThread())")

       sequenceWithChecks
           .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
           .map { i -> Int in
               print("Map2 \(isMainThread())")
               return i + 1
           }
           .observeOn(MainScheduler.instance)
           .subscribe {
               print("\($0) \(isMainThread())")
           }
   }

//    subscribeBackgroundObserveMainTest()

   func oneTaskInBackgroundTest() {
       print("---\nBefore one task in background test… \(isMainThread())")

       sequenceWithChecks
           .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
           .map { i -> Int in
               print("Seriously Hard Map \(isMainThread())")
               return i + 1
           }
           .observeOn(MainScheduler.instance)
           .subscribe {
               print("\($0) \(isMainThread())")
           }
   }

//    oneTaskInBackgroundTest()
}

func urlRequest(url: URL) -> Observable<(Data, HTTPURLResponse)> {
   return .create { observer in
       let task = URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
           guard let data = data, let response = response else {
               observer.onError(error ?? CustomError())
               return
           }

           guard let httpResponse = response as? HTTPURLResponse else {
               observer.onError(CustomError())
               return
           }

           observer.onNext((data, httpResponse))
           observer.onCompleted()
       }

       let cancel = Disposables.create {
           task.cancel()
       }

       task.resume()

       return cancel
   }
}

func urlRequestTest() {
   print("---")
   print("Starting request…")

   urlRequest(url: URL(string: "http://example.com")!)
       .map { (data, response) in
           String(data: data, encoding: .utf8)!
       }
       .subscribe { print($0) }
       .addDisposableTo(bag)

   playgroundShouldContinueIndefinitely()
}

//urlRequestTest()

func testDisposablesTimeoutRetry() {
   func never(withID id: Int) -> Observable<String> {
       return .create { _ in
           print("Starting fake event \(id)")
           return Disposables.create {
               print("Canceling \(id)")
           }
       }
   }

   print("--")
   let stream = PublishSubject<Int>()

   print("Subscribing…")
   stream
       .do(onNext: { print("About to schedule fake network operation for \($0)") })
       .flatMapLatest { i in
           never(withID: i)
               .timeout(5, scheduler: MainScheduler.instance)
               .retry(3)
               .catchErrorJustReturn("Empty (actually error)")
       }
       .startWith("Empty (starting point)")
       .subscribe { print("\t\($0)") }
       .addDisposableTo(bag)

   stream.onNext(0)
   stream.onNext(1)
   stream.onNext(2)

   delay(20) {
       stream.onNext(3)
   }

   playgroundShouldContinueIndefinitely()
}

//testDisposablesTimeoutRetry()

import RxCocoa

func urlRequestTest2() {
    let session = URLSession.shared
    session.rx.response(request: URLRequest(url: URL(string: "http://example.com")!))
        .subscribe { print($0) }
        .addDisposableTo(bag)
    
    session.rx.data(request: URLRequest(url: URL(string: "http://example.com")!))
        .subscribe(onNext: { data in
            print(String(data: data, encoding: .utf8)!)
        })
        .addDisposableTo(bag)
    
    session.rx.json(url: URL(string: "https://api.github.com/users/radex/orgs")!)
        .subscribe { print($0) }
        .addDisposableTo(bag)
    
    // fire and forget
    _ = session.rx
        .json(url: URL(string: "https://api.github.com/users/radex/orgs")!)
        .subscribe()
    
    playgroundShouldContinueIndefinitely()
}

//urlRequestTest2()

do {
    class SomeNSObject: NSObject {
        override init() {
            super.init()
            print("SomeNSObject: init")
        }
        
        deinit {
            print("SomeNSObject: deinit")
        }
    }
    
    let obj = SomeNSObject()
    
    obj.rx.deallocated
        .subscribe { print($0) }
        .addDisposableTo(bag)
    
    print("Subscribed!")
}

print("--")

do {
    class ObjectWithProp: NSObject {
        dynamic var foo: String = "foo"
    }
    
    let obj = ObjectWithProp()
    
    obj.rx.observeWeakly(String.self, "foo")
        .subscribe { print($0) }
        .addDisposableTo(bag)
    
    obj.foo = "blah"
    obj.foo = "bar"
}

print("--")

protocol OptionalType {
    associatedtype _Wrapped
    func asOptional() -> Optional<_Wrapped>
}
extension Optional: OptionalType {
    typealias _Wrapped = Wrapped
    func asOptional() -> Optional<Wrapped> {
        return self
    }
}
extension ObservableType where E: OptionalType {
    func ignoreNil() -> Observable<E._Wrapped> {
        return self
            .filter { $0.asOptional() != nil }
            .map { $0.asOptional()! }
    }
}

do {
    class ObjectWithProp: NSObject {
        dynamic var rect: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    
    let obj = ObjectWithProp()
    
    obj.rx.observeWeakly(CGRect.self, "rect")
        .ignoreNil()
        .subscribe { print($0) }
        .addDisposableTo(bag)
    
    obj.rect = obj.rect.offsetBy(dx: 10, dy: 10)
    obj.rect.size.width = 10
    obj.rect.size.height = 10
}

print("--")

func urlRequestFireForgetTest() {
    print("Subscribed")

    do {
        _ = URLSession.shared.rx
            .json(url: URL(string: "https://api.github.com/users/radex/orgs")!)
            .subscribe()
    }

    print("Fired and forgotten")

    playgroundShouldContinueIndefinitely()
}

extension Notification.Name {
    static let test = Notification.Name("my_playground_test_1")
}

do {
    let nc = NotificationCenter.default
    
    nc.rx.notification(.test)
        .subscribe { print($0) }
        .addDisposableTo(bag)
    
    nc.post(name: .test, object: nil)
    nc.post(name: .test, object: NSObject(), userInfo: ["foo": 10])
}

print("--")

func fakeNetworkSharedResources() {
    var _count = 0
    let fakeRequest = Observable<String>.deferred {
        _count += 1
        print("Creating request \(_count)")
        return Observable.just("Result of request #\(_count)")
            .delay(5, scheduler: MainScheduler.instance)
            .do(onDispose: { print("Request #\(_count) disposed") })
    }.shareReplayLatestWhileConnected()
    
    // I'm not exactly sure why share() doesn't work here
    
    print("Subscribing first")
    fakeRequest
        .subscribe { print("\tFirst: \($0)") }
        .addDisposableTo(bag)
    
    print("Subscribing second")
    fakeRequest
        .subscribe { print("\tSecond: \($0)") }
        .addDisposableTo(bag)
    
    delay(2) {
        print("Subscribing third")
        fakeRequest
            .subscribe { print("\tThird: \($0)") }
            .addDisposableTo(bag)
    }
    
    delay(6) {
        print("Subscribing fourth")
        fakeRequest
            .subscribe { print("\tFourth: \($0)") }
            .addDisposableTo(bag)
    }
    
    delay(8) {
        print("Subscribing fifth")
        fakeRequest
            .subscribe { print("\tFifth: \($0)") }
            .addDisposableTo(bag)
    }
    
    playgroundShouldContinueIndefinitely()
}

//fakeNetworkSharedResources()

//refCount()

do {
    var _count = 0
    
    let fakeRequest1 = PublishSubject<String>()
    let fakeRequest2 = PublishSubject<String>()
    
    let requestStream = PublishSubject<String>()
    requestStream
        .subscribe { print("\t\tStream: \($0)") }
        .addDisposableTo(bag)
    
    let fakeRequest = Observable<String>.deferred {
        _count += 1
        print("Creating request \(_count)")
        if _count == 1 {
            return fakeRequest1
        } else {
            return fakeRequest2
        }
    }.multicast(requestStream).refCount()
    
    // I'm not exactly sure why share() doesn't work here
    
    print("Subscribing first")
    fakeRequest
        .take(1)
        .do(onDispose: { print("Disposed 1") })
        .subscribe { print("\tFirst: \($0)") }
        .addDisposableTo(bag)
    
    print("Subscribing second")
    fakeRequest
        .take(1)
        .do(onDispose: { print("Disposed 2") })
        .subscribe { print("\tSecond: \($0)") }
        .addDisposableTo(bag)
    
    fakeRequest1.onNext("Result of request #1")
    //fakeRequest1.onCompleted()
    
    print("Subscribing fourth")
    fakeRequest
        .take(1)
        .do(onDispose: { print("Disposed 4") })
        .subscribe { print("\tFourth: \($0)") }
        .addDisposableTo(bag)
    
    print("Subscribing fifth")
    fakeRequest
        .take(1)
        .do(onDispose: { print("Disposed 5") })
        .subscribe { print("\tFifth: \($0)") }
        .addDisposableTo(bag)
    
    fakeRequest2.onNext("Result of request #2")
    //fakeRequest2.onCompleted()
}

print("--")

struct CompletionObservable: ObservableType {
    typealias E = Void
    
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
    
    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == Void {
        return _events.subscribe(observer)
    }
    
    func asObservable() -> Observable<Void> {
        return _events
    }
}

extension ObservableType {
    func completionOnly() -> CompletionObservable {
        return CompletionObservable(self)
    }
}

do {
    let empty = Observable<String>.empty()
    printOut(empty)
    
    let emptyCompletion = empty.completionOnly()
    printOut(emptyCompletion.asObservable())
    
    emptyCompletion
        .subscribe { print($0) }
        .addDisposableTo(bag)
    
    print("--")
    
    let just = Observable<Int>.just(10)
    printOut(just)
    
    let justCompletion = just.completionOnly()
    printOut(justCompletion.asObservable())
    
    let from = Observable<Int>.from([1,2,3,4])
    printOut(from)
    
    let fromCompletion = from.completionOnly()
    printOut(fromCompletion.asObservable())
    
    let subject = PublishSubject<Int>()
    
    subject
        .subscribe { print("Subject: \($0)") }
        .addDisposableTo(bag)
    
    subject.onNext(1)
    subject.onNext(2)
    
    subject
        .completionOnly()
        .subscribe { print("\t\($0)") }
        .addDisposableTo(bag)
    
    subject.onNext(3)
    subject.onNext(4)
    subject.onCompleted()
}

print("--")

func asyncCompletion() {
    let fakeNetworkRequest = Observable<String>.just("Some request response")
        .delay(5, scheduler: MainScheduler.instance)
        .shareReplayLatestWhileConnected()
    
    print("request made")
    
    fakeNetworkRequest
        .subscribe { print("Request: \($0)") }
        .addDisposableTo(bag)
    
    fakeNetworkRequest
        .completionOnly()
        .subscribe { print("\t\($0)") }
        .addDisposableTo(bag)
    
    playgroundShouldContinueIndefinitely()
}

//asyncCompletion()

do {
    let req = Observable<String>.just("foo")
    
    let transformed = req.completionOnly() // Observable<String>, not CompletionObservable anymore!
        .map { _ in "bar" }
    
    printOut(transformed)
}

struct OneObservable<T>: ObservableType {
    typealias E = T
    private let _events: Observable<T>
    
    public init<Ev: ObservableType>(_ events: Ev) where Ev.E == T {
        _events = events.single()
    }
    
    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == T {
        return _events.subscribe(observer)
    }

    func asObservable() -> Observable<T> {
        return _events
    }
}

extension ObservableType {
    func justOne() -> OneObservable<E> {
        return OneObservable(self)
    }
}

do {
    printOut(Observable<String>.empty().justOne().asObservable())
    printOut(Observable<String>.just("hey").justOne().asObservable())
    printOut(Observable<String>.of("hey", "you").justOne().asObservable())
    
    let subject = PublishSubject<String>()
    subject
        .justOne()
        .subscribe { print($0) }
        .addDisposableTo(bag)
    
    print("here comes first:")
    subject.onNext("hey")
//    print("here comes second:")
//    subject.onNext("you")
    print("here comes completion:")
    subject.onCompleted()
}

import RxTest

//public func == (lhs: Recorded<Event<Void>>, rhs: Recorded<Event<Void>>) -> Bool {
//    guard lhs.time == rhs.time else { return false }// && lhs.value == rhs.value
//    
//    switch (lhs.value, rhs.value) {
//    case (.completed, .completed): return true
//    case (.next, .next): return true
//    case let (.error(e1), .error(e2)) where e1 == e2: return true
//    default: return false
//    }
//}

print("--")

public func == (lhs: Event<Void>, rhs: Event<Void>) -> Bool {
    let lhs1: Event<Int> = lhs.map { _ in 0 }
    let lhs2: Event<Int> = rhs.map { _ in 0 }
    return lhs1 == lhs2
}

public func == (lhs: Recorded<Event<Void>>, rhs: Recorded<Event<Void>>) -> Bool {
    return lhs.time == rhs.time && lhs.value == rhs.value
}

public func == (lhs: [Recorded<Event<Void>>], rhs: [Recorded<Event<Void>>]) -> Bool {
    return lhs.elementsEqual(rhs, by: ==)
}

do {
    let scheduler = TestScheduler(initialClock: 0)
    
    let xs = scheduler.createHotObservable([
        next(300, 1),
        next(400, 2),
        completed(500),
        ])
    
    let res = scheduler.start { xs.completionOnly().asObservable() }
    
    let correctMessages = [
        next(500, ()),
        completed(500),
    ]
    
    let correctSubscriptions = [
        Subscription(200, 500)
    ]
    
    assert(res.events == correctMessages)
    assert(xs.subscriptions == correctSubscriptions)
    print("S'all good")
}

do {
    let scheduler = TestScheduler(initialClock: 0)
    
    let xs: TestableObservable<Int> = scheduler.createHotObservable([
        completed(500),
        ])
    
    let res = scheduler.start { xs.completionOnly().asObservable() }
    
    let correctMessages = [
        next(500, ()),
        completed(500),
        ]
    
    let correctSubscriptions = [
        Subscription(200, 500)
    ]
    
    assert(res.events == correctMessages)
    assert(xs.subscriptions == correctSubscriptions)
    print("S'all good")
}

do {
    let scheduler = TestScheduler(initialClock: 0)
    
    let xs = scheduler.createHotObservable([
        next(300, 1)
        ])
    
    let res = scheduler.start { xs.completionOnly().asObservable() }
    
    let correctMessages: [Recorded<Event<Void>>] = [
        ]
    
    let correctSubscriptions = [
        Subscription(200, 1000)
    ]
    
    assert(res.events == correctMessages)
    assert(xs.subscriptions == correctSubscriptions)
    print("S'all good")
}

do {
    let scheduler = TestScheduler(initialClock: 0)
    
    let xs = scheduler.createHotObservable([
        next(300, 1),
        completed(600),
        ])
    
    let res = scheduler.start { xs.completionOnly().asObservable() }
    
    let correctMessages = [
        next(600, ()),
        completed(600),
        ]
    
    let correctSubscriptions = [
        Subscription(200, 600)
    ]
    
    assert(res.events == correctMessages)
    assert(xs.subscriptions == correctSubscriptions)
    print("S'all good")
}

do {
    let scheduler = TestScheduler(initialClock: 0)
    
    let xs = scheduler.createHotObservable([
        next(300, 1),
        next(500, 1),
        error(700, CustomError())
        ])
    
    let res = scheduler.start { xs.completionOnly().asObservable() }
    
    let correctMessages: [Recorded<Event<Void>>] = [
        error(700, CustomError()),
        ]
    
    let correctSubscriptions = [
        Subscription(200, 700)
    ]
    
    assert(res.events == correctMessages)
    assert(xs.subscriptions == correctSubscriptions)
    print("S'all good")
}

import RxBlocking

print("--")

func blockingTest1() {
    let fakeRequest = Observable.just("heeey").delay(5, scheduler: MainScheduler.instance)
    print("Blocking…")
    print(try! fakeRequest.toBlocking().toArray())
    print("Unblocked!")
}

//blockingTest1()

func sharedReplayDisposalTest() {
    let cancel = PublishSubject<Void>()
    let fakeNetworkRequest = Observable.just("Hey!").delay(4, scheduler: MainScheduler.instance).takeUntil(cancel).debug("FakeRequest")
    let sharedRequest = fakeNetworkRequest.shareReplayLatestWhileConnected()
    
    var disposeBag = DisposeBag()
    
    sharedRequest.subscribe { print("First: \($0)") }.addDisposableTo(disposeBag)
    
    delay(1) {
        sharedRequest.subscribe { print("Second: \($0)") }.addDisposableTo(disposeBag)
    }
    
//    delay(2) {
//        cancel.onNext()
//    }
    
    delay(2) {
        disposeBag = DisposeBag()
    }
    
    playgroundShouldContinueIndefinitely()
}

sharedReplayDisposalTest()
//: [Next](@next)
//: [Next](@next)
