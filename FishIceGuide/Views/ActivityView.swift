import SwiftUI

struct ActivityView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("Fish")
                        .font(.headline)
                        .foregroundColor(.lightCyan)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 16)
                    Text("Morning")
                        .font(.headline)
                        .foregroundColor(.lightCyan)
                        .frame(maxWidth: .infinity)
                    Text("Day")
                        .font(.headline)
                        .foregroundColor(.lightCyan)
                        .frame(maxWidth: .infinity)
                    Text("Evening")
                        .font(.headline)
                        .foregroundColor(.lightCyan)
                        .frame(maxWidth: .infinity)
                        .padding(.trailing, 16)
                }
                .padding(.vertical, 12)
                .background(Color.frostedBlue.opacity(0.9))
                
                ForEach(activities) { activity in
                    HStack(spacing: 0) {
                        Text(activity.fishName)
                            .foregroundColor(.iceWhiteGlow)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 16)
                        Circle()
                            .fill(colorForActivityLevel(activity.morning))
                            .frame(width: 24, height: 24)
                            .frame(maxWidth: .infinity)
                        Circle()
                            .fill(colorForActivityLevel(activity.day))
                            .frame(width: 24, height: 24)
                            .frame(maxWidth: .infinity)
                        Circle()
                            .fill(colorForActivityLevel(activity.evening))
                            .frame(width: 24, height: 24)
                            .frame(maxWidth: .infinity)
                            .padding(.trailing, 16)
                    }
                    .padding(.vertical, 12)
                    .background(Color.frostedBlue.opacity(0.6))
                    
                    // Divider().background(.midnightIce)
                }
            }
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.3), radius: 8)
            .padding()
        }
        .background(Color.midnightIce.ignoresSafeArea())
        .navigationTitle("Activity")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ActivityView()
}
