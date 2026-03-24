#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "pathname"
require_relative "../lib/i5_supreme"

def parse_options(argv)
  options = {
    root: I5Supreme::Paths.root,
    zip_output: File.join(I5Supreme::Paths.root, "dist", "web-god-mode-supreme.zip")
  }

  OptionParser.new do |opts|
    opts.banner = "Usage: ruby scripts/build_release.rb [options]"
    opts.on("--root PATH", "Project root (default: repo root)") { |v| options[:root] = File.expand_path(v) }
    opts.on("--zip-output PATH", "ZIP output path (default: dist/web-god-mode-supreme.zip)") { |v| options[:zip_output] = v }
  end.parse!(argv)

  options[:zip_output] = File.expand_path(options[:zip_output], options[:root]) unless Pathname.new(options[:zip_output]).absolute?
  options
end

if $PROGRAM_NAME == __FILE__
  options = parse_options(ARGV)
  pipeline = I5Supreme::ReleasePipeline.new(root: options[:root])
  zip_path = pipeline.build_zip(output: options[:zip_output])
  checksums_path = pipeline.write_checksums(output: File.join(options[:root], "dist", "checksums.txt"))
  manifest_path = pipeline.write_release_manifest(
    output: File.join(options[:root], "dist", "release_manifest.json"),
    artifacts: [zip_path]
  )

  puts "Built package: #{zip_path}"
  puts "Wrote checksums: #{checksums_path}"
  puts "Wrote release manifest: #{manifest_path}"
  puts "Release files are ready in #{File.dirname(options[:zip_output])}"
end
