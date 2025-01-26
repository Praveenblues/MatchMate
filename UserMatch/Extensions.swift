//
//  Extensions.swift
//  UserMatch
//
//  Created by Praveen on 26/01/25.
//

import SwiftUICore

private struct CenterHorizontallyModifier: ViewModifier {

    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            Spacer()
            content
            Spacer()
        }
    }
}

extension View {
    
    func centerHorizontally() -> some View {
        modifier(CenterHorizontallyModifier())
    }
}
