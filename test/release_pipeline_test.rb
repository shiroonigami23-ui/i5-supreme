# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "fileutils"
require_relative "../lib/i5_supreme"

class ReleasePipelineTest < Minitest::Test
  def test_build_zip_and_checksums
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "src"))
      File.write(File.join(dir, "src", "content.js"), "console.log('x');")
      File.write(File.join(dir, "README.md"), "hello")

      pipeline = I5Supreme::ReleasePipeline.new(root: dir, includes: %w[src README.md])
      zip_path = pipeline.build_zip(output: File.join(dir, "dist", "out.zip"))
      checksums_path = pipeline.write_checksums(output: File.join(dir, "dist", "checksums.txt"))

      assert File.exist?(zip_path)
      assert File.exist?(checksums_path)
      assert_includes File.read(checksums_path), "out.zip"
    end
  end
end
