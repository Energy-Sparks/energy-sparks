module AlphabeticalScopes
  extend ActiveSupport::Concern

  class_methods do
    def alphabetical_scope_sql(ignore_prefix)
      name = remove_prefix_from_name(ignore_prefix)
      <<-SQL.squish
        CASE
          WHEN substr(#{name}, 1, 1) ~ '^[0-9]' THEN '#'
          ELSE substr(upper(#{name}), 1, 1)
        END
      SQL
    end

    private

    def remove_prefix_from_name(ignore_prefix = nil)
      return 'name' unless ignore_prefix
      "trim(leading '#{ignore_prefix}' from name)"
    end
  end

  included do
    scope :by_letter, ->(letter, ignore_prefix = nil) { where "#{alphabetical_scope_sql(ignore_prefix)} = ?", letter }
    scope :by_keyword, ->(keyword) { where('upper(name) LIKE ?', "%#{keyword.upcase}%") }
    scope :group_by_letter, ->(ignore_prefix = nil) { group alphabetical_scope_sql(ignore_prefix) }
  end
end
