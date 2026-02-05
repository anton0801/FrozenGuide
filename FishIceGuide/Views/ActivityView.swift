import SwiftUI

struct ActivityView: View {
    @EnvironmentObject var activityViewModel: ActivityViewModel
    @EnvironmentObject var fishViewModel: FishViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.midnightIce.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Activity table
                        if !activityViewModel.activitySlots.isEmpty {
                            activityTable
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Fish Activity")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if activityViewModel.activitySlots.isEmpty {
                    activityViewModel.generateActivityTable(from: fishViewModel.fishes)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 40))
                .foregroundColor(.iceCyan)
            
            Text("Daily Activity Patterns")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.iceWhite)
            
            Text("Track when fish are most active")
                .font(.system(size: 14))
                .foregroundColor(.iceWhite.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.iceWhite.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    var activityTable: some View {
        VStack(spacing: 16) {
            ForEach(fishViewModel.fishes) { fish in
                FishActivityRow(
                    fish: fish,
                    timeSlots: activityViewModel.activitySlots
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.iceWhite.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct FishActivityRow: View {
    let fish: Fish
    let timeSlots: [ActivityTimeSlot]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: fish.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(.iceCyan)
                    .frame(width: 30)
                
                Text(fish.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.iceWhite)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                ForEach(timeSlots) { slot in
                    if let activity = slot.fishActivities[fish.id] {
                        ActivityIndicator(level: activity)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.midnightIce.opacity(0.5))
        )
    }
}
