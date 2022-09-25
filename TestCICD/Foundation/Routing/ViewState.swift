//
//  ViewState.swift
//  EVP4
//
//  Created by Stone Zhang on 7/26/22.
//

import Foundation

protocol ViewState {}

protocol ViewStatable {
    var viewState: ViewState { get }
}
