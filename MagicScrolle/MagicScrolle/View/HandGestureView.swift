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
    // MARK: - 画面遷移
    @State private var toSecondView = false
    @State private var selection: Int?
    
    // 指定の位置にジャンプするためのプロパティ
    @State private var jumpTo = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // カメラ映像を表示
                CameraView(camera: handGestureViewModel)
                    .ignoresSafeArea(.all)
                    .onAppear {
                        handGestureViewModel.start()
                    }
                    .onDisappear {
                        handGestureViewModel.stop()
                    }
                
                NavigationStack {
                    ScrollViewReader { scrollProxy in // SctollViewProxyインスタンスを取得
                        ScrollView {
                            VStack {
                                ForEach(0..<100) {
                                    Text("\($0) 番のレシピ")
                                        .font(.largeTitle)
                                        .frame(width: 400, height: 200)
                                        .background($0 == jumpTo ? Color.cyan.opacity(0.8) : Color.cyan.opacity(0.4))
                                        .cornerRadius(15)
                                        .id($0)
                                }
                            }
                        }
                        .onAppear() {
                            // 1秒ごとに実行
                            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) {_ in
                                withAnimation {
                                    // ジェスチャーによって操作jumpToを更新
                                    jumpTo += handGestureViewModel.controlScroll(jumpTo: jumpTo, gesture: handGestureViewModel.currentGesture)
                                    
                                    scrollProxy.scrollTo(jumpTo)
                                    
                                    // OKの時画面遷移
                                    if handGestureViewModel.currentGesture == .ok {
                                        selection = jumpTo
                                        toSecondView = true
                                    }
                                    
                                    print(jumpTo)
                                    print(handGestureViewModel.currentGesture.rawValue)
                                }
                            }
                        }
                    }
                    .navigationDestination(isPresented: $toSecondView, destination: {
                        Text("レシピ画面")
                    })
                    .navigationTitle("MagicScroll \(handGestureViewModel.currentGesture.rawValue)")
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
