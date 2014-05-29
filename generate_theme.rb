#!/usr/bin/env ruby

require 'tilt/erb'
require 'pathname'
require 'fileutils'

Dir.glob('ace/lib/ace/theme/*.js') do |file|
  filename = Pathname.new(file).basename
  theme_name = filename.to_s[0..-4].gsub('_', '.')
  title = theme_name.gsub('.', ' ').split(' ').map(&:capitalize).join(' ')
  package_name = 'cb.theme.' + theme_name
  id = theme_name
  # Remove previous theme
  FileUtils.rm_rf(package_name) if File.directory?(package_name)

  # Create theme directory
  FileUtils.mkdir(package_name)
  # Create ace directory
  FileUtils.mkdir(package_name + '/ace')
  # Copy theme.css
  FileUtils.cp "ace/lib/ace/theme/#{filename.to_s[0..-4]}.css", "#{package_name}/ace/theme.css"

  File.open(file, 'r') do |f|
    # White theme
    is_white = f.grep(/isDark \= true/).empty?

    color = ""

    if is_white
      color = "white"
    else
      color = "dark"
    end

    # Prepare package.json content
    package_template = Tilt::ERBTemplate.new("templates/#{color}/package.json.erb")
    package_content = package_template.render(self, title: title, package_name: package_name)

    # Write package.json content
    File.open(package_name + '/package.json', 'w') do |package|
      package.write(package_content)
    end

    # Prepare main.js content
    main_template = Tilt::ERBTemplate.new("templates/#{color}/main.js.erb")
    main_content = main_template.render(self, id: theme_name, title: title)

    # Write main.js content
    File.open(package_name + '/main.js', 'w') do |main|
      main.write(main_content)
    end

    # Prepare theme.js content
    theme_template = Tilt::ERBTemplate.new("templates/#{color}/ace/theme.js.erb")
    theme_content = theme_template.render(self, css_name: id.gsub('.', '-'))

    # Write theme.js content
    File.open(package_name + '/ace/theme.js', 'w') do |theme|
      theme.write(theme_content)
    end
  end
end
