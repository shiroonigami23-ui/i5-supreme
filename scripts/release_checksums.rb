#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "pathname"
require_relative "../lib/i5_supreme"

def parse_options(argv)
  options = {
    root: I5Supreme::Paths.root,
    glob: "dist/*",
    output: nil
  }

  parser = OptionParser.new do |opts|
    opts.banner = "Usage: ruby scripts/release_checksums.rb [options]"
    opts.on("--root PATH", "Project root (default: repo root)") { |v| options[:root] = File.expand_path(v) }
    opts.on("--glob GLOB", "Glob for release files (default: dist/*)") { |v| options[:glob] = v }
    opts.on("--output PATH", "Output file (default: dist/checksums.txt)") { |v| options[:output] = v }
  end

  parser.parse!(argv)
  options[:output] ||= File.join(options[:root], "dist", "checksums.txt")
  options[:output] = File.expand_path(options[:output], options[:root]) unless Pathname.new(options[:output]).absolute?
  options
end

if $PROGRAM_NAME == __FILE__
  options = parse_options(ARGV)
  output = I5Supreme::ReleasePipeline.new(root: options[:root]).write_checksums(
    output: options[:output],
    glob: options[:glob]
  )
  puts "Wrote checksums: #{output}"
end
