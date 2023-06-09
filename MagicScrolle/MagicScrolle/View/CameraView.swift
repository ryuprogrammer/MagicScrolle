//
//  CameraView.swift
//  MagicScrolle
//
//  Created by トム・クルーズ on 2023/06/08.
//

import SwiftUI

// カメラのプレビューレイヤーを設定
struct CameraView: UIViewRepresentable {
    @ObservedObject var camera: HandGestureViewModel

    func makeUIView(context: Context) -> UIView {
        let previewView = UIView(frame: UIScreen.main.bounds)
        camera.addPreviewLayer(to: previewView)
        context.coordinator.camera = camera // CoordinatorにCameraModelを渡す
        return previewView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // ここでは何もしない。
    }

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(camera: camera)
        camera.handGestureDetector.delegate = coordinator // Coodinatorをデリゲートとして設定
        return coordinator
    }

    class Coordinator: NSObject, HandGestureDetectorDelegate {
        @ObservedObject var camera: HandGestureViewModel // CameraModelを監視可能にするために@ObservedObjectを追加

        init(camera: HandGestureViewModel) {
            self.camera = camera
        }

        // HandGestureを判定してcurrentGesture（画面に表示するプロパティ）に格納
        func handGestureDetector(_ handGestureDetector: HandGestureDetector, didRecognize gesture: HandGestureDetector.HandGesture) {
            DispatchQueue.main.async {
                // @Publishedプロパティに値を設定
                self.camera.currentGesture = gesture
            }
        }
    }
}

