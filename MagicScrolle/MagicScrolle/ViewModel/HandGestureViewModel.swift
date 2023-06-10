//
//  HandGestureViewModel.swift
//  MagicScrolle
//
//  Created by トム・クルーズ on 2023/06/08.
//

import SwiftUI
import AVFoundation
import Vision

class HandGestureViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate, HandGestureDetectorDelegate {

    let handGestureDetector: HandGestureDetector
    // AVCaptureSessionのインスタンス生成
    private let session = AVCaptureSession()
    private var delegate: HandGestureDetectorDelegate?

    @Published var jankenCallTimer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    @Published var currentGesture: HandGestureDetector.HandGesture = .unknown
    // 敵のHPを格納
    @Published var enemyHealthPoint: Double = 1000
    // 敵のHPの背景色
    @Published var enemyHealthColor: [Color] = [.mint, .blue, .blue]
    // ユーザーのHPを格納
    @Published var userHealthPoint: Double = 1000
    // ユーザーのHPの背景色
    @Published var userHealthColor: [Color] = [.mint, .blue, .blue]
    // 逆転後の勝率
    @Published var newWinRate: Int?
    // 敵のジャンケン結果を格納するプロパティ
    @Published var enemyHandGesture: HandGestureDetector.HandGesture = .unknown
    // jankenTextをPublish
    @Published var jankenText = ""
    // ダメージ
    private let damage: Double = 180

    override init() {
        handGestureDetector = HandGestureDetector()
        super.init()
        handGestureDetector.delegate = self
        do {
            session.sessionPreset = .photo
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            if let device = device {
                let input = try AVCaptureDeviceInput(device: device)
                session.addInput(input)
                let output = AVCaptureVideoDataOutput()
                output.setSampleBufferDelegate(self, queue: .main)
                session.addOutput(output)
                let view = UIView(frame: UIScreen.main.bounds)
                addPreviewLayer(to: view)
                session.commitConfiguration()
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - メソッド
    // スクロールを制御するメソッド
    func controlScroll(gesture: HandGestureDetector.HandGesture) -> Int {
        var scrollNumber = 0
        
        switch gesture {
        case .up: scrollNumber = -1
        case .down: scrollNumber = 1
        case .ok: scrollNumber = 0
        case .unknown: scrollNumber = 0
        }
        
        return scrollNumber
    }

    // handGestureDetector
    func handGestureDetector(_ handGestureDetector: HandGestureDetector, didRecognize gesture: HandGestureDetector.HandGesture) {
        // 何もしない
    }

    // キャプチャを停止するメソッド
    func stop() {
        if session.isRunning {
            session.stopRunning()
            jankenCallTimer.upstream.connect().cancel()
        }
    }

    // キャプチャを再開するメソッド
    func start() {
        if session.isRunning == false {
            // 非同期処理をバックグラウンドスレッドで実行
            DispatchQueue.global().async {
                self.session.startRunning()
            }
            jankenCallTimer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
        }
    }

    // キャプチャセッションから得られたカメラ映像を表示するためのレイヤーを追加するメソッド
    func addPreviewLayer(to view: UIView) {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.frame = UIScreen.main.bounds
        layer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(layer) // UIViewにAVCaptureVideoPreviewLayerを追加
    }

    // AVCaptureVideoDataOutputから取得した動画フレームからてのジェスチャーを検出するメソッド
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let request = try? handGestureDetector.createDetectionRequest(pixelBuffer: pixelBuffer)

        guard let observations = request?.results as? [VNRecognizedPointsObservation] else {
            return
        }

        // 実際にジェスチャーからHandGestureを判別する
        handGestureDetector.processObservations(observations)
    }
}
