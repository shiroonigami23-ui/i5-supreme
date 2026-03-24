#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "pathname"
require_relative "../lib/i5_supreme"

def parse_options(argv)
  options = {
    source: I5Supreme::Paths.root,
    output: nil,
    includes: I5Supreme::ReleasePipeline::DEFAULT_INCLUDES.dup
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
  zip_path = I5Supreme::ReleasePipeline.new(root: options[:source], includes: options[:includes]).build_zip(output: options[:output])
  puts "Built package: #{zip_path}"
end
