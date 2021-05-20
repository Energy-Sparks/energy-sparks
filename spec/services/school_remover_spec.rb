require 'rails_helper'

describe SchoolRemover, :schools, type: :service do

  let(:school) { create(:school, active: true, visible: false) }

  let(:service) { SchoolRemover.new(school) }

  describe '#remove_school!' do
    it 'marks the school as inactive and sets removal date' do
      service.remove_school!
      expect(school.active).to be_falsey
      expect(school.removal_date).to eq(Time.zone.today)
    end

    it 'fails if school is visible' do
      school.update(visible: true)
      expect {
        service.remove_school!
      }.to raise_error(SchoolRemover::Error)
    end
  end

  # deactivate meters
  # remove meter readings, tariffs
  # remove school from user cluster schools
  # remove alert contacts

  # remove onboarding?
  # remove calendars?
  # remove calendars?

end
