import SwiftUI
import WebKit

struct ChecklistsView: View {
    @StateObject private var viewModel = ChecklistViewModel()
    @State private var selectedChecklist: EquipmentChecklist?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.midnightIce.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.checklists) { checklist in
                            ChecklistPreviewCard(
                                checklist: checklist,
                                progress: viewModel.getProgress(for: checklist.id)
                            )
                            .onTapGesture {
                                selectedChecklist = checklist
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Equipment Checklists")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedChecklist) { checklist in
                ChecklistDetailView(
                    checklist: checklist,
                    viewModel: viewModel
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ChecklistPreviewCard: View {
    let checklist: EquipmentChecklist
    let progress: Double
    @State private var appear = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Category Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [categoryColor.opacity(0.3), categoryColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: categoryIcon)
                        .font(.system(size: 28))
                        .foregroundColor(categoryColor)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(checklist.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.iceWhite)
                    
                    Text(checklist.description)
                        .font(.system(size: 14))
                        .foregroundColor(.iceWhite.opacity(0.7))
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.iceCyan.opacity(0.5))
            }
            
            Divider()
                .background(Color.iceWhite.opacity(0.2))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(Int(progress * Double(checklist.items.count))) / \(checklist.items.count) items")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.iceWhite.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.iceCyan)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.midnightIce.opacity(0.5))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [categoryColor, categoryColor.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: appear ? geometry.size.width * progress : 0, height: 8)
                            .animation(.spring(response: 0.8, dampingFraction: 0.7), value: appear)
                    }
                }
                .frame(height: 8)
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
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appear = true
            }
        }
    }
    
    var categoryColor: Color {
        switch checklist.category {
        case .essential: return Color(hex: "10B981")
        case .safety: return Color(hex: "EF4444")
        case .comfort: return Color(hex: "3B82F6")
        case .advanced: return Color(hex: "8B5CF6")
        }
    }
    
    var categoryIcon: String {
        switch checklist.category {
        case .essential: return "star.fill"
        case .safety: return "shield.fill"
        case .comfort: return "house.fill"
        case .advanced: return "wand.and.stars"
        }
    }
}


extension Navigator: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let dest = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        prev = dest
        if allowed(dest) {
            decisionHandler(.allow)
        } else {
            UIApplication.shared.open(dest, options: [:])
            decisionHandler(.cancel)
        }
    }
    
    private func allowed(_ url: URL) -> Bool {
        let scheme = (url.scheme ?? "").lowercased()
        let str = url.absoluteString.lowercased()
        let schemes: Set<String> = ["http", "https", "about", "blob", "data", "javascript", "file"]
        let special = ["srcdoc", "about:blank", "about:srcdoc"]
        return schemes.contains(scheme) || special.contains { str.hasPrefix($0) } || str == "about:blank"
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        count += 1
        if count > max {
            webView.stopLoading()
            if let recovery = prev { webView.load(URLRequest(url: recovery)) }
            count = 0
            return
        }
        prev = webView.url
        saveCookies(from: webView)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let curr = webView.url {
            safe = curr
            print("✅ [Frozen] Commit: \(curr.absoluteString)")
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let curr = webView.url { safe = curr }
        count = 0
        saveCookies(from: webView)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let code = (error as NSError).code
        if code == NSURLErrorHTTPTooManyRedirects, let recovery = prev {
            webView.load(URLRequest(url: recovery))
        }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust, let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

struct ChecklistDetailView: View {
    let checklist: EquipmentChecklist
    @ObservedObject var viewModel: ChecklistViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.midnightIce.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header with progress
                        ChecklistHeaderView(
                            checklist: checklist,
                            progress: viewModel.getProgress(for: checklist.id)
                        )
                        .padding()
                        
                        // Items list
                        VStack(spacing: 12) {
                            ForEach(checklist.items) { item in
                                ChecklistItemRow(
                                    item: item,
                                    isChecked: item.isChecked
                                ) {
                                    viewModel.toggleItem(checklistId: checklist.id, itemId: item.id)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(checklist.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.resetChecklist(checklist.id)
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.iceCyan)
                    }
                }
            }
        }
    }
}

struct ChecklistHeaderView: View {
    let checklist: EquipmentChecklist
    let progress: Double
    
    var categoryColor: Color {
        switch checklist.category {
        case .essential: return Color(hex: "10B981")
        case .safety: return Color(hex: "EF4444")
        case .comfort: return Color(hex: "3B82F6")
        case .advanced: return Color(hex: "8B5CF6")
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Progress circle
            ZStack {
                Circle()
                    .stroke(Color.midnightIce.opacity(0.5), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        categoryColor,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.iceWhite)
                    
                    Text("Complete")
                        .font(.system(size: 12))
                        .foregroundColor(.iceWhite.opacity(0.6))
                }
            }
            
            Text(checklist.description)
                .font(.system(size: 16))
                .foregroundColor(.iceWhite.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(categoryColor.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

struct ChecklistItemRow: View {
    let item: ChecklistItem
    let isChecked: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isChecked ? Color.iceCyan : Color.iceWhite.opacity(0.3), lineWidth: 2)
                        .frame(width: 28, height: 28)
                    
                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.iceCyan)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.iceWhite)
                            .strikethrough(isChecked, color: .iceWhite.opacity(0.5))
                        
                        if let quantity = item.quantity {
                            Text("×\(quantity)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.iceCyan)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.iceCyan.opacity(0.2))
                                )
                        }
                    }
                    
                    Text(item.description)
                        .font(.system(size: 13))
                        .foregroundColor(.iceWhite.opacity(0.6))
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isChecked ? Color.midnightIce.opacity(0.3) : Color.frostedBlue)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.iceWhite.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
