//
//  NewsView.swift
//  Test2
//
//  Created by yangsu.baek on 2024/02/29.
//

import SwiftUI
import URLImage

struct ArticleView: View {

    let article: Article

    var body: some View {
        HStack {
            if let imgUrl = article.image,
               let url = URL(string: imgUrl) {
                URLImage(url) {
                    // This view is displayed before download starts
                    EmptyView()
                } inProgress: { progress in
                    // Display progress
                    Text("Loading...")
                } failure: { error, retry in
                    // Display error and retry button
                    PlaceholderImageView()
                } content: { image in
                    // Downloaded image
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)

                }
                .frame(width: 100, height: 100)
                .cornerRadius(10)
            } else {
                PlaceholderImageView()
            }

            VStack(alignment: .leading) {
                Text(article.title ?? "")
                    .foregroundStyle(.black)
                    .font(.system(size: 18, weight: .semibold))
                Text(article.source ?? "")
                    .foregroundStyle(.gray)
                    .font(.footnote)
            }
        }
    }
}

struct PlaceholderImageView : View {
    var body: some View {
        Image(systemName: "photo.fill")
             .foregroundStyle(.white)
             .background(Color.gray)
             .frame(width: 100, height: 100)
    }
}

#Preview {
    ArticleView(article: Article.dummyData)
        .previewLayout(.sizeThatFits)
}
