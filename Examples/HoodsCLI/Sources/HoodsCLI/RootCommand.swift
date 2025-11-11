import ArgumentParser

@main
struct HoodsCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Hoods CLI Tool.",
        version: "0.1.0",
        subcommands: [
            DemoUtilsCommand.self,
            Greet.self
        ]
    )
}
