require 'rails_helper'

describe 'Activity' do
  describe '#between' do
    let!(:activity_1) { create(:activity, happened_on: '2020-02-01') }
    let!(:activity_2) { create(:activity, happened_on: '2020-03-01') }
    let!(:activity_3) { create(:activity, happened_on: '2020-04-01') }

    it 'returns ranges of activities' do
      expect(Activity.between('2020-01-01', '2020-01-31')).to match_array([])
      expect(Activity.between('2020-01-01', '2020-02-01')).to match_array([activity_1])
      expect(Activity.between('2020-01-01', '2020-03-31')).to match_array([activity_1, activity_2])
      expect(Activity.between('2020-01-01', '2020-04-01')).to match_array([activity_1, activity_2, activity_3])
    end
  end

  describe '#recorded_in_last_week' do
    let(:activity_too_old)      { create(:activity) }
    let(:activity_last_week_1)  { create(:activity) }
    let(:activity_last_week_2)  { create(:activity) }

    before do
      activity_too_old.update!(created_at: (7.days.ago - 1.minute))
      activity_last_week_1.update!(created_at: (7.days.ago + 1.minute))
      activity_last_week_2.update!(created_at: 1.minute.ago)
    end

    it 'excludes older activities' do
      expect(Activity.recorded_in_last_week).to match_array([activity_last_week_1, activity_last_week_2])
    end
  end

  describe 'Callbacks' do
    before do
      SiteSettings.current.update(photo_bonus_points: 5)
    end

    let(:observation) { activity.observations.last.reload }

    context 'when updating happened_on' do
      let!(:activity) { create(:activity, happened_on: Date.new(2025, 10, 5)) } # also creates observation

      before do
        activity.update(happened_on: Date.new(2025, 10, 7))
      end

      it 'updates associated observation at date' do
        expect(observation.at.to_date).to eq(Date.new(2025, 10, 7))
      end
    end

    context 'when updated_by changed' do
      let!(:activity) { create(:activity) } # also creates observation
      let(:user) { create(:school_admin) }

      before do
        activity.update(updated_by: user)
      end

      it 'updates associated observation updated_by' do
        expect(observation.updated_by).to eq(user)
      end
    end

    def add_image(activity)
      file = Rails.root.join('spec/fixtures/images/placeholder.png')

      blob = ActiveStorage::Blob.create_and_upload!(
        io: File.open(file),
        filename: 'placeholder.png',
        content_type: 'image/png'
      )

      attachment_html = ActionText::Attachment.from_attachable(blob).to_html
      activity.description = ActionText::Content.new("<div>#{attachment_html}</div>")
      activity.save
    end

    context 'when description does not have an image' do
      let(:description) { 'Initial description without bonus points' }
      let!(:activity) { create(:activity, description:, happened_on: Date.new(2025, 10, 5)) } # also creates observation

      it { expect(observation.points).to eq(activity.activity_type.score) }

      context 'when updating description to have an image' do
        before do
          add_image(activity)
        end

        it 'updates associated observation points' do
          expect(observation.points).to eq(activity.activity_type.score + SiteSettings.current.photo_bonus_points)
        end
      end
    end

    context 'when description already has image' do
      let(:description) { 'Initial description with bonus points figure' }
      let(:activity) { create(:activity, description:) } # also creates observation

      before do
        add_image(activity)
      end

      it { expect(observation.points).to eq(activity.activity_type.score + SiteSettings.current.photo_bonus_points) }

      context 'when updating description to have no image' do
        before do
          activity.update(description: 'New description without bonus points')
        end

        it 'updates associated observation points' do
          expect(observation.points).to eq(activity.activity_type.score)
        end
      end
    end
  end
end
