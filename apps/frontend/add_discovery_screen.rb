require 'xcodeproj'
require 'fileutils'

project_path = '/Users/development/Documents/CoffeeCall/apps/frontend/Coffee_Call/Coffee_Call.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Print all groups to find the right one
puts "Finding main group..."
main_group = project.main_group.groups.find { |g| g.display_name == 'Coffee_Call' || g.name == 'Coffee_Call' }

if main_group.nil?
    puts "Main group not found by name, listing all top-level groups:"
    project.main_group.groups.each { |g| puts "  #{g.display_name} (path: #{g.path})" }
    # Try to take the first one that isn't Frameworks or Products
    main_group = project.main_group.groups.find { |g| g.display_name != 'Frameworks' && g.display_name != 'Products' }
end

puts "Using main group: #{main_group.display_name}"

puts "Finding Screens group..."
screens_group = main_group.groups.find { |g| g.name == 'Screens' || g.display_name == 'Screens' }

if screens_group.nil?
    puts "Screens group not found, creating it..."
    screens_group = main_group.new_group('Screens', 'Screens')
end

# 1. Create Main group if missing
puts "Finding Main screens group..."
main_screens_group = screens_group.groups.find { |g| g.name == 'Main' || g.display_name == 'Main' || g.path == 'Main' }
if main_screens_group.nil?
    puts "Main screens group not found, creating it..."
    main_screens_group = screens_group.new_group('Main', 'Main')
end

# 2. Add Screen files
files = ['DiscoveryScreen.swift', 'MainTabView.swift']
files.each do |filename|
    file_ref = main_screens_group.files.find { |f| f.path == filename || f.name == filename }
    if file_ref.nil?
        puts "Adding #{filename} reference..."
        file_ref = main_screens_group.new_file(filename)
    end
    unless target.source_build_phase.files_references.include?(file_ref)
        target.source_build_phase.add_file_reference(file_ref, true)
    end
end

# 3. Add Component files
comp_group = main_group.groups.find { |g| g.name == 'Components' }
comp_files = ['CategoryChip.swift', 'ActivityCardView.swift']
comp_files.each do |filename|
    file_ref = comp_group.files.find { |f| f.path == filename || f.name == filename }
    if file_ref.nil?
        puts "Adding #{filename} to Components..."
        file_ref = comp_group.new_file(filename)
    end
    unless target.source_build_phase.files_references.include?(file_ref)
        target.source_build_phase.add_file_reference(file_ref, true)
    end
end

project.save
puts "Successfully added main screens and components to Xcode project!"

