//
//  SplashScreen.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/12/25.
//

import SwiftUI

struct SplashView: View {
  var body: some View {
    ZStack {
      Color.white.ignoresSafeArea()

      VStack {
        Spacer()

        Image("sotwLogoTransparent")
          .resizable()
          .scaledToFit()
          .frame(width: 160, height: 160)

        Spacer()
      }
    }
  }
}
