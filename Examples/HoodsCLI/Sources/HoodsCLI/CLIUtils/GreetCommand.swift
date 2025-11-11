import ArgumentParser
import Hoods

struct Greet: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "greet",
        abstract: "Greet demo from Hoods."
    )

    @Option var name: InputableValue<String> = InputableValue(prompt: "What is your name?")

    mutating func run() throws {
        let name = try name.get()
        print("Hello \(name)!")
    }
}
