//
//  HandGestureView.swift
//  MagicScrolle
//
//  Created by トム・クルーズ on 2023/06/08.
//

import SwiftUI
import AVFoundation

struct HandGestureView: View {
    // MARK: - インスタンス生成
    // HandGestureViewModelのインスタンス生成
    @StateObject private var handGestureViewModel = HandGestureViewModel()
    // MARK: - ゲーム関連
    // ジャンケンのカウントダウン用プロパティ
    @State private var jankenCount: Int = 0
    // ゲームの勝敗を格納
    @State private var finalResult: String?
    // 勝率を格納
    @State private var showWinRate: Int?
    // １回のジャンケンの終了判定
    @State private var isEndJanken: Bool = false
    // MARK: - 画面遷移
    // 環境変数を利用して画面を戻る
    @Environment(\.dismiss) private var dissmiss
    // ResultViewの表示有無
    @State private var isShowResultView: Bool = false
    // MARK: - 画面、背景
    // Viewの背景色のプロパティ（ジャンケンの手が有効の時青、無効の時赤に変化）
    @State private var backgroundColor = Color.red
    // ユーザーのデバイスの画面の大きさ
    private let userScreenWidth: Double = UIScreen.main.bounds.size.width
    private let userScreenHeight: Double = UIScreen.main.bounds.size.height
    
    // 指定の位置にジャンプするためのプロパティ
    @State private var jumpTo = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CameraView(camera: handGestureViewModel)
                    .ignoresSafeArea(.all)
                    .onAppear {
                        handGestureViewModel.start()
                    }
                    .onDisappear {
                        handGestureViewModel.stop()
                    }
                
                ScrollViewReader { scrollProxy in // SctollViewProxyインスタンスを取得
                    VStack {
                        ScrollView {
                            VStack {
                                ForEach(0..<100) {
                                    Text("\($0) 行目")
                                        .font(.largeTitle)
                                        .id($0)
                                }
                            }
                        }
                        
                        // 行を移動する
                        Button {
                            withAnimation {
                                jumpTo += 1
                                scrollProxy.scrollTo(jumpTo)
                                print(scrollProxy)
                            }
                        } label: {
                            Text("+")
                                .font(.largeTitle)
                        }
                    }
                    .onAppear() {
                        // 1秒ごとに実行
                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) {_ in
                            withAnimation {
                                // ジェスチャーによって操作jumpToを更新
                                jumpTo += handGestureViewModel.controlScroll(gesture: handGestureViewModel.currentGesture)
                                
                                scrollProxy.scrollTo(jumpTo)
                                
                                print(handGestureViewModel.currentGesture.rawValue)
                            }
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
