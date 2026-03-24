# frozen_string_literal: true

require "digest"
require "fileutils"
require "pathname"
require "json"
require "time"

begin
  require "zip"
rescue LoadError
  warn "Missing gem: rubyzip. Install with `gem install rubyzip`."
  exit 1
end

module I5Supreme
  class ReleasePipeline
    DEFAULT_INCLUDES = %w[src icon LICENSE README.md CHANGELOG.md android].freeze

    def initialize(root:, includes: DEFAULT_INCLUDES)
      @root = File.expand_path(root)
      @includes = includes
    end

    def build_zip(output:)
      output = absolute(output)
      FileUtils.mkdir_p(File.dirname(output))
      FileUtils.rm_f(output)

      files = package_files
      raise "No package files found. Includes: #{@includes.join(", ")}" if files.empty?

      Zip::File.open(output, Zip::File::CREATE) do |zip|
        files.each { |file| zip.add(relative(file), file) }
      end

      output
    end

    def write_checksums(output:, glob: "dist/*")
      output = absolute(output)
      pattern = absolute(glob)
      files = Dir.glob(pattern).select { |path| File.file?(path) }.sort
      raise "No files found for #{glob}" if files.empty?

      lines = files.map { |path| "#{Digest::SHA256.file(path).hexdigest}  #{relative(path)}" }
      FileUtils.mkdir_p(File.dirname(output))
      File.write(output, "#{lines.join("\n")}\n")
      output
    end

    def write_release_manifest(output:, artifacts:)
      payload = {
        built_at_utc: Time.now.utc.iso8601,
        artifacts: artifacts.map do |artifact|
          path = absolute(artifact)
          {
            path: relative(path),
            size_bytes: File.size(path),
            sha256: Digest::SHA256.file(path).hexdigest
          }
        end
      }
      output = absolute(output)
      FileUtils.mkdir_p(File.dirname(output))
      File.write(output, JSON.pretty_generate(payload) + "\n")
      output
    end

    private

    def package_files
      files = []
      @includes.each do |entry|
        full = File.join(@root, entry)
        next unless File.exist?(full)

        if File.directory?(full)
          Dir.glob(File.join(full, "**", "*"), File::FNM_DOTMATCH).each do |candidate|
            next if File.directory?(candidate)
            next if File.basename(candidate).start_with?(".")
            next if candidate.include?("#{File::SEPARATOR}.git#{File::SEPARATOR}")
            next if candidate.include?("#{File::SEPARATOR}build#{File::SEPARATOR}")
            next if candidate.include?("#{File::SEPARATOR}.gradle#{File::SEPARATOR}")

            files << candidate
          end
        else
          files << full
        end
      end
      files.uniq.sort
    end

    def absolute(path)
      return path if Pathname.new(path).absolute?

      File.expand_path(path, @root)
    end

    def relative(path)
      Pathname.new(path).relative_path_from(Pathname.new(@root)).to_s.tr("\\", "/")
    end
  end
end
