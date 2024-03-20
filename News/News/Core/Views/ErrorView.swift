//
//  ErrorView.swift
//  Test2
//
//  Created by yangsu.baek on 2024/02/29.
//

import SwiftUI

struct ErrorView: View {
    typealias ErrorViewActionHandler = () -> Void //클로져

    let error: Error
    let handler : ErrorViewActionHandler

    internal init(error: Error, handler: @escaping ErrorViewActionHandler) {
        self.error = error
        self.handler = handler
    }

    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.icloud.fill")
                 .foregroundStyle(.gray)
                 .font(.system(size: 50, weight: .heavy))
                 .padding(.bottom, 4)
            Text("Oooopss")
                .foregroundStyle(.black)
                .font(.system(size: 30, weight: .heavy))
                .multilineTextAlignment(.center)
            Text(error.localizedDescription)
                .foregroundStyle(.gray)
                .font(.system(size: 15, weight: .heavy))
                .multilineTextAlignment(.center)
                .padding(.bottom, 4)
            Button {
                handler()
            } label: {
                 Text("Retry")
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 30)
            .background(Color.blue)
            .foregroundStyle(.white)
            .font(.system(size: 15, weight: .heavy))
            .clipShape(RoundedRectangle(cornerRadius: 10))

        }
    }
}

#Preview {
    ErrorView(error: APIError.decodingError) { /*ErrorViewActionHandler*/ }
}
