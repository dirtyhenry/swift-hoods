import Blocks
import ComposableArchitecture
import SwiftUI
import UniformTypeIdentifiers

struct ImagePickerDemoView: View {
    @Bindable var store: StoreOf<ImagePickerDemoFeature>

    init(store: StoreOf<ImagePickerDemoFeature>) {
        self.store = store
    }

    var body: some View {
        NavigationStack {
            if store.latestPhoto == nil {
                VStack(spacing: 32) {
                    Button("Take Photo") {
                        store.send(.takePhotoButtonTapped)
                    }

                    switch store.status {
                    case .notDetermined:
                        Text("Access not determined")
                    case .authorized:
                        Text("Access authorized")
                    case .denied:
                        Text("Access denied")
                    case .restricted:
                        Text("Access restricted")
                    @unknown default:
                        Text("Unknown status")
                    }
                }
            } else {
                VStack {
                    Image(uiImage: store.latestPhoto!)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 200)
                    Button("Retake Photo") {
                        store.send(.takePhotoButtonTapped)
                    }
                }
            }
        }
        .sheet(item: $store.scope(state: \.takePhoto, action: \.usePhoto)) { takePhotoStore in
            NavigationStack {
                ImagePickerView(store: takePhotoStore)
            }
        }
    }
}

#Preview {
    ImagePickerDemoView(store: Store(initialState: ImagePickerDemoFeature.State()) {
        ImagePickerDemoFeature()
    })
}
