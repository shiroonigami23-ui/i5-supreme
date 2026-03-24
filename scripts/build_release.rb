#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "pathname"

ROOT = File.expand_path("..", __dir__)

def run_step(command)
  puts ">> #{command}"
  ok = system(command)
  raise "Failed: #{command}" unless ok
end

def parse_options(argv)
  options = {
    root: ROOT,
    zip_output: File.join(ROOT, "dist", "web-god-mode-supreme.zip")
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
  builder = File.join(options[:root], "scripts", "release_builder.rb")
  checksums = File.join(options[:root], "scripts", "release_checksums.rb")

  run_step(%(ruby "#{builder}" --source "#{options[:root]}" --output "#{options[:zip_output]}"))
  run_step(%(ruby "#{checksums}" --root "#{options[:root]}"))
  puts "Release files are ready in #{File.dirname(options[:zip_output])}"
end
