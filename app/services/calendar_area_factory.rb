class CalendarAreaFactory
  def self.create(calendar_area, terms)
    england_and_wales = CalendarArea.where(title: 'England and Wales').first!
    calendar_area.parent_area = england_and_wales

    calendar_area.transaction do
      begin
        calendar_area.save!
        CalendarFactoryFromEventHash.new(terms, calendar_area, true).create
      rescue ActiveRecord::RecordInvalid => e
        calendar_area.errors.add(:base, e.message)
        raise ActiveRecord::Rollback
      end
    end

    calendar_area
  end
end
