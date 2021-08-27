require 'rails_helper'

describe Schools::SchoolUpdater do

  let(:has_heaters) { true }
  let(:school)  { create(:school, indicated_has_storage_heaters: has_heaters) }
  let(:service) { Schools::SchoolUpdater.new(school) }

  describe '#after_update!' do

    it "invalidates the cache" do
      expect_any_instance_of(AggregateSchoolService).to receive(:invalidate_cache).at_least(:once)
      service.after_update!
    end

    context 'storage heaters config is changed' do

      before(:each) do
        allow_any_instance_of(AggregateSchoolService).to receive(:invalidate_cache)
      end

      context 'and school has target' do
        context 'and storage heaters are added' do
          let(:has_heaters) { false }
          let!(:school_target) { create(:school_target, school: school, storage_heaters: nil) }

          it 'adds a school target event' do
            school.update!(indicated_has_storage_heaters: true)
            service.after_update!
            school.reload
            expect(school.has_school_target_event?(:storage_heaters_added)).to be true
          end

          it 'removes the event if the setting is changed back' do
            school.update!(indicated_has_storage_heaters: true)
            service.after_update!
            school.update!(indicated_has_storage_heaters: false)
            service.after_update!
            expect(school.has_school_target_event?(:storage_heaters_added)).to be false
          end
        end

        context 'and storage heaters are removed' do
          let!(:school_target) { create(:school_target, school: school) }

          it 'adds school target event' do
            school.update!(indicated_has_storage_heaters: false)
            service.after_update!
            school.reload
            expect(school.has_school_target_event?(:storage_heaters_removed)).to be true
          end

          it 'removes the event if the setting is changed back' do
            school.update!(indicated_has_storage_heaters: false)
            service.after_update!
            school.update!(indicated_has_storage_heaters: true)
            service.after_update!
            expect(school.has_school_target_event?(:storage_heaters_removed)).to be false
          end
        end

      end

      context 'and school has no target' do
        it 'doesnt add an event' do
          school.update!(indicated_has_storage_heaters: false)
          service.after_update!
          school.reload
          expect(SchoolTargetEvent.count).to eql 0
        end
      end

    end
  end
end
