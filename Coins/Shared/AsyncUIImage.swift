//
//  AsyncUIImage.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import SwiftUI

final class AsyncUIImageViewModel: ObservableObject {
    @Published var imageURL: URL?

    init(imageURL: URL? = nil) {
        self.imageURL = imageURL
    }
}

struct AsyncUIImage: View {
    @ObservedObject var viewModel = AsyncUIImageViewModel()

    var body: some View {
        AsyncImage(url: viewModel.imageURL)
            .aspectRatio(contentMode: .fit)
            .ignoresSafeArea()
    }
}
