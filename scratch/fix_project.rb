require 'xcodeproj'

project_path = 'apps/frontend/Coffee_Call/Coffee_Call.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# 1. Find the main target
target = project.targets.find { |t| t.name == 'Coffee_Call' }

# 2. Find and remove the "Models" folder reference if it exists as a file reference (which causes the Resource error)
# Folder references have lastKnownFileType set to "folder"
models_file_ref = project.files.find { |f| f.path == 'Models' }
if models_file_ref
  puts "Removing Models folder reference..."
  models_file_ref.remove_from_project
end

# 3. Find or create the proper "Models" Group
# Most projects have a top-level group named after the project
main_group = project.main_group['Coffee_Call'] || project.main_group

models_group = main_group['Models']
if !models_group
  puts "Creating Models group..."
  models_group = main_group.new_group('Models')
end

# 4. Add Activity.swift to the group
# Path is relative to the group's path on disk. 
# main_group['Coffee_Call'] usually points to the 'Coffee_Call' directory.
# So 'Models/Activity.swift' should be correct if it's inside that directory.
activity_path = 'Models/Activity.swift'
file_ref = models_group.find_file_by_path('Activity.swift')
if !file_ref
  puts "Adding Activity.swift to Models group..."
  file_ref = models_group.new_file(activity_path)
end

# 5. Add to Build Phase
if target
  puts "Adding Activity.swift to target sources..."
  target.add_resources([models_group]) if false # We don't want it in resources
  target.add_file_references([file_ref])
else
  puts "Target Coffee_Call not found!"
end

# 6. Save
project.save
puts "Project fixed successfully!"
