require 'fileutils'
require 'xcodeproj'

base_dir = '/Users/development/Documents/CoffeeCall/apps/frontend/Coffee_Call/Coffee_Call'

FileUtils.mkdir_p(File.join(base_dir, 'DesignSystem'))
FileUtils.mkdir_p(File.join(base_dir, 'Components'))
FileUtils.mkdir_p(File.join(base_dir, 'Screens'))

# 1. Color+Extensions.swift
File.write(File.join(base_dir, 'DesignSystem', 'Color+Extensions.swift'), <<-SWIFT
import SwiftUI

extension Color {
    static let coffeePrimary = Color("coffeePrimary")
    static let coffeePrimaryLight = Color("coffeePrimaryLight")
    static let coffeePrimaryDark = Color("coffeePrimaryDark")
    static let coffeeBackground = Color("coffeeBackground")
    static let coffeeSurface = Color("coffeeSurface")
    static let coffeeSuccess = Color("coffeeSuccess")
    static let coffeeTextPrimary = Color("coffeeTextPrimary")
    static let coffeeTextSecondary = Color("coffeeTextSecondary")
}
SWIFT
)

# 2. Font+Extensions.swift
File.write(File.join(base_dir, 'DesignSystem', 'Font+Extensions.swift'), <<-SWIFT
import SwiftUI

extension Font {
    static let heading1 = Font.system(size: 32, weight: .bold, design: .rounded)
    static let bodyStandard = Font.system(size: 16, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)
    static let captionText = Font.system(size: 12, weight: .medium, design: .default)
    static let buttonText = Font.system(size: 16, weight: .bold, design: .rounded)
}
SWIFT
)

# 3. PrimaryButton.swift
File.write(File.join(base_dir, 'Components', 'PrimaryButton.swift'), <<-SWIFT
import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.buttonText)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isDisabled ? Color.coffeeTextSecondary.opacity(0.5) : Color.coffeePrimary)
                .clipShape(Capsule())
        }
        .disabled(isDisabled)
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PrimaryButton(title: "Let's Go", action: {})
            PrimaryButton(title: "Disabled", action: {}, isDisabled: true)
        }
        .padding()
        .background(Color.coffeeBackground)
    }
}
SWIFT
)

# 4. GlassmorphicCard.swift
File.write(File.join(base_dir, 'Components', 'GlassmorphicCard.swift'), <<-SWIFT
import SwiftUI

struct GlassmorphicCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(.thinMaterial)
            .background(Color.white.opacity(0.15))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct GlassmorphicCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.coffeePrimary.edgesIgnoringSafeArea(.all)
            GlassmorphicCard {
                Text("Glassmorphism")
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}
SWIFT
)

# 5. PillBadge.swift
File.write(File.join(base_dir, 'Components', 'PillBadge.swift'), <<-SWIFT
import SwiftUI

struct PillBadge: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 10, weight: .bold))
            Text(title)
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(0.2))
        .clipShape(Capsule())
    }
}

struct PillBadge_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.coffeePrimaryDark.edgesIgnoringSafeArea(.all)
            PillBadge(title: "BETA", systemImage: "sparkles")
        }
    }
}
SWIFT
)

# 6. OnboardingScreen.swift
File.write(File.join(base_dir, 'Screens', 'OnboardingScreen.swift'), <<-SWIFT
import SwiftUI

struct OnboardingScreen: View {
    var body: some View {
        ZStack {
            // Background Image Placeholder
            LinearGradient(
                colors: [Color.coffeeTextPrimary, Color.coffeeTextSecondary],
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    PillBadge(title: "COFFEECALL BETA", systemImage: "sparkles")
                    Spacer()
                }
                .padding(.top, 20)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Meet people")
                        .font(.heading1)
                        .foregroundColor(.white)
                    Text("nearby in")
                        .font(.heading1)
                        .foregroundColor(.white)
                    Text("real life.")
                        .font(.heading1)
                        .foregroundColor(.coffeePrimary)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                
                VStack(spacing: 16) {
                    HStack {
                        GlassmorphicCard {
                            HStack(spacing: 16) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.orange.opacity(0.8))
                                    .frame(width: 40, height: 40)
                                    .overlay(Image(systemName: "sun.max.fill").foregroundColor(.white))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("NOW NEARBY")
                                        .font(.captionText)
                                        .foregroundColor(.white.opacity(0.8))
                                    Text("Sunset Walk + Convo")
                                        .font(.bodySmall)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                        }
                        Spacer(minLength: 40)
                    }
                    
                    HStack {
                        Spacer(minLength: 40)
                        GlassmorphicCard {
                            HStack(spacing: 16) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.purple.opacity(0.8))
                                    .frame(width: 40, height: 40)
                                    .overlay(Image(systemName: "camera.fill").foregroundColor(.white))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("12 PEOPLE JOINED")
                                        .font(.captionText)
                                        .foregroundColor(.white.opacity(0.8))
                                    Text("Photo Session at Park")
                                        .font(.bodySmall)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                
                PrimaryButton(title: "Let's Go") {
                    print("Transition to Auth Flow")
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingScreen()
    }
}
SWIFT
)

# 7. Update ContentView.swift
content_view_path = File.join(base_dir, 'ContentView.swift')
if File.exist?(content_view_path)
    File.write(content_view_path, <<-SWIFT
import SwiftUI

struct ContentView: View {
    var body: some View {
        OnboardingScreen()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
SWIFT
    )
end

# 8. Link to Xcode Project
project_path = '/Users/development/Documents/CoffeeCall/apps/frontend/Coffee_Call/Coffee_Call.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Find the main group matching the project name
main_group = project.main_group.groups.find { |g| g.display_name == 'Coffee_Call' || g.name == 'Coffee_Call' }

def add_files(project, target, group, dir_path)
  Dir.foreach(dir_path) do |entry|
    next if entry == '.' || entry == '..' || entry == '.DS_Store' || entry == 'Assets.xcassets' || entry == 'Preview Content'
    full_path = File.join(dir_path, entry)
    
    if File.directory?(full_path)
      sub_group = group.groups.find { |g| g.path == entry || g.name == entry }
      if sub_group.nil?
        sub_group = group.new_group(entry, entry)
      end
      add_files(project, target, sub_group, full_path)
    elsif full_path.end_with?('.swift')
      file_ref = group.files.find { |f| f.path == entry || f.name == entry }
      if file_ref.nil?
        file_ref = group.new_file(entry)
      end
      unless target.source_build_phase.files_references.include?(file_ref)
        target.source_build_phase.add_file_reference(file_ref, true)
      end
    end
  end
end

add_files(project, target, main_group, base_dir)
project.save
puts "Successfully recreated all files and linked to new Xcode project!"
