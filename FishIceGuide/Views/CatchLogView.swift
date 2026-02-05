import SwiftUI

struct CatchLogView: View {
    @StateObject private var viewModel = CatchLogViewModel()
    @State private var showingAddCatch = false
    @State private var selectedSegment = 0
    
    let segments = ["All", "Recent", "Best"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.midnightIce.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Statistics Header
                    if let stats = viewModel.statistics {
                        StatisticsHeaderView(stats: stats)
                            .padding()
                    }
                    
                    // Segment Control
                    Picker("Filter", selection: $selectedSegment) {
                        ForEach(0..<segments.count, id: \.self) { index in
                            Text(segments[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Catches List
                    if viewModel.isLoading {
                        LoadingView()
                    } else if filteredCatches.isEmpty {
                        EmptyCatchLogView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredCatches) { `catch` in
                                    CatchCardView(catch: `catch`)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                viewModel.deleteCatch(`catch`)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Catch Log")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCatch = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.iceCyan)
                    }
                }
            }
            .sheet(isPresented: $showingAddCatch) {
                AddCatchView(viewModel: viewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            if viewModel.catches.isEmpty {
                viewModel.loadCatches(for: "currentUser") // Replace with actual user ID
            }
        }
    }
    
    var filteredCatches: [CatchEntry] {
        switch selectedSegment {
        case 1: // Recent (last 7 days)
            let weekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
            return viewModel.catches.filter { $0.date >= weekAgo }
        case 2: // Best (largest)
            return viewModel.catches.sorted { ($0.weight ?? 0) > ($1.weight ?? 0) }
        default:
            return viewModel.catches
        }
    }
}

struct StatisticsHeaderView: View {
    let stats: CatchStatistics
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatBox(
                    value: "\(stats.totalCatches)",
                    label: "Total Catches",
                    icon: "fish.fill",
                    color: .iceCyan
                )
                
                StatBox(
                    value: "\(stats.uniqueSpecies)",
                    label: "Species",
                    icon: "star.fill",
                    color: Color(hex: "F59E0B")
                )
            }
            
            HStack(spacing: 16) {
                StatBox(
                    value: String(format: "%.1f lbs", stats.largestCatch),
                    label: "Largest",
                    icon: "trophy.fill",
                    color: Color(hex: "10B981")
                )
                
                StatBox(
                    value: String(format: "%.1f lbs", stats.averageWeight),
                    label: "Average",
                    icon: "chart.bar.fill",
                    color: Color(hex: "8B5CF6")
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.iceWhite.opacity(0.1), lineWidth: 1)
                )
        )
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appear = true
            }
        }
    }
}

struct StatBox: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.iceWhite)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.iceWhite.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.midnightIce.opacity(0.5))
        )
    }
}

struct CatchCardView: View {
    let `catch`: CatchEntry
    @State private var appear = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(`catch`.fishName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.iceWhite)
                    
                    Text(formatDate(`catch`.date))
                        .font(.system(size: 14))
                        .foregroundColor(.iceWhite.opacity(0.6))
                }
                
                Spacer()
                
                if let weight = `catch`.weight {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(String(format: "%.1f", weight)) lbs")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.iceCyan)
                        
                        if let length = `catch`.length {
                            Text("\(String(format: "%.1f", length))\"")
                                .font(.system(size: 14))
                                .foregroundColor(.iceWhite.opacity(0.6))
                        }
                    }
                }
            }
            
            Divider()
                .background(Color.iceWhite.opacity(0.2))
            
            HStack(spacing: 20) {
                InfoPill(icon: "location.fill", text: `catch`.locationName)
                InfoPill(icon: "thermometer", text: `catch`.weather)
                if let temp = `catch`.temperature {
                    InfoPill(icon: "temperature", text: "\(Int(temp))°F")
                }
            }
            
            if !`catch`.notes.isEmpty {
                Text(`catch`.notes)
                    .font(.system(size: 14))
                    .foregroundColor(.iceWhite.opacity(0.8))
                    .lineLimit(2)
                    .padding(.top, 4)
            }
            
            if !`catch`.photoURLs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(`catch`.photoURLs, id: \.self) { url in
                            AsyncImage(url: URL(string: url)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.frostedBlue
                            }
                            .frame(width: 80, height: 80)
                            .cornerRadius(10)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.iceWhite.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appear = true
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct InfoPill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 12))
        }
        .foregroundColor(.iceCyan)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.iceCyan.opacity(0.15))
        )
    }
}

struct EmptyCatchLogView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "fish.circle")
                .font(.system(size: 80))
                .foregroundColor(.iceCyan.opacity(0.5))
            
            Text("No Catches Yet")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.iceWhite)
            
            Text("Start logging your catches to track your fishing success!")
                .font(.system(size: 16))
                .foregroundColor(.iceWhite.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxHeight: .infinity)
    }
}

// AddCatchView.swift
import SwiftUI
import PhotosUI

struct AddCatchView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CatchLogViewModel
    
    @State private var selectedFish = ""
    @State private var locationName = ""
    @State private var weight = ""
    @State private var length = ""
    @State private var quantity = 1
    @State private var baitUsed = ""
    @State private var notes = ""
    @State private var isReleased = false
    @State private var selectedImages: [UIImage] = []
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.midnightIce.ignoresSafeArea()
                
                if #available(iOS 16.0, *) {
                    form.scrollContentBackground(.hidden)
                } else {
                    form
                }
            }
            .navigationTitle("Log Catch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCatch()
                    }
                    .disabled(selectedFish.isEmpty || locationName.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(images: $selectedImages)
            }
        }
    }
    
    private var form: some View {
        Form {
            Section("Fish Details") {
                TextField("Fish Species", text: $selectedFish)
                TextField("Location", text: $locationName)
                
                HStack {
                    TextField("Weight (lbs)", text: $weight)
                        .keyboardType(.decimalPad)
                    TextField("Length (in)", text: $length)
                        .keyboardType(.decimalPad)
                }
                
                Stepper("Quantity: \(quantity)", value: $quantity, in: 1...100)
            }
            
            Section("Equipment") {
                TextField("Bait/Lure Used", text: $baitUsed)
            }
            
            Section("Notes") {
                TextEditor(text: $notes)
                    .frame(height: 100)
            }
            
            Section {
                Toggle("Released", isOn: $isReleased)
            }
            
            Section("Photos") {
                Button(action: { showingImagePicker = true }) {
                    Label("Add Photos", systemImage: "photo.on.rectangle.angled")
                }
                
                if !selectedImages.isEmpty {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(0..<selectedImages.count, id: \.self) { index in
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func saveCatch() {
        let newCatch = CatchEntry(
            id: UUID().uuidString,
            userId: "currentUser",
            fishId: selectedFish.lowercased().replacingOccurrences(of: " ", with: "_"),
            fishName: selectedFish,
            date: Date(),
            time: Date(),
            locationName: locationName,
            latitude: nil,
            longitude: nil,
            weight: Double(weight),
            length: Double(length),
            quantity: quantity,
            weather: "Sunny", // Would come from weather service
            temperature: nil,
            waterTemperature: nil,
            moonPhase: "Full Moon", // Would come from moon service
            windSpeed: nil,
            baitUsed: baitUsed,
            lineWeight: nil,
            depth: nil,
            photoURLs: [],
            notes: notes,
            isReleased: isReleased,
            createdAt: Date()
        )
        
        viewModel.addCatch(newCatch, images: selectedImages)
        dismiss()
    }
}

// Simple ImagePicker wrapper
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 5
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.images.append(image)
                        }
                    }
                }
            }
        }
    }
}
