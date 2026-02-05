import SwiftUI

struct FrozenAlertView: View {
    @ObservedObject var controller: WorkflowController
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image("main_notification_app_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: g.size.width, height: g.size.height)
                    .ignoresSafeArea()
                    .opacity(0.9)
                
                if g.size.width < g.size.height {
                    VStack(spacing: 12) {
                        Spacer()
                        
                        Text("ALLOW NOTIFICATIONS ABOUT\nBONUSES AND PROMOS")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .multilineTextAlignment(.center)
                        
                        Text("STAY TUNED WITH BEST OFFERS FROM\nOUR CASINO")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 12)
                            .multilineTextAlignment(.center)
                        
                        buttons
                    }
                    .padding(.bottom, 24)
                } else {
                    HStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: 12) {
                            Spacer()
                            
                            Text("ALLOW NOTIFICATIONS ABOUT\nBONUSES AND PROMOS")
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .multilineTextAlignment(.leading)
                            
                            Text("STAY TUNED WITH BEST OFFERS FROM\nOUR CASINO")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 12)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        VStack {
                            Spacer()
                            buttons
                        }
                        Spacer()
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }
    
    private var buttons: some View {
        VStack(spacing: 12) {
            Button {
                controller.allowAlerts()
            } label: {
                Text("YES, I WANT BONUSES!")
                    .font(.system(size: 19, weight: .black))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(
                        Color(hex: "FFE54F")
                    )
                    .cornerRadius(52)
            }
            
            Button {
                controller.skipAlerts()
            } label: {
                Text("SKIP")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(
                        Color.white.opacity(0.1)
                    )
                    .cornerRadius(52)
            }
        }
        .padding(.horizontal, 60)
    }
    
}

#Preview {
    FrozenAlertView(controller: WorkflowController())
}
