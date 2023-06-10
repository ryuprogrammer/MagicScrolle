//
//  ContentView.swift
//  MagicScrolle
//
//  Created by トム・クルーズ on 2023/06/08.
//

import SwiftUI

struct ListView: View {
    // 指定の位置にジャンプするためのプロパティ
    @State private var jumpTo = 0
    
    
    var body: some View {
        ScrollViewReader { scrollProxy in // SctollViewProxyインスタンスを取得
            VStack {
                ScrollView {
                    VStack {
                        ForEach(0..<100) {
                            Text("\($0) 行目")
                                .font(.largeTitle)
                                .frame(width: 400, height: 200)
                                .background($0 == jumpTo ? Color.cyan.opacity(0.8) : Color.cyan.opacity(0.4))
                                .cornerRadius(15)
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
