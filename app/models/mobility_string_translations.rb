class MobilityStringTranslations < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search,
                  against: [:value]

  def self.activity_type
    where(translatable_type: 'ActivityType')
  end

  # def self.search(query)
  #   where("value ILIKE ?", '%' + query + '%')
  # end
end
