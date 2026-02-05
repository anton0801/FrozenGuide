import SwiftUI

struct AuthenticationView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var showSignUp = false
    
    var body: some View {
        ZStack {
            Color.midnightIce.ignoresSafeArea()
            
            if showSignUp {
                SignUpView(showSignUp: $showSignUp)
            } else {
                SignInView(showSignUp: $showSignUp)
            }
        }
    }
}

// SignInView.swift
struct SignInView: View {
    @Binding var showSignUp: Bool
    @StateObject private var authManager = AuthManager.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Logo and title
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.iceCyan.opacity(0.3), Color.iceCyan.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "fish.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.iceCyan)
                }
                
                VStack(spacing: 8) {
                    Text("FROZEN GUIDE")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.iceWhite)
                    
                    Text("Your Ice Fishing Companion")
                        .font(.system(size: 16))
                        .foregroundColor(.iceCyan.opacity(0.8))
                }
            }
            .padding(.bottom, 60)
            
            // Sign in form
            VStack(spacing: 20) {
                AuthTextField(
                    icon: "envelope.fill",
                    placeholder: "Email",
                    text: $email,
                    isSecure: false
                )
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                
                AuthTextField(
                    icon: "lock.fill",
                    placeholder: "Password",
                    text: $password,
                    isSecure: true
                )
                
                Button(action: {
                    signIn()
                }) {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .midnightIce))
                    } else {
                        Text("Sign In")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.midnightIce)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color.iceCyan, Color.iceCyan.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .disabled(authManager.isLoading)
                
                Button(action: {
                    showSignUp = true
                }) {
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .foregroundColor(.iceWhite.opacity(0.7))
                        Text("Sign Up")
                            .foregroundColor(.iceCyan)
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 15))
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Guest mode button
            VStack(spacing: 12) {
                Text("OR")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.iceWhite.opacity(0.5))
                
                Button(action: {
                    continueAsGuest()
                }) {
                    HStack {
                        Image(systemName: "person.fill.questionmark")
                            .font(.system(size: 18))
                        Text("Continue as Guest")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.iceWhite)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.iceWhite.opacity(0.3), lineWidth: 2)
                    )
                }
                .padding(.horizontal, 30)
            }
            .padding(.bottom, 40)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authManager.errorMessage ?? "An error occurred")
        }
        .onChange(of: authManager.errorMessage) { newValue in
            if newValue != nil {
                showError = true
            }
        }
    }
    
    private func signIn() {
        authManager.signIn(email: email, password: password) { result in
            switch result {
            case .success:
                break
            case .failure:
                break
            }
        }
    }
    
    private func continueAsGuest() {
        authManager.continueAsGuest { result in
            switch result {
            case .success:
                break
            case .failure:
                break
            }
        }
    }
}

// SignUpView.swift
struct SignUpView: View {
    @Binding var showSignUp: Bool
    @StateObject private var authManager = AuthManager.shared
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    showSignUp = false
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.iceCyan)
                }
                
                Spacer()
                
                Text("Create Account")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.iceWhite)
                
                Spacer()
                
                // Invisible spacer for centering
                Image(systemName: "chevron.left")
                    .font(.system(size: 20))
                    .opacity(0)
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            .padding(.bottom, 40)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Avatar placeholder
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.iceCyan.opacity(0.3), Color.iceCyan.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.iceCyan)
                    }
                    .padding(.bottom, 20)
                    
                    // Form fields
                    AuthTextField(
                        icon: "person.fill",
                        placeholder: "Username",
                        text: $username,
                        isSecure: false
                    )
                    
                    AuthTextField(
                        icon: "envelope.fill",
                        placeholder: "Email",
                        text: $email,
                        isSecure: false
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    
                    AuthTextField(
                        icon: "lock.fill",
                        placeholder: "Password",
                        text: $password,
                        isSecure: true
                    )
                    
                    AuthTextField(
                        icon: "lock.fill",
                        placeholder: "Confirm Password",
                        text: $confirmPassword,
                        isSecure: true
                    )
                    
                    // Password requirements
                    VStack(alignment: .leading, spacing: 8) {
                        PasswordRequirement(
                            text: "At least 8 characters",
                            isMet: password.count >= 8
                        )
                        PasswordRequirement(
                            text: "Passwords match",
                            isMet: !password.isEmpty && password == confirmPassword
                        )
                    }
                    .padding(.top, 8)
                    
                    Button(action: {
                        signUp()
                    }) {
                        if authManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .midnightIce))
                        } else {
                            Text("Create Account")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.midnightIce)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color.iceCyan, Color.iceCyan.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .disabled(authManager.isLoading || !isFormValid)
                    .opacity(isFormValid ? 1 : 0.5)
                    .padding(.top, 20)
                    
                    Text("By creating an account, you agree to our Terms of Service and Privacy Policy")
                        .font(.system(size: 12))
                        .foregroundColor(.iceWhite.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 30)
            }
            
            Spacer()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onChange(of: authManager.errorMessage) { newValue in
            if let message = newValue {
                errorMessage = message
                showError = true
            }
        }
    }
    
    private var isFormValid: Bool {
        return !username.isEmpty &&
               !email.isEmpty &&
               password.count >= 8 &&
               password == confirmPassword
    }
    
    private func signUp() {
        guard isFormValid else { return }
        
        authManager.signUp(email: email, password: password, username: username) { result in
            switch result {
            case .success:
                showSignUp = false
            case .failure:
                break
            }
        }
    }
}

// AuthTextField.swift
struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    
    @State private var isSecureVisible = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.iceCyan)
                .frame(width: 24)
            
            if isSecure && !isSecureVisible {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(.iceWhite)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(.iceWhite)
            }
            
            if isSecure {
                Button(action: {
                    isSecureVisible.toggle()
                }) {
                    Image(systemName: isSecureVisible ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.iceCyan.opacity(0.6))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.frostedBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.iceWhite.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct PasswordRequirement: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14))
                .foregroundColor(isMet ? Color(hex: "10B981") : .iceWhite.opacity(0.3))
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.iceWhite.opacity(0.7))
        }
    }
}
