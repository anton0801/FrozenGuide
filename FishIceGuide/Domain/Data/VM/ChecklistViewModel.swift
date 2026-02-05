import Foundation

class ChecklistViewModel: ObservableObject {
    @Published var checklists: [EquipmentChecklist] = []
    @Published var activeChecklist: EquipmentChecklist?
    
    init() {
        loadDefaultChecklists()
    }
    
    func loadDefaultChecklists() {
        checklists = [
            EquipmentChecklist(
                id: "essential",
                name: "Essential Gear",
                description: "Must-have items for ice fishing",
                category: .essential,
                items: [
                    ChecklistItem(id: "1", name: "Ice Auger", description: "For drilling holes", isChecked: false, quantity: 1),
                    ChecklistItem(id: "2", name: "Ice Fishing Rod", description: "Shorter rod for jigging", isChecked: false, quantity: 2),
                    ChecklistItem(id: "3", name: "Tip-ups", description: "For multiple lines", isChecked: false, quantity: 3),
                    ChecklistItem(id: "4", name: "Ice Scoop", description: "Clear ice from holes", isChecked: false, quantity: 1),
                    ChecklistItem(id: "5", name: "Tackle Box", description: "Organized tackle", isChecked: false, quantity: 1),
                    ChecklistItem(id: "6", name: "Jigs & Lures", description: "Various baits", isChecked: false, quantity: nil),
                    ChecklistItem(id: "7", name: "Live Bait", description: "Minnows or worms", isChecked: false, quantity: nil),
                    ChecklistItem(id: "8", name: "Fishing License", description: "Valid permit", isChecked: false, quantity: 1),
                    ChecklistItem(id: "9", name: "Ice Picks", description: "Safety device", isChecked: false, quantity: 1),
                    ChecklistItem(id: "10", name: "5-Gallon Bucket", description: "Seat and storage", isChecked: false, quantity: 1)
                ],
                isPredefined: true
            ),
            EquipmentChecklist(
                id: "safety",
                name: "Safety Equipment",
                description: "Items for safe ice fishing",
                category: .safety,
                items: [
                    ChecklistItem(id: "s1", name: "Ice Picks/Claws", description: "Self-rescue tool", isChecked: false, quantity: 1),
                    ChecklistItem(id: "s2", name: "Rope", description: "50+ feet for rescue", isChecked: false, quantity: 1),
                    ChecklistItem(id: "s3", name: "Life Jacket/Floatation", description: "Personal flotation", isChecked: false, quantity: 1),
                    ChecklistItem(id: "s4", name: "First Aid Kit", description: "Medical supplies", isChecked: false, quantity: 1),
                    ChecklistItem(id: "s5", name: "Whistle", description: "Signal for help", isChecked: false, quantity: 1),
                    ChecklistItem(id: "s6", name: "Ice Chisel/Spud", description: "Test ice thickness", isChecked: false, quantity: 1),
                    ChecklistItem(id: "s7", name: "Cell Phone", description: "Waterproof case", isChecked: false, quantity: 1),
                    ChecklistItem(id: "s8", name: "Emergency Blanket", description: "Thermal protection", isChecked: false, quantity: 1),
                    ChecklistItem(id: "s9", name: "Buddy System", description: "Never fish alone", isChecked: false, quantity: nil),
                    ChecklistItem(id: "s10", name: "Weather Radio", description: "Stay informed", isChecked: false, quantity: 1)
                ],
                isPredefined: true
            ),
            EquipmentChecklist(
                id: "comfort",
                name: "Comfort Items",
                description: "Stay warm and comfortable",
                category: .comfort,
                items: [
                    ChecklistItem(id: "c1", name: "Portable Shelter", description: "Ice shanty or tent", isChecked: false, quantity: 1),
                    ChecklistItem(id: "c2", name: "Portable Heater", description: "Propane or battery", isChecked: false, quantity: 1),
                    ChecklistItem(id: "c3", name: "Insulated Bibs", description: "Waterproof overalls", isChecked: false, quantity: 1),
                    ChecklistItem(id: "c4", name: "Winter Boots", description: "Insulated and waterproof", isChecked: false, quantity: 1),
                    ChecklistItem(id: "c5", name: "Gloves", description: "Warm and waterproof", isChecked: false, quantity: 2),
                    ChecklistItem(id: "c6", name: "Hat/Beanie", description: "Insulated cap", isChecked: false, quantity: 1),
                    ChecklistItem(id: "c7", name: "Hand Warmers", description: "Chemical heat packs", isChecked: false, quantity: 10),
                    ChecklistItem(id: "c8", name: "Thermos", description: "Hot drinks", isChecked: false, quantity: 1),
                    ChecklistItem(id: "c9", name: "Snacks", description: "High-energy food", isChecked: false, quantity: nil),
                    ChecklistItem(id: "c10", name: "Folding Chair", description: "Comfortable seating", isChecked: false, quantity: 1),
                    ChecklistItem(id: "c11", name: "Sunglasses", description: "UV protection", isChecked: false, quantity: 1),
                    ChecklistItem(id: "c12", name: "Sunscreen", description: "Face protection", isChecked: false, quantity: 1)
                ],
                isPredefined: true
            ),
            EquipmentChecklist(
                id: "advanced",
                name: "Advanced Gear",
                description: "Electronics and extras",
                category: .advanced,
                items: [
                    ChecklistItem(id: "a1", name: "Fish Finder/Flasher", description: "Depth and fish detection", isChecked: false, quantity: 1),
                    ChecklistItem(id: "a2", name: "Underwater Camera", description: "See below ice", isChecked: false, quantity: 1),
                    ChecklistItem(id: "a3", name: "GPS Device", description: "Mark spots", isChecked: false, quantity: 1),
                    ChecklistItem(id: "a4", name: "Power Auger", description: "Gas or electric drill", isChecked: false, quantity: 1),
                    ChecklistItem(id: "a5", name: "Ice Sled", description: "Transport gear", isChecked: false, quantity: 1),
                    ChecklistItem(id: "a6", name: "Portable Generator", description: "Power electronics", isChecked: false, quantity: 1),
                    ChecklistItem(id: "a7", name: "Bait Container", description: "Keep bait alive", isChecked: false, quantity: 1),
                    ChecklistItem(id: "a8", name: "Line Spooler", description: "Reline quickly", isChecked: false, quantity: 1),
                    ChecklistItem(id: "a9", name: "Camera/GoPro", description: "Document catches", isChecked: false, quantity: 1),
                    ChecklistItem(id: "a10", name: "Measuring Board", description: "Size verification", isChecked: false, quantity: 1)
                ],
                isPredefined: true
            )
        ]
    }
    
    func toggleItem(checklistId: String, itemId: String) {
        if var checklistIndex = checklists.firstIndex(where: { $0.id == checklistId }),
           let itemIndex = checklists[checklistIndex].items.firstIndex(where: { $0.id == itemId }) {
            checklists[checklistIndex].items[itemIndex].isChecked.toggle()
        }
    }
    
    func resetChecklist(_ checklistId: String) {
        if let index = checklists.firstIndex(where: { $0.id == checklistId }) {
            for i in 0..<checklists[index].items.count {
                checklists[index].items[i].isChecked = false
            }
        }
    }
    
    func getProgress(for checklistId: String) -> Double {
        guard let checklist = checklists.first(where: { $0.id == checklistId }) else {
            return 0
        }
        let checkedItems = checklist.items.filter { $0.isChecked }.count
        return Double(checkedItems) / Double(checklist.items.count)
    }
}
