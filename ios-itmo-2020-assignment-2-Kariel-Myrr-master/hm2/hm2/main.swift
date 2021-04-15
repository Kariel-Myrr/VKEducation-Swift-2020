import Foundation

protocol Calculatable: Numeric {
    init?(_ string: String)
    
    static func div(first : Self, second : Self) throws -> Self
    static func deg(first : Self, second : Self) throws -> Self
    static func negate(this : Self) -> Self
    static func abs(this : Self) -> Self
    static func fack(this : Self) -> Self
}

extension Int: Calculatable {
    static func div(first : Self, second : Self) throws -> Self {
        guard (second != 0) else {
            throw EvaluationError.divideByZero
        }
        return first/second
    }
    static func deg(first : Self, second : Self) throws -> Self {
        guard second >= 0  else {
            throw EvaluationError.incorrectDeg
        }
        return Int(truncating: NSDecimalNumber(decimal : pow(Decimal.init(first), second)))
    }
    static func negate(this: Self) -> Self {
        return -this
    }
    static func abs(this: Self ) -> Self{
        return this > 0 ? this : -this
    }
    static func fack(this : Self) -> Self{
        var res = 1
        var thisC = this
        while (thisC > 0){
            res = res * this
            thisC = thisC - 1
        }
        return res
    }
}

extension Double: Calculatable {
    static func div(first : Self, second : Self) throws -> Self {
        guard (second != 0) else {
            throw EvaluationError.divideByZero
        }
        return first/second
    }
    static func deg(first : Self, second : Self) throws -> Self {
        guard second >= 0  else {
            throw EvaluationError.incorrectDeg
        }
        return pow(first, second)
    }
    static func negate(this: Self) -> Self {
        return -this
    }
    static func abs(this: Self ) -> Self{
        return this > 0 ? this : -this
    }
    static func fack(this : Self) -> Self{
        var res = 1.0
        var thisC = this
        while (thisC > 0){
            res = res * this
            thisC = thisC - 1.0
        }
        return res
    }
}

extension Optional {
    func unwrap(or error: Error) throws -> Wrapped {
        guard let wrapped = self else {
            throw error
        }
        return wrapped
    }
}

struct Operator<Num: Calculatable>: CustomStringConvertible{
    let name: String
    let precedence: Int
    let f: (Num, Num) throws -> Num

    var description: String {
        return self.name
    }
}

struct AtomOperator<Num: Calculatable>: CustomStringConvertible {
    let name: String
    let precedence: Int
    let f: (Num) throws -> Num

    var description: String {
        return self.name
    }
}


enum Token<Num: Calculatable>: CustomStringConvertible {
    case value(Num)
    case `operator`(Operator<Num>)
    case `atomOperator`(AtomOperator<Num>)

    var description: String {
        switch self {
        case .value(let num): return "\(num)"
        case .operator(let op): return op.description
        case .atomOperator(let op): return op.description
        }
    }
}

func defaultAtomOperators<Num: Calculatable>() -> [AtomOperator<Num>] {
    [
        AtomOperator(name: "negate", precedence: 30, f: Num.negate),
        AtomOperator(name: "abs", precedence: 30, f: Num.abs),
        AtomOperator(name: "!", precedence: 30, f: Num.fack)
    ]
}

func defaultOperators<Num: Calculatable>() -> [Operator<Num>] {
    [
        Operator(name: "+", precedence: 10, f: +),
        Operator(name: "-", precedence: 10, f: -),
        Operator(name: "*", precedence: 20, f: *),
        Operator(name: "/", precedence: 20, f: Num.div),
        Operator(name: "^", precedence: 25, f: Num.deg)
    ]
}

enum Breaket {
    case open
    case close
}

enum EvaluationError: Error, CustomStringConvertible {
    case invalidToken(token: String)
    case arityError
    case divideByZero
    case incorrectDeg

    var description: String {
        switch self {
        case .invalidToken(token: let token):
            return "Invalid token: \"\(token)\""
        case .arityError:
            return "arity error"
        case .divideByZero:
            return "divide by zero"
        case .incorrectDeg:
            return "incorrect deg"
        }
    }
}

func eval<Num: Calculatable>(_ input: String, operators ops: [Operator<Num>] = defaultOperators(), atomOperators aOps: [AtomOperator<Num>] = defaultAtomOperators()) throws -> Num {
    let operators: [String: Operator<Num>] = Dictionary(uniqueKeysWithValues: ops.map { ($0.name, $0) })
    let atomOperators: [String: AtomOperator<Num>] = Dictionary(uniqueKeysWithValues: aOps.map { ($0.name, $0) })

    let tokens: [Token<Num>] = try input.components(separatedBy: .whitespaces).map {
        try (Num($0).map(Token.value)  ?? (atomOperators[$0].map(Token.atomOperator) ?? operators[$0].map(Token.operator))).unwrap(or: EvaluationError.invalidToken(token: $0))
    }
    
    let rpnExt: (rpn: [Token<Num>], opStack: [Token<Num>]) = tokens.reduce(into: (rpn: [], opStack: [])) { (acc, token) in
        switch token {
        case .value:
            acc.rpn.append(token)
        case .operator(let op):
            outerloop : while let token = acc.opStack.last{
                switch token {
                case .operator(let topOp):
                    if topOp.precedence < op.precedence {
                        break outerloop
                    }
                    acc.rpn.append(.operator(topOp))
                    acc.opStack.removeLast()
                case .atomOperator(let topOp):
                    if topOp.precedence < op.precedence {
                        break outerloop
                    }
                    acc.rpn.append(.atomOperator(topOp))
                    acc.opStack.removeLast()
                default:
                    continue
                }
            }
            acc.opStack.append(token)
        case .atomOperator(let op) :
            outerloop : while let token = acc.opStack.last{
                switch token {
                case .operator(let topOp):
                    if topOp.precedence < op.precedence {
                        break outerloop
                    }
                    acc.rpn.append(.operator(topOp))
                    acc.opStack.removeLast()
                case .atomOperator(let topOp):
                    if topOp.precedence < op.precedence {
                        break outerloop
                    }
                    acc.rpn.append(.atomOperator(topOp))
                    acc.opStack.removeLast()
                default:
                    continue
                }
            }
            acc.opStack.append(token)
        }
    }

    let rpn = rpnExt.rpn + rpnExt.opStack.reversed()

    let valStack: [Num] = try rpn.reduce(into: [Num]()) { (valStack, token) in
        switch token {
        case .value(let num):
            valStack.append(num)
        case .operator(let op):
            guard let lhs = valStack.popLast(), let rhs = valStack.popLast() else {
                throw EvaluationError.arityError
            }
            try valStack.append(op.f(rhs, lhs))
        case .atomOperator(let op):
            guard let hs = valStack.popLast() else {
                throw EvaluationError.arityError
            }
            try valStack.append(op.f(hs))
        }
    }

    guard let result = valStack.first, valStack.count == 1 else {
        throw EvaluationError.arityError
    }

    return result
}

print(try eval("2 ^ 2") as Int)
