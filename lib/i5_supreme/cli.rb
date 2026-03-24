# frozen_string_literal: true

require "optparse"
require "json"
require_relative "paths"
require_relative "version"
require_relative "manifest_manager"
require_relative "rule_auditor"
require_relative "release_pipeline"

module I5Supreme
  class CLI
    def initialize(argv)
      @argv = argv.dup
    end

    def run
      command = @argv.shift
      case command
      when "manifest:summary" then manifest_summary
      when "manifest:set-version" then manifest_set_version
      when "manifest:set-description" then manifest_set_description
      when "rules:audit" then rules_audit
      when "release:build" then release_build
      when "version", "--version", "-v" then puts(I5Supreme::VERSION)
      else
        puts help_text
        command.nil? ? 0 : 1
      end
    rescue StandardError => e
      warn "i5-supreme error: #{e.message}"
      1
    end

    private

    def manifest_manager(path = I5Supreme::Paths.manifest)
      I5Supreme::ManifestManager.new(manifest_path: path)
    end

    def release_pipeline(root = I5Supreme::Paths.root)
      I5Supreme::ReleasePipeline.new(root: root)
    end

    def manifest_summary
      puts JSON.pretty_generate(manifest_manager.summary)
      0
    end

    def manifest_set_version
      options = parse_flags("Usage: i5-supreme manifest:set-version --value 1.8", value: true)
      manifest_manager.set_version(options.fetch(:value))
      puts "manifest version set to #{options[:value]}"
      0
    end

    def manifest_set_description
      options = parse_flags("Usage: i5-supreme manifest:set-description --value \"...\"", value: true)
      manifest_manager.set_description(options.fetch(:value))
      puts "manifest description updated"
      0
    end

    def rules_audit
      rules_path = File.join(I5Supreme::Paths.src, "rules.json")
      report = I5Supreme::RuleAuditor.new(rules_path: rules_path).audit
      puts JSON.pretty_generate(report)
      report[:duplicate_ids].empty? && report[:invalid_rules].empty? ? 0 : 2
    end

    def release_build
      options = parse_flags(
        "Usage: i5-supreme release:build [--root PATH] [--zip dist/file.zip]",
        root: false,
        zip: false
      )
      root = options[:root] || I5Supreme::Paths.root
      zip = options[:zip] || "dist/web-god-mode-supreme.zip"

      pipeline = release_pipeline(root)
      zip_path = pipeline.build_zip(output: zip)
      checksums_path = pipeline.write_checksums(output: "dist/checksums.txt")
      manifest_path = pipeline.write_release_manifest(
        output: "dist/release_manifest.json",
        artifacts: [zip_path]
      )

      puts "built: #{zip_path}"
      puts "checksums: #{checksums_path}"
      puts "release manifest: #{manifest_path}"
      0
    end

    def parse_flags(banner, root: false, zip: false, value: false)
      options = {}
      parser = OptionParser.new do |opts|
        opts.banner = banner
        opts.on("--root PATH", "Project root") { |v| options[:root] = v } if root
        opts.on("--zip PATH", "Zip output") { |v| options[:zip] = v } if zip
        opts.on("--value VALUE", "Required value") { |v| options[:value] = v } if value
      end
      parser.parse!(@argv)

      if value && (options[:value].nil? || options[:value].strip.empty?)
        raise "missing required flag: --value"
      end

      options
    end

    def help_text
      <<~TXT
        i5-supreme #{I5Supreme::VERSION}
        Commands:
          manifest:summary
          manifest:set-version --value 1.8
          manifest:set-description --value "..."
          rules:audit
          release:build [--root PATH] [--zip dist/web-god-mode-supreme.zip]
          version
      TXT
    end
  end
end
