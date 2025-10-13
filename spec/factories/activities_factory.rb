FactoryBot.define do
  factory :activity do
    school { create(:school) }
    activity_type
    activity_category
    title             { 'test activity title' }
    description       { 'test activity description' }
    happened_on       { Time.zone.today - 1.day }

    to_create { |instance| Tasks::Recorder.new(instance, nil).process }
  end

  factory :activity_without_creator, class: 'Activity' do
    school { create(:school) }
    activity_type
    activity_category
    title             { 'test activity title' }
    description       { 'test activity description' }
    happened_on       { Time.zone.today - 1.day }
  end
end
