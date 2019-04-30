import Abstract

public protocol TypeConstructor {
    associatedtype ParameterType
}

public protocol TypeConstructor2: TypeConstructor {
    associatedtype SecondaryType
}

public protocol PureConstructible: TypeConstructor {
    static func pure(_ value: ParameterType) -> Self
}

// MARK: - Boolean

public extension Bool {
    /// Method version of &&
    func and(_ other: @autoclosure () -> Bool) -> Bool {
        return self && other()
    }
    
    /// Method version of ||
    func or(_ other: @autoclosure () -> Bool) -> Bool {
        return self || other()
    }
    
    /// Computed property representing the negation (like the ! prefix, or "== false")
    var not: Bool {
        return self == false
    }
    
    /// Method version of =>
    func implies(_ other: @autoclosure () -> Bool) -> Bool {
        return self.not.or(other())
    }
    
    func fold<A>(onTrue: @autoclosure () -> A, onFalse: @autoclosure () -> A) -> A {
        if self {
            return onTrue()
        } else {
            return onFalse()
        }
    }
    
    func ifTrue(_ call: () -> ()) {
        fold(onTrue: call(), onFalse: ())
    }
    
    func ifFalse(_ call: () -> ()) {
        fold(onTrue: (), onFalse: call())
    }
}

// MARK: - f
enum f {
    
    static func identity <A> (_ a: A) -> A {
        return a
    }
    
    static func identity <A,B> (_ a: A, _ b: B) -> (A,B) {
        return (a,b)
    }
    
    static func identity <A,B,C> (_ a: A, _ b: B, _ c: C) -> (A,B,C) {
        return (a,b,c)
    }
    
    static func pure0 <A> (_ a : A) -> () -> A {
        return { a }
    }
    
    static func pure <A,B> (_ a : A) -> (B) -> A {
        return { _ in a }
    }
    
    static func pure2 <A,B,C> (_ a : A) -> (B,C) -> A {
        return { _, _ in a }
    }
    
    static func pure3 <A,B,C,D> (_ a : A) -> (B,C,D) -> A {
        return { _, _, _ in a }
    }
    
    static func destructure <A,B,T> (_ function: @escaping (A,B) -> T) -> ((A,B)) -> T {
        return { tuple in function(tuple.0,tuple.1) }
    }
    
    static func destructure <A,B,C,T> (_ function: @escaping (A,B,C) -> T) -> ((A,B,C)) -> T {
        return { tuple in function(tuple.0,tuple.1,tuple.2) }
    }
    
    static func ignore () {}
    
    static func ignore <A> (_ a: A) {}
    
    static func ignore <A,B> (_ a: A, _ b: B) {}
    
    static func ignore <A,B,C> (_ a: A, _ b: B, _ c: C) {}
    
    static func first <A,B> (_ a: A, _ b: B) -> A {
        return a
    }
    
    static func first <A,B,C> (_ a: A, _ b: B, _ c: C) -> A {
        return a
    }
    
    static func second <A,B> (_ a: A, _ b: B) -> B {
        return b
    }
    
    static func second <A,B,C> (_ a: A, _ b: B, _ c: C) -> B {
        return b
    }
    
    static func third <A,B,C> (_ a: A, _ b: B, _ c: C) -> C {
        return c
    }
    
    static func flatten <A,B,C> (_ ab: (A,B), _ c: C) -> (A,B,C) {
        return (ab.0, ab.1, c)
    }
    
    static func flatten <A,B,C> (_ a: A, _ bc: (B,C)) -> (A,B,C) {
        return (a, bc.0, bc.1)
    }
    
    static func flatten <A,B> (_ ab: ((A,B))) -> (A,B) {
        return ab
    }
    
    static func flatten <A,B,C> (_ abc: ((A,B,C))) -> (A,B,C) {
        return abc
    }
    
    static func zip <A1,B1,A2,B2> (_ function1: @escaping (A1) -> B1, _ function2: @escaping (A2) -> (B2)) -> (A1,A2) -> (B1,B2) {
        return { a1, a2 in
            (function1(a1),function2(a2))
        }
    }
    
    static func zip <A1,B1,A2,B2,A3,B3> (_ function1: @escaping (A1) -> B1, _ function2: @escaping (A2) -> B2, _ function3: @escaping (A3) -> B3) -> (A1,A2,A3) -> (B1,B2,B3) {
        return { a1, a2, a3 in
            (function1(a1),function2(a2),function3(a3))
        }
    }
    
    static func duplicate <A> (_ a: A) -> (A,A) {
        return (a,a)
    }
    
    static func duplicate <A,B> (_ function: @escaping (A) -> B) -> (A,A) -> (B,B) {
        return zip(function, function)
    }
    
    static func triplicate <A> (_ a: A) -> (A,A,A) {
        return (a,a,a)
    }
    
    static func triplicate <A,B> (_ function: @escaping (A) -> B) -> (A,A,A) -> (B,B,B) {
        return zip(function, function, function)
    }
    
    static func with<A> (_ function: @escaping (inout A) -> ()) -> (A) -> A {
        return { a in
            var m = a
            function(&m)
            return m
        }
    }
    
    static func asTuple <A,B,C> (_ function: @escaping (A,B) -> C) -> ((A,B)) -> C {
        return { function($0.0,$0.1) }
    }
    
    static func embedFirst <A,B> (_ a: A) -> (B) -> (A,B) {
        return { b in
            (a,b)
        }
    }
    
    static func embedSecond <A,B> (_ b: B) -> (A) -> (A,B) {
        return { a in
            (a,b)
        }
    }
}

// MARK: - FunctionType

public protocol FunctionType {
    associatedtype SourceType
    associatedtype TargetType
    
    func call(_ source: SourceType) -> TargetType
    static func from(function: Function<SourceType,TargetType>) -> Self
}

extension Function: FunctionType {
    public static func from(function: Function<A, B>) -> Function<A, B> {
        return function
    }
}

// MARK: - Functor

public extension FunctionType {
    func dimap<A,B>(_ source: @escaping (A) -> SourceType, _ target: @escaping (TargetType) -> B) -> Function<A,B> {
        return Function<A,B>.init { value in target(self.call(source(value))) }
    }
    
    func map<T>(_ transform: @escaping (TargetType) -> T) -> Function<SourceType,T> {
        return dimap(f.identity, transform)
    }
    
    func contramap<T>(_ transform: @escaping (T) -> SourceType) -> Function<T,TargetType> {
        return dimap(transform, f.identity)
    }
    
    func carryOver() -> Function<SourceType, Product<SourceType, TargetType>> {
        return Function<SourceType, Product<SourceType, TargetType>>.init { source in
            Product.init(source, self.call(source))
        }
    }
    
    func toFunction() -> Function<SourceType,TargetType> {
        return dimap(f.identity, f.identity)
    }
}

//MARK: - Equatable

public extension FunctionType where TargetType: Equatable {
    static func == (lhs: Self, rhs: Self) -> (SourceType) -> Bool {
        return lhs.toFunction() == rhs.toFunction()
    }
}

//MARK: - PredicateSet

public extension FunctionType where TargetType == Bool {
    static var universe: Function<SourceType,Bool> {
        return Function<SourceType,Bool> { _ in true }
    }
    
    static var empty: Function<SourceType,Bool> {
        return Function<SourceType,Bool> { _ in false }
    }
    
    func contains(_ value: SourceType) -> Bool {
        return call(value)
    }
    
    func inverted() -> Function<SourceType,Bool> {
        return Function<SourceType,Bool> {
            self.contains($0).not
        }
    }
    
    func union (_ other: Function<SourceType,Bool>) -> Function<SourceType,Bool> {
        return Function<SourceType,Bool> {
            self.contains($0) || other.contains($0)
        }
    }
    
    func intersection (_ other: Function<SourceType,Bool>) -> Function<SourceType,Bool> {
        return Function<SourceType,Bool> {
            self.contains($0) && other.contains($0)
        }
    }
    
    func subtraction (_ other: Function<SourceType,Bool>) -> Function<SourceType,Bool> {
        return Function<SourceType,Bool> {
            self.contains($0) && other.contains($0).not
        }
    }
    
    func exclusiveDisjunction (_ other: Function<SourceType,Bool>) -> Function<SourceType,Bool> {
        let unionSet = self.union(other)
        let intersectionSet = self.intersection(other)
        
        return unionSet.subtraction(intersectionSet)
    }
}

//MARK: - Utility

public extension FunctionType where SourceType == TargetType {
    static var identity: Function<SourceType,TargetType> {
        return Function.init { $0 }
    }
}

// MARK: - ProductType

public protocol ProductType {
    associatedtype FirstType
    associatedtype SecondType
    
    func fold<T>(_ transform: (FirstType,SecondType) -> T) -> T
    static func from(product: Product<FirstType,SecondType>) -> Self
}

// sourcery: testBifunctor
// sourcery: testConstruct = "init(x,y)"
extension Product: ProductType {
    public typealias FirstType = A
    public typealias SecondType = B
    
    public static func from(product: Product<A, B>) -> Product<A, B> {
        return product
    }
}

extension Product: Error where A: Error, B: Error {}

// MARK: - Equatable

extension ProductType where FirstType: Equatable, SecondType: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.toProduct() == rhs.toProduct()
    }
}

// MARK: - Projections

public extension ProductType {
    func toProduct() -> Product<FirstType,SecondType> {
        return fold(Product<FirstType,SecondType>.init)
    }
    
    var first: FirstType {
        return fold { first, _ in first }
    }
    
    var second: SecondType {
        return fold { _, second in second }
    }
    
    var unwrap: (FirstType,SecondType) {
        return fold(f.identity)
    }
}

// MARK: - Evaluation

public extension ProductType where FirstType: FunctionType, FirstType.SourceType == SecondType {
    func eval() -> FirstType.TargetType {
        return fold { (function, value) -> FirstType.TargetType in
            function.call(value)
        }
    }
}

public extension ProductType where SecondType: FunctionType, SecondType.SourceType == FirstType {
    func eval() -> SecondType.TargetType {
        return fold { (value, function) -> SecondType.TargetType in
            function.call(value)
        }
    }
}

// MARK: - Functor

public extension ProductType {
    func bimap<T,U>(_ onFirst: (FirstType) -> T, _ onSecond: (SecondType) -> U) -> Product<T,U> {
        return fold { first, second in Product<T,U>.init(onFirst(first), onSecond(second)) }
    }
    
    func mapFirst<T>(_ transform: (FirstType) -> T) -> Product<T,SecondType> {
        return bimap(transform, f.identity)
    }
    
    func mapSecond<U>(_ transform: (SecondType) -> U) -> Product<FirstType,U> {
        return bimap(f.identity, transform)
    }
}

// MARK: - Cross Interactions

public extension ProductType where FirstType: CoproductType {
    func insideOut() -> Coproduct<Product<FirstType.LeftType,SecondType>,Product<FirstType.RightType,SecondType>> {
        return fold { first, second in
            first.bimap(
                { Product.init($0, second) },
                { Product.init($0, second) })
        }
    }
}

public extension ProductType where SecondType: CoproductType {
    func insideOut() -> Coproduct<Product<FirstType,SecondType.LeftType>,Product<FirstType,SecondType.RightType>> {
        return fold { first, second in
            second.bimap(
                { Product.init(first, $0) },
                { Product.init(first, $0) })
        }
    }
}

// MARK: - Algebra

/// Default implementations for product types

public extension ProductType where FirstType: Magma, SecondType: Magma {
    static func <> (lhs: Self, rhs: Self) -> Self {
        return Self.from(product: lhs.toProduct() <> rhs.toProduct())
    }
}

public extension ProductType where FirstType: Monoid, SecondType: Monoid {
    static var empty: Self {
        return Self.from(product: .empty)
    }
}

// MARK: - CoproductType
public protocol CoproductType {
    associatedtype LeftType
    associatedtype RightType
    
    func fold<T>(onLeft: (LeftType) -> T, onRight: (RightType) -> T) -> T
    static func from(coproduct: Coproduct<LeftType,RightType>) -> Self
}

// sourcery: testBifunctor
// sourcery: testConstruct = "random(x,y)"
extension Coproduct: CoproductType {
    public typealias LeftType = A
    public typealias RightType = B
    
    static public func from(coproduct: Coproduct<A, B>) -> Coproduct<A, B> {
        return coproduct
    }
}

extension Coproduct: Error where A: Error, B: Error {}

// MARK: - Equatable

extension CoproductType where LeftType: Equatable, RightType: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.toCoproduct() == rhs.toCoproduct()
    }
}

// MARK: - Projections

public extension CoproductType {
    func toCoproduct() -> Coproduct<LeftType,RightType> {
        return fold(onLeft: Coproduct<LeftType,RightType>.left, onRight: Coproduct<LeftType,RightType>.right)
    }
    
    func tryLeft() ->  LeftType? {
        return fold(onLeft: f.identity, onRight: { _ in nil })
    }
    
    func tryRight() ->  RightType? {
        return fold(onLeft: { _ in nil }, onRight: f.identity)
    }
    
    func foldToLeft(_ transform: (RightType) -> LeftType) -> LeftType {
        return fold(onLeft: f.identity, onRight: transform)
    }
    
    func foldToRight(_ transform: (LeftType) -> RightType) -> RightType {
        return fold(onLeft: transform, onRight: f.identity)
    }
    
    func toBool() -> Bool {
        return fold(
            onLeft: f.pure(false),
            onRight: f.pure(true))
    }
}

public extension CoproductType where LeftType == RightType {
    func merged() -> LeftType {
        return fold(onLeft: f.identity, onRight: f.identity)
    }
}

// MARK: - Functor

public extension CoproductType {
    func bimap<T,U>(_ onLeft: (LeftType) -> T, _ onRight: (RightType) -> U) -> Coproduct<T,U> {
        return fold(
            onLeft: { Coproduct<T,U>.left(onLeft($0)) },
            onRight: { Coproduct<T,U>.right(onRight($0)) })
    }
    
    func mapLeft<T>(_ transform: (LeftType) -> T) -> Coproduct<T,RightType> {
        return bimap(transform, f.identity)
    }
    
    func mapRight<U>(_ transform: (RightType) -> U) -> Coproduct<LeftType,U> {
        return bimap(f.identity, transform)
    }
}

// MARK: - Cross-Interactions

public extension CoproductType where LeftType: ProductType {
    func insideOut() -> Product<Coproduct<LeftType.FirstType,RightType>,Coproduct<LeftType.SecondType,RightType>> {
        return fold(
            onLeft: { $0.bimap(Coproduct.left,Coproduct.left) },
            onRight: { rightValue in Product.init(Coproduct.right(rightValue), Coproduct.right(rightValue)) })
    }
}

public extension CoproductType where RightType: ProductType {
    func insideOut() -> Product<Coproduct<LeftType,RightType.FirstType>,Coproduct<LeftType,RightType.SecondType>> {
        return fold(
            onLeft: { leftValue in Product.init(Coproduct.left(leftValue), Coproduct.left(leftValue)) },
            onRight: { $0.bimap(Coproduct.right,Coproduct.right) })
    }
}

// MARK: - InclusiveType
public protocol InclusiveType {
    associatedtype LeftType
    associatedtype RightType
    
    func fold<T>(onLeft: @escaping (LeftType) -> T, onCenter: @escaping (LeftType,RightType) -> T, onRight: @escaping (RightType) -> T) -> T
    static func from(inclusive: Inclusive<LeftType,RightType>) -> Self
}

// sourcery: testBifunctor
// sourcery: testConstruct = "random(x,y)"
extension Inclusive: InclusiveType {
    public typealias LeftType = A
    public typealias RightType = B
    
    public static func from(inclusive: Inclusive<A, B>) -> Inclusive<A, B> {
        return inclusive
    }
}

extension Inclusive: Error where A: Error, B: Error {}

// MARK: - Equatable

extension InclusiveType where LeftType: Equatable, RightType: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.toInclusive() == rhs.toInclusive()
    }
}

// MARK: - Projections
public extension InclusiveType {
    func toInclusive() -> Inclusive<LeftType,RightType> {
        return fold(
            onLeft: Inclusive.left,
            onCenter: Inclusive.center,
            onRight: Inclusive.right)
    }
    
    func tryToProduct() -> Product<LeftType,RightType>? {
        return fold(
            onLeft: f.pure(nil),
            onCenter: Product.init,
            onRight: f.pure(nil))
    }
    
    func tryToCoproduct() -> Coproduct<LeftType,RightType>? {
        return fold(
            onLeft: Coproduct.left,
            onCenter: f.pure2(nil),
            onRight: Coproduct.right)
    }
    
    func tryLeft() -> LeftType? {
        return fold(
            onLeft: f.identity,
            onCenter: f.first,
            onRight: f.pure(nil))
    }
    
    func tryRight() -> RightType? {
        return fold(
            onLeft: f.pure(nil),
            onCenter: f.second,
            onRight: f.identity)
    }
    
    func tryBoth() -> (LeftType,RightType)? {
        return fold(
            onLeft: f.pure(nil),
            onCenter: f.identity,
            onRight: f.pure(nil))
    }
}
public extension InclusiveType where LeftType == RightType {
    var left: LeftType {
        return fold(onLeft: f.identity, onCenter: f.first, onRight: f.identity)
    }
    
    var right: RightType {
        return fold(onLeft: f.identity, onCenter: f.second, onRight: f.identity)
    }
    
    func merged(composing: @escaping (LeftType,LeftType) -> LeftType) -> LeftType {
        return fold(onLeft: f.identity, onCenter: composing, onRight: f.identity)
    }
}

public extension InclusiveType where LeftType == RightType, LeftType: Semigroup {
    func merged() -> LeftType {
        return merged(composing: <>)
    }
}

// MARK: - Functor

public extension InclusiveType {
    func bimap<T,U>(_ onLeft: @escaping (LeftType) -> T, _ onRight: @escaping (RightType) -> U) -> Inclusive<T,U> {
        return fold(
            onLeft: { Inclusive<T,U>.left(onLeft($0)) },
            onCenter: { Inclusive<T,U>.center(onLeft($0), onRight($1)) },
            onRight: { Inclusive<T,U>.right(onRight($0)) })
    }
    
    func mapLeft<T>(_ transform: @escaping (LeftType) -> T) -> Inclusive<T,RightType> {
        return fold(
            onLeft: { Inclusive<T,RightType>.left(transform($0)) },
            onCenter: { Inclusive<T,RightType>.center(transform($0),$1) },
            onRight: { Inclusive<T,RightType>.right($0) })
    }
    
    func mapRight<T>(_ transform: @escaping (RightType) -> T) -> Inclusive<LeftType,T> {
        return fold(
            onLeft: { Inclusive<LeftType,T>.left($0) },
            onCenter: { Inclusive<LeftType,T>.center($0,transform($1)) },
            onRight: { Inclusive<LeftType,T>.right(transform($0)) })
    }
}

// Algebra

/// Default definitions for inclusive types

public extension InclusiveType where LeftType: Magma, RightType: Magma {
    static func <> (lhs: Self, rhs: Self) -> Self {
        return Self.from(inclusive: lhs.toInclusive() <> rhs.toInclusive())
    }
}

public enum Result<Failure,Parameter> where Failure: Error {
    case success(Parameter)
    case failure(Failure)
    
    public func run() throws -> Parameter {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
    
    public func fold <A> (onSuccess: (Parameter) -> A, onFailure: (Failure) -> A) -> A {
        switch self {
        case .success(let value):
            return onSuccess(value)
        case .failure(let error):
            return onFailure(error)
        }
    }
}

extension Result: Equatable where Failure: Equatable, Parameter: Equatable {}

extension Result: CoproductType {
    public typealias LeftType = Failure
    public typealias RightType = Parameter
    
    public func fold<T>(onLeft: (Failure) -> T, onRight: (Parameter) -> T) -> T {
        return fold(onSuccess: onRight, onFailure: onLeft)
    }
    
    public static func from(coproduct: Coproduct<Failure, Parameter>) -> Result<Failure, Parameter> {
        switch coproduct {
        case let .left(error):
            return .failure(error)
        case let .right(value):
            return .success(value)
        }
    }
}

extension Result: TypeConstructor2 {
    public typealias ParameterType = Parameter
    public typealias SecondaryType = Failure
}

extension Result: PureConstructible {
    public static func pure(_ value: ParameterType) -> Result {
        return Result.success(value)
    }
}

public extension Result {
    typealias Generic<F,A> = Result<F,A> where F: Error
}

public extension Result {
    func map <A> (_ transform: (ParameterType) -> A) -> Result<Failure,A> {
        switch self {
        case let .success(value):
            return .success(transform(value))
        case let .failure(error):
            return .failure(error)
        }
    }
    
    func mapError <A> (_ transform: (Failure) -> A) -> Result<A,ParameterType> {
        switch self {
        case let .success(value):
            return .success(value)
        case let .failure(error):
            return .failure(transform(error))
        }
        
    }
    
    static func lift <A> (_ function: @escaping (ParameterType) -> A) -> (Result) -> Result<Failure,A> {
        return { $0.map(function) }
    }
    
    static func zip <F1,A,F2,B> (_ first: Result<F1,A>, _ second: Result<F2,B>) -> Result<Inclusive<F1,F2>,(A,B)> where Failure == Inclusive<F1,F2>, ParameterType == (A,B) {
        switch (first, second) {
        case let (.success(leftValue), .success(rightValue)):
            return .success((leftValue,rightValue))
            
        case let (.failure(leftError), .failure(rightError)):
            return .failure(.center(leftError,rightError))
            
        case let (.failure(error), _):
            return .failure(.left(error))
            
        case let (_, .failure(error)):
            return .failure(.right(error))
        }
    }
    
    static func zipMerged <A,B> (_ first: Result<Failure,A>, _ second: Result<Failure,B>) -> Result<Failure,(A,B)> where Failure: Semigroup {
//        switch (first, second) {
//        case let (.success(leftValue), .success(rightValue)):
//            return .success((leftValue,rightValue))
//
//        case let (.failure(leftError), .failure(rightError)):
//            return .failure(leftError <> rightError)
//
//        case let (.failure(error), _):
//            return .failure(error)
//
//        case let (_, .failure(error)):
//            return .failure(error)
//        }
        
                return Generic.zip(first, second).mapError { $0.merged() }
    }
}
