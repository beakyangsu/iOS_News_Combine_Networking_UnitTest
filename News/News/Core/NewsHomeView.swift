//
//  NewsHomeView.swift
//  Test2
//
//  Created by yangsu.baek on 2024/02/29.
//

import SwiftUI

struct NewsHomeView: View {

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
            case .success(let articles) :
                NavigationStack {
                    List(articles) { article  in
                        ArticleView(article: article)
                    }.navigationTitle(Text("News"))
                }
            }

        }.onAppear(perform: viewModel.getArticles) //데이터 가져오기
    }
}

#Preview {
    NewsHomeView()
}
