import ComposableArchitecture
import MessageUI
import SwiftUI

/// A basic SwiftUI wrapper for UIKit's `MFMailComposeViewController`.
struct MailerView: UIViewControllerRepresentable {
    let viewStore: ViewStoreOf<MailerFeature>

    init(store: StoreOf<MailerFeature>) {
        viewStore = ViewStore(store, observe: { $0 })
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.delegate = context.coordinator
        composer.configure(with: viewStore.mailtoComponents)
        return composer
    }

    func updateUIViewController(_: MFMailComposeViewController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(viewStore: viewStore)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate {
        let viewStore: ViewStoreOf<MailerFeature>

        init(viewStore: ViewStoreOf<MailerFeature>) {
            self.viewStore = viewStore
        }

        func mailComposeController(
            _: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error _: Error?
        ) {
            viewStore.send(.interactionCompleted(result))
        }
    }
}
