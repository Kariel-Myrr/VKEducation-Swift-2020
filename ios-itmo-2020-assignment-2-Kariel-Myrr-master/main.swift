import Foundation

protocol Calculatable: Numeric {
    init?(_ string: String)
}

extension Int: Calculatable {}
extension Double: Calculatable {}

extension Optional {
    func unwrap(or error: Error) throws -> Wrapped {
        guard let wrapped = self else {
            throw error
        }
        return wrapped
    }
}

struct Operator<Num: Calculatable>: CustomStringConvertible {
    let name: String
    let precedence: Int
    let f: (Num, Num) -> Num

    var description: String {
        return self.name
    }
}

enum Token<Num: Calculatable>: CustomStringConvertible {
    case value(Num)
    case `operator`(Operator<Num>)

    var description: String {
        switch self {
        case .value(let num): return "\(num)"
        case .operator(let op): return op.description
        }
    }
}

func defaultOperators<Num: Calculatable>() -> [Operator<Num>] {
    [
        Operator(name: "+", precedence: 10, f: +),
        Operator(name: "-", precedence: 10, f: -),
        Operator(name: "*", precedence: 20, f: *),
    ]
}

enum EvaluationError: Error, CustomStringConvertible {
    case invalidToken(token: String)
    case arityError

    var description: String {
        switch self {
        case .invalidToken(token: let token):
            return "Invalid token: \"\(token)\""
        case .arityError:
            return "arity error"
        }
    }
}

func eval<Num: Calculatable>(_ input: String, operators ops: [Operator<Num>] = defaultOperators()) throws -> Num {
    let operators: [String: Operator<Num>] = Dictionary(uniqueKeysWithValues: ops.map { ($0.name, $0) })

    let tokens: [Token<Num>] = try input.components(separatedBy: .whitespaces).map {
        try (Num($0).map(Token.value) ?? operators[$0].map(Token.operator)).unwrap(or: EvaluationError.invalidToken(token: $0))
    }

    let rpnExt: (rpn: [Token<Num>], opStack: [Operator<Num>]) = tokens.reduce(into: (rpn: [], opStack: [])) { (acc, token) in
        switch token {
        case .value:
            acc.rpn.append(token)
        case .operator(let op):
            while let topOp = acc.opStack.last, topOp.precedence > op.precedence {
                acc.rpn.append(.operator(topOp))
                acc.opStack.removeLast()
            }
            acc.opStack.append(op)
        }
    }

    let rpn = rpnExt.rpn + rpnExt.opStack.reversed().map(Token.operator)

    let valStack: [Num] = try rpn.reduce(into: [Num]()) { (valStack, token) in
        switch token {
        case .value(let num):
            valStack.append(num)
        case .operator(let op):
            guard let lhs = valStack.popLast(), let rhs = valStack.popLast() else {
                throw EvaluationError.arityError
            }
            valStack.append(op.f(lhs, rhs))
        }
    }

    guard let result = valStack.first, valStack.count == 1 else {
        throw EvaluationError.arityError
    }

    return result
}

print(try eval("1 * 2 + 3") as Double)
