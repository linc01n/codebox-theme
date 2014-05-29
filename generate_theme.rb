#!/usr/bin/env ruby

require 'tilt/erb'
require 'pathname'
require 'fileutils'

template = Tilt::ERBTemplate.new('templates/dark/package.json.erb')

output = template.render(self, title: "test", package_name: "testid")


Dir.glob("ace/lib/ace/theme/*.js") do |file|
  filename = Pathname.new(file).basename

  File.open(file, "r") do |f|
    # White theme
    f.grep(/isDark \= false/) do |match|

      theme_name = filename.to_s[0..-4].gsub("_", ".")
      title = theme_name.gsub(".", " ").split(" ").map(&:capitalize).join(" ")
      package_name = "cb.theme." + theme_name
      id = theme_name

      # Remove previous theme
      FileUtils.rm_rf(package_name) if File.directory?(package_name)

      # Create theme directory
      FileUtils.mkdir(package_name)

      # Prepare package.json content
      package_template = Tilt::ERBTemplate.new('templates/white/package.json.erb')
      package_content = package_template.render(self, title: title, package_name: package_name)

      # Write package.json content
      File.open(package_name+"/package.json", "w") do |package|
        package.write(package_content)
      end

      # Prepare main.js content
      main_template = Tilt::ERBTemplate.new('templates/white/main.js.erb')
      main_content = main_template.render(self, id: theme_name, title: title)

      # Write main.js content
      File.open(package_name+"/main.js", "w") do |main|
        main.write(main_content)
      end

      # Create ace directory
      FileUtils.mkdir(package_name+"/ace")

      # Prepare theme.js content
      theme_template = Tilt::ERBTemplate.new('templates/white/ace/theme.js.erb')
      theme_content = theme_template.render(self, css_name: id.gsub(".", "-"))

      # Write theme.js content
      File.open(package_name+"/ace/theme.js", "w") do |theme|
        theme.write(theme_content)
      end

      # Copy theme.css
      FileUtils.cp "ace/lib/ace/theme/#{filename.to_s[0..-4]}.css", "#{package_name}/ace/theme.css"
    end
  end
end
