//
//  NewsApp.swift
//  News
//
//  Created by yangsu.baek on 2024/03/02.
//

import SwiftUI
import URLImage
import URLImageStore

@main
struct NewsApp: App {
    let urlImageService = URLImageService(fileStore: URLImageFileStore(),
                                          inMemoryStore: URLImageInMemoryStore())


    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.urlImageService, urlImageService)
        }
    }
}
