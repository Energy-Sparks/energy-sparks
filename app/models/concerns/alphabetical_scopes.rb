module AlphabeticalScopes
  extend ActiveSupport::Concern

  included do
    def self.remove_prefix_from_name(ignore_prefix = nil)
      return 'name' unless ignore_prefix
      "regexp_replace(name, '^#{Regexp.escape(ignore_prefix)}\\s*', '', 'i')"
    end

    scope :by_letter, ->(letter, ignore_prefix = nil) do
      name = remove_prefix_from_name(ignore_prefix)

      where <<-SQL.squish, letter
        CASE
          WHEN substr(#{name}, 1, 1) ~ '^[0-9]' THEN '#'
          ELSE substr(upper(#{name}), 1, 1)
        END = ?
      SQL
    end

    scope :by_keyword, ->(keyword) { where('upper(name) LIKE ?', "%#{keyword.upcase}%") }

    scope :group_by_letter, ->(ignore_prefix = nil) do
      name = remove_prefix_from_name(ignore_prefix)

      group <<-SQL.squish
        CASE
          WHEN substr(#{name}, 1, 1) ~ '^[0-9]' THEN '#'
          ELSE substr(upper(#{name}), 1, 1)
        END
      SQL
    end
  end
end
