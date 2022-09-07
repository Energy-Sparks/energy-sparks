require 'rails_helper'

describe Alerts::DeleteContentGenerationRunService, type: :service do
  let(:created_at)        { Time.zone.now }
  let!(:school)            { create(:school) }
  let!(:run)               { ContentGenerationRun.create(created_at: created_at) }

  let(:service)   { Alerts::DeleteContentGenerationRunService.new }

  it 'defaults to beginning of month, 2 months ago' do
    expect(service.older_than).to eql(3.months.ago.beginning_of_month)
  end

  it 'doesnt delete new runs' do
    date_time = (Time.zone.now - 3.months)
    school.content_generation_runs.create!(created_at: date_time + 1.day)
    school.content_generation_runs.create!(created_at: date_time + 1.week)
    school.content_generation_runs.create!(created_at: date_time + 1.month)
    school.content_generation_runs.create!(created_at: Time.zone.now)
    expect(ContentGenerationRun.count).to eq 4
    expect { service.delete! }.not_to change(ContentGenerationRun, :count)
  end

  context 'when there are older runs to delete' do
    it 'deletes only the older runs' do
      school.content_generation_runs.create!(created_at: Time.zone.now)
      school.content_generation_runs.create!(created_at: (Time.zone.now - 3.months).beginning_of_month + 1.day)
      school.content_generation_runs.create!(created_at: (Time.zone.now - 3.months).beginning_of_month)
      school.content_generation_runs.create!(created_at: (Time.zone.now - 6.months).beginning_of_month)
      expect(ContentGenerationRun.count).to eq 4
      expect { service.delete! }.to change(ContentGenerationRun, :count).from(4).to(2)
    end

    it 'deletes all of the dependent objects' do
    end
  end
end
