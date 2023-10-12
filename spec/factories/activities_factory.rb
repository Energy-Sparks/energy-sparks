FactoryBot.define do
  factory :activity do
    school            { create(:school) }
    activity_type
    activity_category
    title             { 'test activity title' }
    description       { 'test activity description' }
    happened_on       { Time.zone.today - 1.days }

    to_create { |instance| ActivityCreator.new(instance).process }
  end
end
