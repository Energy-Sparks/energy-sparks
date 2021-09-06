require 'rails_helper'

describe Schools::SchoolUpdater do

  let(:school)  { create(:school) }
  let(:service) { Schools::SchoolUpdater.new(school) }

  describe '#after_update!' do

    it "invalidates the cache" do
      expect_any_instance_of(AggregateSchoolService).to receive(:invalidate_cache).at_least(:once)
      service.after_update!
    end

  end
end
