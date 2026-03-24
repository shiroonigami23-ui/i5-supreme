# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "json"
require_relative "../lib/i5_supreme"

class RuleAuditorTest < Minitest::Test
  def test_detects_duplicates_and_invalid_rules
    sample = [
      { "id" => 1, "priority" => 1, "action" => {}, "condition" => {} },
      { "id" => 1, "priority" => 2, "action" => {}, "condition" => {} },
      { "id" => "bad", "priority" => 2, "action" => {}, "condition" => {} }
    ]

    Dir.mktmpdir do |dir|
      path = File.join(dir, "rules.json")
      File.write(path, JSON.pretty_generate(sample))
      report = I5Supreme::RuleAuditor.new(rules_path: path).audit

      assert_equal 3, report[:total_rules]
      assert_includes report[:duplicate_ids], 1
      refute_empty report[:invalid_rules]
    end
  end
end
