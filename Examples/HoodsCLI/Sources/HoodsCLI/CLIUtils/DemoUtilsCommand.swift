import ArgumentParser
import Hoods

struct DemoUtilsCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "demo",
        abstract: "Demo CLI utilities from Hoods."
    )

    @Option(help: "String Value")
    var stringInput: InputableValue<String> = .init(prompt: "String Input?")

    @Option(help: "Int Value")
    var intInput: InputableValue<Int> = .init(prompt: "Int Input?")

    mutating func run() throws {
        let string = try stringInput.get()
        print("string: \(string)")

        let int = try intInput.get()
        print("int: \(int)")
    }
}
