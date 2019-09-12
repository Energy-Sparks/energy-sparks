class CalendarAreaFactory
  def self.create(calendar_area, terms)
    calendar_area.transaction do
      begin
        calendar_area.save!
        CalendarFactoryFromEventHash.new(terms, true).create
      rescue ActiveRecord::RecordInvalid => e
        calendar_area.errors.add(:base, e.message)
        raise ActiveRecord::Rollback
      end
    end

    calendar_area
  end
end
