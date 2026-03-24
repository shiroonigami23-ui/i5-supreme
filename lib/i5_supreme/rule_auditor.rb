# frozen_string_literal: true

require "json"

module I5Supreme
  class RuleAuditor
    def initialize(rules_path:)
      @rules_path = rules_path
    end

    def load_rules
      JSON.parse(File.read(@rules_path))
    end

    def audit
      rules = load_rules
      ids = {}
      duplicate_ids = []
      invalid_rules = []

      rules.each do |rule|
        id = rule["id"]
        duplicate_ids << id if ids.key?(id)
        ids[id] = true

        next if valid_rule?(rule)

        invalid_rules << id
      end

      {
        total_rules: rules.length,
        duplicate_ids: duplicate_ids.uniq,
        invalid_rules: invalid_rules.uniq
      }
    end

    private

    def valid_rule?(rule)
      has_id = rule["id"].is_a?(Integer)
      has_priority = rule["priority"].is_a?(Integer)
      has_action = rule["action"].is_a?(Hash)
      has_condition = rule["condition"].is_a?(Hash)
      has_id && has_priority && has_action && has_condition
    end
  end
end
