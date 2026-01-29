import SwiftUI

struct BaitsListView: View {
    let artificialBaits = baits.filter { $0.type == "Artificial" }
    let naturalBaits = baits.filter { $0.type == "Natural" }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Artificial").font(.headline).foregroundColor(.lightCyan)) {
                    ForEach(artificialBaits) { bait in
                        NavigationLink(destination: BaitDetailView(bait: bait)) {
                            Text(bait.name)
                                .foregroundColor(.iceWhiteGlow)
                                .padding(.vertical, 8)
                        }
                    }
                }
                .listRowBackground(Color.frostedBlue.opacity(0.8))
                
                Section(header: Text("Natural").font(.headline).foregroundColor(.lightCyan)) {
                    ForEach(naturalBaits) { bait in
                        NavigationLink(destination: BaitDetailView(bait: bait)) {
                            Text(bait.name)
                                .foregroundColor(.iceWhiteGlow)
                                .padding(.vertical, 8)
                        }
                    }
                }
                .listRowBackground(Color.frostedBlue.opacity(0.8))
            }
            .listStyle(InsetGroupedListStyle())
            .background(Color.midnightIce.ignoresSafeArea())
            .navigationTitle("Baits")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    BaitsListView()
}
