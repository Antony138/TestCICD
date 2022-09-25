//
//  SearchResultView.swift
//  EVP4
//
//  Created by Woramet Muangsiri on 2022/08/19.
//

import SwiftUI
import heresdk

struct SearchResultView: View {
    struct SearchResult: Equatable {
        let title: String
        let places: [Place]
    }

    let result: SearchResult
    let onTapResult: ((Place) -> Void)?

    var body: some View {
        List {
            Section(result.title) {
                ForEach(result.places, id: \.self) { place in
                    SearchResultRow(place: place).onTapGesture {
                        self.onTapResult?(place)
                    }
                }
            }
        }
        .background(Color.white)
        .listStyle(.plain)
    }
}

struct SearchResultRow: View {
    let place: Place
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(place.title)")
                .bold()
            Text("\(place.address.addressText)")
                .font(.caption)
        }
    }
}

struct SearchResultView_Previews: PreviewProvider {
    // swiftlint:disable all
    static let dummyplace = ["v0-eNqdj82qwjAQhV+lzDqVxvTP7IpmoaBcbr2LuyohHWq0JqFNwSK+uxH0BZzVzDl8Zzh3kErhOAK/Qy89cJYtclawVfIZRqA3HXDKVouCLsvyY9AHAdm2Q6Abj7fAAo1pGu2xmwYb0Vid7BXJ+44vE4mO9jIHJ2NxkuSMRDvppAECyk7GD3OjbIshZvdzCKJuw3rCAfltpNxZbfz7HU+ztMiXtOTrTm1Fve6K/z8nKiGrs0gC6nqpsPGze6VVm82vqOuXbEfttTVflvXa9/h1y8cTTkpojw==",
                             "v0-eNqdT8EOgjAU+xXyzpMwEZDdPHDhYIxyJ5O96CJuZHsYF+O/Ow76AfbUtGnTvkAq5dD7nvBJIGBng7zLlbJOJ7sHmhlZcrrq8xzkj6xuM0s6ewuWJa2cpAEGg50NudAPVmGsaQ/7KGoV6RUdiqfnwpNDJI8DaWsEzxbwKi8rvk7LDd/GwDTKAXsK09Jx6o5N0y2q9XrJgHjBKOPKvEjLot7w+ouKwWguIHhep1VWrLOf82ZAmkb8+9r7A4JMW4Q=",
                             "v0-eNqdT8EOgjAU+xXyzpMwEZDdPHDhYIxyJ5O96CJuZHsYF+O/Ow76AfbUtGnTvkAq5dD7nvBJIGBng7zLlbJOJ7sHmhlZcrrq8xzkj6xuM0s6ewuWJa2cpAEGg50NudAPVmGsaQ/7KGoV6RUdiqfnwpNDJI8DaWsEzxbwKi8rvk7LDd/GwDTKAXsK09Jx6o5N0y2q9XrJgHjBKOPKvEjLot7w+ouKwWguIHhep1VWrLOf82ZAmkb8+9r7A4JMW4Q=","v0-eNqdj8FqwzAQRH9F6CwHrxXVsW6m1iGBlhLnkpNRZGGLuJKwZYgI+fcq0PYDMqdlljfD3LFUSi8L5nc8yYA5ZZu3sgKo/rQjeLID5kCrTZnTovj/PAiWfT8nugv6llgMGaCzi24wCDI1um9NUDuayxpldl0JOrlrdAgYZHnOKEEH6aXFBCu32jDHTrlep5jD12cyTZ/OUc+a3xbg3hkbfuv4lpU7oKzg74Pai7Y5mvOHF7WQ9Ukk0k9S6S5E/wyrm+Yo2vZpu8UE4+yLW4MJk3555OMHMn1qCQ=="]

    static var previews: some View {
        SearchResultView(result: SearchResultView.SearchResult(title: "test",
                                                               places: dummyplace.map { try! Place.deserialize(serializedPlace: $0) }),
                         onTapResult: nil)
    }
}
