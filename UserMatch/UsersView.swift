//
//  ContentView.swift
//  UserMatch
//
//  Created by Praveen on 24/01/25.
//

import SwiftUI
import CoreData

struct UsersView: View {
    @ObservedObject var viewModel = UsersViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.users) { user in
                Card(user: user) { cardAction in
                    switch cardAction {
                    case .AcceptProfile:
                        viewModel.acceptProfile(userID: user.id)
                    case .DeclineProfile:
                        viewModel.declineProfile(userID: user.id)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            }
            .listStyle(.plain)
            .alert(isPresented: $viewModel.showError) {
                Alert(title: Text(""), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
            }
//            ScrollView {
//                VStack {
//                    ForEach(viewModel.users) { user in
//                        
//                    }
//                }
//            }
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
    var user: UserDataModel
    var action: ((CardAction) -> ())?
    
    init(user: UserDataModel, action: ((CardAction) -> ())?) {
        self.user = user
        self.action = action
    }
    
    var body: some View {
        VStack {
            Text(user.name)
            if let preferenceStatus = user.preferenceStatus {
                Text(preferenceStatus == .Accepted ? "Accepted" : "Declined")
            } else {
                Button {
                    action?(.AcceptProfile)
                } label: {
                    Text("accept")
                }
                .buttonStyle(.plain)
                Button(action: {
                    action?(.DeclineProfile)
                }, label: {
                    Text("Decline")
                })
                .buttonStyle(.plain)
            }
        }
    }
    
    
}

#Preview {
    UsersView()
}
