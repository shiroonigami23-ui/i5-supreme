#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "optparse"
require "pathname"

DEFAULT_GLOB = "dist/*".freeze

def parse_options(argv)
  options = {
    root: File.expand_path("..", __dir__),
    glob: DEFAULT_GLOB,
    output: nil
  }

  parser = OptionParser.new do |opts|
    opts.banner = "Usage: ruby scripts/release_checksums.rb [options]"
    opts.on("--root PATH", "Project root (default: repo root)") { |v| options[:root] = File.expand_path(v) }
    opts.on("--glob GLOB", "Glob for release files (default: #{DEFAULT_GLOB})") { |v| options[:glob] = v }
    opts.on("--output PATH", "Output file (default: dist/checksums.txt)") { |v| options[:output] = v }
  end

  parser.parse!(argv)
  options[:output] ||= File.join(options[:root], "dist", "checksums.txt")
  options[:output] = File.expand_path(options[:output], options[:root]) unless Pathname.new(options[:output]).absolute?
  options
end

def checksum_lines(root:, glob:)
  pattern = File.expand_path(glob, root)
  files = Dir.glob(pattern).select { |path| File.file?(path) }.sort
  files.map do |path|
    rel = Pathname.new(path).relative_path_from(Pathname.new(root)).to_s.tr("\\", "/")
    "#{Digest::SHA256.file(path).hexdigest}  #{rel}"
  end
end

if $PROGRAM_NAME == __FILE__
  options = parse_options(ARGV)
  lines = checksum_lines(root: options[:root], glob: options[:glob])
  raise "No files found for #{options[:glob]}" if lines.empty?

  FileUtils.mkdir_p(File.dirname(options[:output]))
  File.write(options[:output], "#{lines.join("\n")}\n")
  puts "Wrote checksums: #{options[:output]}"
end
