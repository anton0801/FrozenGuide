import SwiftUI

struct UnavailableView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("main_app_inet_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .ignoresSafeArea()
            }
        }
        .ignoresSafeArea()
    }
}
