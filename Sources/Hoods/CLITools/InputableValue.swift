import ArgumentParser
import Blocks

/// A utility for handling values that can be initialized from command line arguments or user input prompts.
public struct InputableValue<Value: ExpressibleByArgument>: ExpressibleByArgument {
    private enum Input {
        case argumentValue(Value)
        case invalidArgumentValue
        case promptInput(String)
    }

    private var input: Input

    /// Initializes an `InputableValue` with a command line argument.
    ///
    /// - Parameter argument: The command line argument.
    public init(argument: String) {
        if let value = Value(argument: argument) {
            input = .argumentValue(value)
        } else {
            input = .invalidArgumentValue
        }
    }

    /// Initializes an `InputableValue` with a prompt for user input.
    ///
    /// - Parameter prompt: The prompt for user input.
    public init(prompt: String) {
        input = .promptInput(prompt)
    }

    /// Retrieves the value represented by the `InputableValue`.
    ///
    /// - Returns: The value if it can be obtained successfully.
    /// - Throws: An error if the value cannot be obtained.
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
