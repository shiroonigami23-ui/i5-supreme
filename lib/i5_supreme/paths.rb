# frozen_string_literal: true

module I5Supreme
  module Paths
    module_function

    def root
      @root ||= File.expand_path("../..", __dir__)
    end

    def src
      File.join(root, "src")
    end

    def manifest
      File.join(src, "manifest.json")
    end

    def dist
      File.join(root, "dist")
    end

    def icon
      File.join(root, "icon")
    end
  end
end
