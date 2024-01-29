#if canImport(MessageUI)
import Blocks
import MessageUI

extension MFMailComposeViewController {
    // MARK: Configure

    func configure(with mailtoComponents: MailtoComponents) {
        if let recipient = mailtoComponents.recipient {
            setToRecipients([recipient])
        }

        if let subject = mailtoComponents.subject {
            setSubject(subject)
        }

        if let body = mailtoComponents.body {
            setMessageBody(body, isHTML: false)
        }
    }
}
#endif
