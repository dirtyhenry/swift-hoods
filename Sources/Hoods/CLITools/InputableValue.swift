import ArgumentParser
import Blocks

public struct InputableValue<Value: ExpressibleByArgument>: ExpressibleByArgument {
    private enum Input {
        case argumentValue(Value)
        case invalidArgumentValue
        case promptInput(String)
    }

    private var input: Input

    public init(argument: String) {
        if let value = Value(argument: argument) {
            input = .argumentValue(value)
        } else {
            input = .invalidArgumentValue
        }
    }

    public init(prompt: String) {
        input = .promptInput(prompt)
    }

    public func get() throws -> Value {
        switch input {
        case let .argumentValue(value):
            return value
        case let .promptInput(prompt):
            print(prompt)
            let inputString = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines)
            return try Value(argument: inputString ?? "") ?? { throw SimpleMessageError(message: "Required") }()
        case .invalidArgumentValue:
            throw SimpleMessageError(message: "Required")
        }
    }
}
