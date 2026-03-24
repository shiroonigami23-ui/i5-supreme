# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "json"
require_relative "../lib/i5_supreme"

class ManifestManagerTest < Minitest::Test
  def test_setters_update_manifest
    Dir.mktmpdir do |dir|
      path = File.join(dir, "manifest.json")
      File.write(path, JSON.pretty_generate({ "name" => "x", "version" => "1.0", "description" => "old" }))
      manager = I5Supreme::ManifestManager.new(manifest_path: path)

      manager.set_version("2.0")
      manager.set_description("new")
      data = manager.load

      assert_equal "2.0", data["version"]
      assert_equal "new", data["description"]
    end
  end
end
