require 'fileutils'
require 'xcodeproj'

base_dir = '/Users/development/Documents/CoffeeCall/apps/frontend/Coffee_Call/Coffee_Call/Screens/Auth'
FileUtils.mkdir_p(base_dir)

# 1. PhoneAuthScreen.swift
File.write(File.join(base_dir, 'PhoneAuthScreen.swift'), <<-SWIFT
import SwiftUI

struct PhoneAuthScreen: View {
    @State private var phoneNumber: String = ""
    @Environment(\\.presentationMode) var presentationMode
    
    var isPhoneValid: Bool {
        return phoneNumber.count >= 10
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.coffeeTextPrimary)
                }
                Spacer()
            }
            .padding(.top, 16)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("What's your\\nphone number?")
                    .font(.heading1)
                    .foregroundColor(.coffeeTextPrimary)
                
                Text("We'll send you a code to verify your number so you can connect with people safely.")
                    .font(.bodyStandard)
                    .foregroundColor(.coffeeTextSecondary)
                    .lineSpacing(4)
            }
            .padding(.top, 16)
            
            // Phone Input
            HStack(spacing: 12) {
                Text("+1")
                    .font(.heading1)
                    .foregroundColor(.coffeeTextPrimary)
                
                TextField("555-555-5555", text: $phoneNumber)
                    .font(.heading1)
                    .keyboardType(.numberPad)
                    .foregroundColor(.coffeeTextPrimary)
            }
            .padding(.vertical, 16)
            
            Divider()
                .background(Color.coffeeTextSecondary.opacity(0.3))
            
            Spacer()
            
            NavigationLink(destination: OTPVerificationScreen(phoneNumber: "+1 \\(phoneNumber)")) {
                Text("Send Code →")
                    .font(.buttonText)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isPhoneValid ? Color.coffeePrimary : Color.coffeeTextSecondary.opacity(0.5))
                    .clipShape(Capsule())
            }
            .disabled(!isPhoneValid)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
        .background(Color.coffeeSurface.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
}

struct PhoneAuthScreen_Previews: PreviewProvider {
    static var previews: some View {
        PhoneAuthScreen()
    }
}
SWIFT
)

# 2. OTPVerificationScreen.swift
File.write(File.join(base_dir, 'OTPVerificationScreen.swift'), <<-SWIFT
import SwiftUI

struct OTPVerificationScreen: View {
    var phoneNumber: String
    @State private var otpCode: String = ""
    @Environment(\\.presentationMode) var presentationMode
    
    var isCodeComplete: Bool {
        return otpCode.count == 6
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.coffeeTextPrimary)
                }
                Spacer()
            }
            .padding(.top, 16)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter your\\nverification code")
                    .font(.heading1)
                    .foregroundColor(.coffeeTextPrimary)
                
                Text("Sent to \\(phoneNumber)")
                    .font(.bodyStandard)
                    .foregroundColor(.coffeeTextSecondary)
            }
            .padding(.top, 16)
            
            TextField("000000", text: $otpCode)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .keyboardType(.numberPad)
                .foregroundColor(.coffeeTextPrimary)
                .padding(.vertical, 16)
            
            Divider()
                .background(Color.coffeeTextSecondary.opacity(0.3))
            
            Spacer()
            
            NavigationLink(destination: ProfileSetupScreen()) {
                Text("Verify")
                    .font(.buttonText)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isCodeComplete ? Color.coffeePrimary : Color.coffeeTextSecondary.opacity(0.5))
                    .clipShape(Capsule())
            }
            .disabled(!isCodeComplete)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
        .background(Color.coffeeSurface.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
}

struct OTPVerificationScreen_Previews: PreviewProvider {
    static var previews: some View {
        OTPVerificationScreen(phoneNumber: "+1 555-555-5555")
    }
}
SWIFT
)

# 3. ProfileSetupScreen.swift
File.write(File.join(base_dir, 'ProfileSetupScreen.swift'), <<-SWIFT
import SwiftUI

struct ProfileSetupScreen: View {
    @State private var firstName: String = ""
    
    var isReady: Bool {
        return !firstName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            Text("Set up your profile")
                .font(.heading1)
                .foregroundColor(.coffeeTextPrimary)
                .padding(.top, 60)
            
            // Photo Upload Placeholder
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.coffeeTextSecondary.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 120))
                            .foregroundColor(.coffeeTextSecondary.opacity(0.3))
                    )
                
                Circle()
                    .fill(Color.coffeePrimary)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .offset(x: -8, y: -8)
            }
            .padding(.vertical, 24)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("FIRST NAME")
                    .font(.captionText)
                    .foregroundColor(.coffeeTextSecondary)
                
                TextField("e.g. Alex", text: $firstName)
                    .font(.heading1)
                    .foregroundColor(.coffeeTextPrimary)
                
                Divider()
                    .background(Color.coffeeTextSecondary.opacity(0.3))
            }
            
            Spacer()
            
            NavigationLink(destination: LocationPermissionScreen()) {
                Text("Continue →")
                    .font(.buttonText)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isReady ? Color.coffeePrimary : Color.coffeeTextSecondary.opacity(0.5))
                    .clipShape(Capsule())
            }
            .disabled(!isReady)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
        .background(Color.coffeeSurface.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
}

struct ProfileSetupScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSetupScreen()
    }
}
SWIFT
)

# 4. LocationPermissionScreen.swift
File.write(File.join(base_dir, 'LocationPermissionScreen.swift'), <<-SWIFT
import SwiftUI

struct LocationPermissionScreen: View {
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Spacer()
            
            Circle()
                .fill(Color.white)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "location.fill")
                        .foregroundColor(.coffeePrimary)
                        .font(.system(size: 32))
                )
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            
            Text("Enable Location")
                .font(.heading1)
                .foregroundColor(.coffeeTextPrimary)
                .multilineTextAlignment(.center)
            
            Text("CoffeeCall uses your location to match you with nearby people and activities within a 10km radius.")
                .font(.bodyStandard)
                .foregroundColor(.coffeeTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 16)
            
            Spacer()
            
            VStack(spacing: 16) {
                PrimaryButton(title: "Allow Location") {
                    print("Requesting Location Permissions")
                }
                
                Button(action: {
                    print("Skipping Location")
                }) {
                    Text("Skip for now")
                        .font(.buttonText)
                        .foregroundColor(.coffeeTextSecondary)
                }
                .padding(.vertical, 8)
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
        .background(Color.coffeeSurface.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
}

struct LocationPermissionScreen_Previews: PreviewProvider {
    static var previews: some View {
        LocationPermissionScreen()
    }
}
SWIFT
)

# Inject into Xcode
project_path = '/Users/development/Documents/CoffeeCall/apps/frontend/Coffee_Call/Coffee_Call.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first
main_group = project.main_group.groups.find { |g| g.display_name == 'Coffee_Call' || g.name == 'Coffee_Call' }
screens_group = main_group.groups.find { |g| g.name == 'Screens' }

# Find or create Auth group
auth_group = screens_group.groups.find { |g| g.name == 'Auth' || g.path == 'Auth' }
if auth_group.nil?
    auth_group = screens_group.new_group('Auth', 'Auth')
end

Dir.foreach(base_dir) do |entry|
    next unless entry.end_with?('.swift')
    file_ref = auth_group.files.find { |f| f.path == entry || f.name == entry }
    if file_ref.nil?
        file_ref = auth_group.new_file(entry)
    end
    unless target.source_build_phase.files_references.include?(file_ref)
        target.source_build_phase.add_file_reference(file_ref, true)
    end
end

project.save
puts "Successfully created Auth screens and linked to Xcode!"
