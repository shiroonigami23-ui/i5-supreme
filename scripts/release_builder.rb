#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "optparse"
require "pathname"

begin
  require "zip"
rescue LoadError
  warn "Missing gem: rubyzip. Install with `gem install rubyzip`."
  exit 1
end

DEFAULT_INCLUDES = %w[src icon LICENSE README.md CHANGELOG.md].freeze

def collect_files(root, includes)
  files = []

  includes.each do |entry|
    full = File.join(root, entry)
    next unless File.exist?(full)

    if File.directory?(full)
      Dir.glob(File.join(full, "**", "*"), File::FNM_DOTMATCH).each do |candidate|
        next if File.directory?(candidate)
        next if File.basename(candidate).start_with?(".")

        files << candidate
      end
    else
      files << full
    end
  end

  files.uniq.sort
end

def relative_path(path, root)
  Pathname.new(path).relative_path_from(Pathname.new(root)).to_s.tr("\\", "/")
end

def build_zip(root:, output:, includes:)
  files = collect_files(root, includes)
  raise "No package files found. Expected any of: #{includes.join(", ")}" if files.empty?

  FileUtils.mkdir_p(File.dirname(output))
  FileUtils.rm_f(output)

  Zip::File.open(output, Zip::File::CREATE) do |zip|
    files.each do |file|
      zip.add(relative_path(file, root), file)
    end
  end

  output
end

def parse_options(argv)
  options = {
    source: File.expand_path("..", __dir__),
    output: nil,
    includes: DEFAULT_INCLUDES.dup
  }

  parser = OptionParser.new do |opts|
    opts.banner = "Usage: ruby scripts/release_builder.rb [options]"
    opts.on("--source PATH", "Project root to package") { |v| options[:source] = File.expand_path(v) }
    opts.on("--output PATH", "Output zip path (default: dist/web-god-mode-supreme.zip)") { |v| options[:output] = v }
    opts.on("--include x,y,z", Array, "Override package paths") { |v| options[:includes] = v }
  end

  parser.parse!(argv)
  options[:output] ||= File.join(options[:source], "dist", "web-god-mode-supreme.zip")
  options[:output] = File.expand_path(options[:output], options[:source]) unless Pathname.new(options[:output]).absolute?
  options
end

if $PROGRAM_NAME == __FILE__
  options = parse_options(ARGV)
  zip_path = build_zip(root: options[:source], output: options[:output], includes: options[:includes])
  puts "Built package: #{zip_path}"
end
