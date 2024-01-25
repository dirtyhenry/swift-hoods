import Blocks
import Foundation

public struct MailContent: Equatable {
    public let recipient: String
    public let subject: String
    public let body: String

    public init(recipient: String, subject: String, body: String) {
        self.recipient = recipient
        self.subject = subject
        self.body = body
    }
}

public extension MailContent {
    // MARK: Transform into a mailto URL

    func asMailtoURL() -> URL? {
        var mailtoComponents = MailtoComponents()
        mailtoComponents.recipient = recipient
        mailtoComponents.subject = subject
        mailtoComponents.body = body

        return mailtoComponents.url
    }
}
