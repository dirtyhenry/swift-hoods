import ComposableArchitecture
import SwiftUI
import UniformTypeIdentifiers

struct ImagePickerView: UIViewControllerRepresentable {
    let store: StoreOf<ImagePickerFeature>

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.mediaTypes = [UTType.image.identifier]
        return picker
    }

    func updateUIViewController(_: UIImagePickerController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(store: store)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let store: StoreOf<ImagePickerFeature>

        init(store: StoreOf<ImagePickerFeature>) {
            self.store = store
        }

        func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            guard let image = info[.originalImage] as? UIImage else {
                return
            }
            print("imagePickerControllerDidFinishPickingMediaWithInfo: \(Thread.isMainThread)")
            store.send(.usePhotoButtonTapped(image))
        }

        func imagePickerControllerDidCancel(_: UIImagePickerController) {
            print("imagePickerControllerDidCancel: \(Thread.isMainThread)")
            store.send(.cancelButtonTapped)
        }
    }
}

struct ImagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerView(
            store: Store(initialState: ImagePickerFeature.State()) {
                ImagePickerFeature()
            }
        )
    }
}
