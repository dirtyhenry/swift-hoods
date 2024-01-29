import Blocks

public extension MailtoComponents {
    init(recipient: String, subject: String, body: String) {
        self.init()
        self.recipient = recipient
        self.subject = subject
        self.body = body
    }
}
