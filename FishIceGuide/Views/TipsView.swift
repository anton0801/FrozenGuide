import SwiftUI

struct TipsView: View {
    var body: some View {
        NavigationView {
            List {
                ForEach(tipCategories) { category in
                    Section(header: Text(category.name).font(.headline).foregroundColor(.lightCyan)) {
                        ForEach(category.tips, id: \.self) { tip in
                            Text(tip)
                                .foregroundColor(.iceWhiteGlow.opacity(0.9))
                                .padding()
                                .background(Color.frostedBlue.opacity(0.8))
                                .cornerRadius(8)
                                .shadow(color: .black.opacity(0.2), radius: 4)
                        }
                    }
                    .listRowBackground(Color.midnightIce)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .background(Color.midnightIce.ignoresSafeArea())
            .navigationTitle("Tips")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    TipsView()
}
