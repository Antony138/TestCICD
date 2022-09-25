//
//  SearchBarViewState.swift
//  EVP4
//
//  Created by Stone Zhang on 8/26/22.
//

import Foundation

class SearchBarViewState: ObservableObject {
    @Published var isEditing: Bool = false
    @Published var searchText: String = ""
    @Published var isEmpty: Bool = true
    // Avoid update loop
    var shouldUpdateView: Bool = true
}
