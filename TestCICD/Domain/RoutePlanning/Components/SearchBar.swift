//
//  SearchBar.swift
//  EVP4
//
//  Created by Antony Wong on 2022/08/18.
//

import SwiftUI

struct SearchBar: UIViewRepresentable {
    @ObservedObject var viewState: SearchBarViewState

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UISearchBar {
        let uiSearchBar = UISearchBar()
        uiSearchBar.barStyle = UIBarStyle.black
        uiSearchBar.searchTextField.textColor = .black
        uiSearchBar.backgroundImage = UIImage()
        uiSearchBar.delegate = context.coordinator
        return uiSearchBar
    }

    func updateUIView(_ uiSearchBar: UISearchBar, context: Context) {
        guard viewState.shouldUpdateView else {
            print("[SearchBar] - Skip updating search bar `\(viewState.isEditing)` `\(viewState.searchText)`")
            viewState.shouldUpdateView = true
            return
        }
        print("[SearchBar] - Update search bar `\(viewState.isEditing)` `\(viewState.searchText)`")
        if uiSearchBar.searchTextField.isEditing != viewState.isEditing {
            if viewState.isEditing {
                uiSearchBar.becomeFirstResponder()
            } else {
                uiSearchBar.endEditing(true)
            }
        }
        uiSearchBar.text = viewState.searchText
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        let searchBar: SearchBar

        init(_ searchBar: SearchBar) {
            self.searchBar = searchBar
        }

        func searchBarTextDidBeginEditing(_ uiSearchBar: UISearchBar) {
            print("[SearchBar] - searchBarTextDidBeginEditing")
            searchBar.viewState.shouldUpdateView = false
            searchBar.viewState.isEditing = true
        }

        func searchBarTextDidEndEditing(_ uiSearchBar: UISearchBar) {
            print("[SearchBar] - searchBarTextDidEndEditing")
            searchBar.viewState.shouldUpdateView = false
            searchBar.viewState.isEditing = false
        }

        func searchBar(_ uiSearchBar: UISearchBar, textDidChange searchText: String) {
            print("[SearchBar] - textDidChange `\(searchText)`")
            searchBar.viewState.shouldUpdateView = false
            searchBar.viewState.searchText = searchText
            searchBar.viewState.isEmpty = searchText.isEmpty
        }
    }

}
