import MessageUI

extension MFMailComposeViewController {
    // MARK: Configure

    func configure(with mailContent: MailContent) {
        setToRecipients([mailContent.recipient])
        setSubject(mailContent.subject)
        setMessageBody(mailContent.body, isHTML: false)
    }
}
