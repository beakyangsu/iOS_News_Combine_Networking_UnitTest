//
//  ContentView.swift
//  News
//
//  Created by yangsu.baek on 2024/03/02.
//

import SwiftUI

struct ContentView: View {
    //StateObject 메모리를 유지함
    @StateObject var viewModel = NewsViewModelImpl(service: NewsServiceImpl())

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .failed(let error):
                //error일때 데이터 가져오는거 리트라이
                ErrorView(error: error, handler: viewModel.getArticles)
            case .success:
                NavigationStack {
                    List(viewModel.articles) { article  in
                        ArticleView(article: article)
                    }.navigationTitle(Text("News"))
                }
            }

        }.onAppear(perform: viewModel.getArticles) //데이터 가져오기
    }
}

#Preview {
    ContentView()
}
