class MobilityStringTranslations < ApplicationRecord
  def self.activity_type
    where(translatable_type: 'ActivityType')
  end

  def self.search(query)
    where("value ILIKE ?", '%' + query + '%')
  end
end
