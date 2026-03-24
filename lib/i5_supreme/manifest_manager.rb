# frozen_string_literal: true

require "json"
require "fileutils"

module I5Supreme
  class ManifestManager
    def initialize(manifest_path:)
      @manifest_path = manifest_path
    end

    def load
      JSON.parse(File.read(@manifest_path))
    end

    def save(data)
      FileUtils.mkdir_p(File.dirname(@manifest_path))
      content = JSON.pretty_generate(data) + "\n"
      File.write(@manifest_path, content)
    end

    def set_version(version)
      manifest = load
      manifest["version"] = version
      save(manifest)
      version
    end

    def set_description(description)
      manifest = load
      manifest["description"] = description
      save(manifest)
      description
    end

    def summary
      manifest = load
      {
        "name" => manifest["name"],
        "version" => manifest["version"],
        "description" => manifest["description"],
        "homepage_url" => manifest["homepage_url"]
      }
    end
  end
end
