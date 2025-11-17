module AlphabeticalScopes
  extend ActiveSupport::Concern

  included do
    scope :by_letter, ->(letter) {
      where("CASE WHEN substr(name, 1, 1) ~ '^[0-9]' THEN '#' ELSE substr(upper(name), 1, 1) END = ?", letter)
    }
    scope :by_keyword, ->(keyword) { where('upper(name) LIKE ?', "%#{keyword.upcase}%") }
    scope :group_by_letter, -> { group("CASE WHEN substr(name, 1, 1) ~ '^[0-9]' THEN '#' ELSE substr(upper(name), 1, 1) END") }
  end
end
