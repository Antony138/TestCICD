//
//  DetailInfoView.swift
//  EVP4
//
//  Created by Woramet Muangsiri on 2022/08/25.
//

import SwiftUI
import Combine
import heresdk

struct DetailInfoView: View {
    enum DetailInfoState: Equatable {
        case hidden
        case show(_: Place)
        case showRouteInfo(_: Place, _: Route)
        case showManeuverInfo(_: Place, _: Route)
    }

    var state: DetailInfoState
    var onTapDirection: ((Place) -> Void)?
    var onTapViewRoute: ((Route) -> Void)?
    var onTapSendToMeter: ((Route) -> Void)?
    var onTapBack: ((Place) -> Void)?
    var onTapFav: ((Bool) -> Void)?
    // TODO: move to "show(_: Place)" later
    @State var isFav = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            switch state {
            case .show(let place):
                showPlaceInfo(of: place)

            case .showRouteInfo(let place, let route):
                showRouteInfo(of: place, by: route)

            case .showManeuverInfo(let place, let route):
                showManeuverInfo(of: place, by: route)

            default:
                Spacer(minLength: 0)
            }
        }
        .padding()
        .background(Color.white)
    }
}

// MARK: - View Builders
private extension DetailInfoView {
    @ViewBuilder
    func showPlaceInfo(of place: Place) -> some View {
        Text("\(place.title)")
            .font(.system(size: 28))
        Text("\(place.address.addressText)")

        HStack {
            Text("N/A km ∙")
                .foregroundColor(.gray)
            Text("N/A minutes from current location")
                .font(.body.weight(.bold))
        }
        .padding(.bottom)

        HStack {
            blueButton(text: "Direction") { onTapDirection?(place) }

            Spacer(minLength: 18.0)

            Button {
                isFav.toggle()
                onTapFav?(isFav)
            } label: {
                isFav ? Image("fav") : Image("unfav")
            }
        }
    }

    @ViewBuilder
    func showRouteInfo(of place: Place, by route: heresdk.Route) -> some View {
        addressView(place: place)

        ETAView(duration: route.duration,
                lengthInMeters: Double(route.lengthInMeters))
            .padding(.bottom)

        HStack {
            whiteButton(text: "View Route") { onTapViewRoute?(route) }
            blueButton(text: "Send to Meter") { onTapSendToMeter?(route) }
        }
    }

    @ViewBuilder
    func showManeuverInfo(of place: Place, by route: heresdk.Route) -> some View {
        addressView(place: place)

        ETAView(duration: route.duration,
                lengthInMeters: Double(route.lengthInMeters))
            .padding(.bottom)

        HStack {
            whiteButton(text: "Map") { onTapDirection?(place) }
            blueButton(text: "Send to Meter") { onTapSendToMeter?(route) }
        }

        if let maneuvers = route.sections.first?.maneuvers {
            List(maneuvers, id: \.hashValue) { maneuver in
                Label(maneuver.text, systemImage: getManeuverSymbolName(action: maneuver.action))
            }.listStyle(.plain)
        }
    }

    private func getManeuverSymbolName(action: ManeuverAction) -> String {
        switch action {
        case .depart:
            return "dot.square"
        case .leftExit, .leftFork, .leftTurn, .leftUTurn, .leftRoundaboutEnter, .leftRamp, .sharpLeftTurn:
            return "arrow.turn.up.left"
        case .rightExit, .rightFork, .rightTurn, .rightUTurn, .rightRoundaboutEnter, .rightRamp, .sharpRightTurn:
            return "arrow.turn.up.right"
        case .continueOn:
            return "arrow.up"
        case .arrive:
            return "mappin.circle.fill"
        default:
            return "questionmark"
        }
    }

    @ViewBuilder
    private func addressView(place: Place) -> some View {
        HStack {
            Text("\(place.title)")
                .font(.system(size: 24))
                .bold()
                .lineLimit(2)
            Spacer()
            Button {
                onTapBack?(place)
            } label: {
                Image("cancel")
                .renderingMode(.original)
            }
        }

        Text("\(place.address.addressText)")
            .font(.system(size: 12))
            .foregroundColor(.gray)
        Divider()
    }

    @ViewBuilder
    private func ETAView(duration: Double, lengthInMeters: Double) -> some View {
        HStack {
            Text("\(String(format: "%.1f", duration / 60)) min")
                .font(.system(size: 24))
            Text("(\(String(format: "%.1f", lengthInMeters / 1000)) km)")
                .font(.system(size: 24))
                .foregroundColor(.gray)
        }
    }

    @ViewBuilder
    private func blueButton(text: String, onTap: @escaping () -> Void) -> some View {
        Button {
            onTap()
        } label: {
            Text(text)
                .font(.title3.weight(.bold))
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
        }
        .padding()
        .background(.blue)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func whiteButton(text: String, onTap: @escaping () -> Void) -> some View {
        Button {
            onTap()
        } label: {
            Text(text)
                .font(.title3.weight(.bold))
                .frame(maxWidth: .infinity)
                .foregroundColor(.blue)
        }
        .padding()
        .background(.white)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.blue, lineWidth: 1))
    }

}

// MARK: - Preview
struct DetailInfoView_Previews: PreviewProvider {
    // swiftlint:disable all
    static let dummyplace = "v0-eNqdj82qwjAQhV+lzDqVxvTP7IpmoaBcbr2LuyohHWq0JqFNwSK+uxH0BZzVzDl8Zzh3kErhOAK/Qy89cJYtclawVfIZRqA3HXDKVouCLsvyY9AHAdm2Q6Abj7fAAo1pGu2xmwYb0Vid7BXJ+44vE4mO9jIHJ2NxkuSMRDvppAECyk7GD3OjbIshZvdzCKJuw3rCAfltpNxZbfz7HU+ztMiXtOTrTm1Fve6K/z8nKiGrs0gC6nqpsPGze6VVm82vqOuXbEfttTVflvXa9/h1y8cTTkpojw=="

    static var dummy = DetailInfoView.DetailInfoState.show(try! Place.deserialize(serializedPlace: dummyplace))

    static var previews: some View {
        DetailInfoView(state: dummy)
    }
}
