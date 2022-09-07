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
  end

  context 'when there are older runs to delete' do
    it 'deletes only the older runs' do
    end

    it 'deletes all of the dependent objects' do
    end
  end
end