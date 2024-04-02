import ArgumentParser
import Blocks

/// A utility for handling values that can be initialized from command line arguments or user input prompts.
///
/// Use `InputableValue` for command-line interfaces options that are mandatory for your command and that you want to
/// be input by the user either by the option at calling time, or interactively at run time.
///
/// For example, for the user to provide their name:
///
/// ```swift
/// @main
/// struct Greet: ParsableCommand {
///     @Option var name: InputableValue<String> = InputableValue(prompt: "What is your name?")
///
///     mutating func run() {
///         let name = try name.get()
///         print("Hello \(name)!")
///     }
/// }
/// ```
///
/// If `name` is known when `get()` is called, then the value will be used without any interaction. Otherwise, a
/// prompt will provide the user an opportunity to fill their name.
///
/// ```
/// $ greet --name Alicia
/// Hello Alicia!
/// $ greet
/// What is your name?
/// Alicia
/// Hello Alicia!
/// ```
///
/// `InputableValue` works with any type that complies with ``ExpressibleByArgument``, including `Int`, `Bool`, but
/// also any custom types conforming to it.
public struct InputableValue<Value: ExpressibleByArgument>: ExpressibleByArgument {
    private enum Input {
        case argumentValue(Value)
        case invalidArgumentValue(String)
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
            input = .invalidArgumentValue(argument)
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
        case let .invalidArgumentValue(argument):
            throw SimpleMessageError(message: "Could not get `ExpressibleByArgument` value from input \(argument)")
        }
    }
}

extension InputableValue: CustomStringConvertible {
    public var description: String {
        "will prompt the user for input"
    }
}
