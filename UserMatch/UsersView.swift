//
//  ContentView.swift
//  UserMatch
//
//  Created by Praveen on 24/01/25.
//

import SwiftUI
import CoreData
import SDWebImageSwiftUI

struct UsersView: View {
    @ObservedObject var viewModel = UsersViewModel()

    var body: some View {
        NavigationView {
            switch viewModel.screenState {
            case .Loading:
                ProgressView()
            case .Data:
                List {
                    ForEach(viewModel.users, id: \.id) { user in
                        Card(user: user) { cardAction in
                            switch cardAction {
                            case .AcceptProfile:
                                viewModel.acceptProfile(userID: user.id)
                            case .DeclineProfile:
                                viewModel.declineProfile(userID: user.id)
                            }
                        }
                        .padding([.vertical], 30)
                        .padding([.horizontal], 30)
                        
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                    }
                    HStack(alignment: .center, spacing: 10) {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .onAppear {
                        Task {
                            try? await Task.sleep(nanoseconds: 500_000_000)
                            await viewModel.fetchNextPage()
                        }
                    }
                }
                .listStyle(.plain)
                .alert(viewModel.errorMessage, isPresented: $viewModel.showError, actions: {
                })
            }
        }
        .task {
            await viewModel.getMatchingUsers()
        }
    }
}

enum CardAction {
    case AcceptProfile
    case DeclineProfile
}

struct Card: View {
    var imageSize: CGFloat = 25
    var user: UserDataModel
    var action: ((CardAction) -> ())?
    
    init(user: UserDataModel, action: ((CardAction) -> ())?) {
        self.user = user
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 10) {
            if let imageUrl = user.avatarUrl {
                WebImage(url: URL(string: imageUrl)) { image in
                        image.resizable()
                    } placeholder: {
                            Rectangle().foregroundColor(.gray)
                    }
                .frame(width: 200, height: 200)
            }
            Text(user.name)
                .font(.title2)
                .foregroundStyle(Color.teal)
                .bold()
            Text(user.location ?? "")
                .font(.subheadline)
                .foregroundStyle(Color.gray)
                .padding([.horizontal], 20)
                .padding([.bottom], 20)
                .multilineTextAlignment(.center)
            if let preferenceStatus = user.preferenceStatus {
                Text(preferenceStatus == .Accepted ? "Accepted" : "Declined")
                    .foregroundStyle(Color.white)
                    .font(.title3)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(preferenceStatus == .Accepted ? Color.teal.opacity(0.5) : Color.orange.opacity(0.5))
            } else {
                HStack(spacing: 60) {
                    Button {
                        action?(.AcceptProfile)
                    } label: {
                        Image(.tick).resizable()
                            .renderingMode(.template)
                            .foregroundColor(.gray)
                            .frame(width: imageSize, height: imageSize)
                    }
                    .buttonStyle(.plain)
                    .padding([.horizontal], 15)
                    .padding([.vertical], 15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 55/2)
                            .stroke(.teal.opacity(0.5), lineWidth: 2)
                    )
                    Button(action: {
                        action?(.DeclineProfile)
                    }, label: {
                        Image(.cross).resizable()
                            .renderingMode(.template)
                            .foregroundColor(.gray)
                            .frame(width: imageSize, height: imageSize)
                    })
                    .buttonStyle(.plain)
                    .padding([.horizontal], 15)
                    .padding([.vertical], 15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 55/2)
                            .stroke(.teal.opacity(0.5), lineWidth: 2)
                    )
                }
            }
        }
        .padding([.top], 20)
        .padding([.bottom], user.preferenceStatus != nil ? 0 : 20)
        .padding([.horizontal], user.preferenceStatus != nil ? 0 : 10)
        .frame(maxWidth: .infinity)
        .cornerRadius(10)
        .background(Color.white.cornerRadius(10).shadow(color: .gray.opacity(0.45),radius: 7))
        
    }
    
    
}

#Preview {
    UsersView()
}
