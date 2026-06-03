FactoryBot.define do
  factory :activity do
    school { create(:school) }
    activity_type
    activity_category
    title             { 'test activity title' }
    description       { 'test activity description' }
    happened_on       { Time.zone.today - 1.day }

    to_create do |instance|
      ActivityCreator.new(instance, instance.created_by).process
    end
  end

  factory :activity_without_creator, class: 'Activity' do
    school { create(:school) }
    activity_type
    activity_category
    title             { 'test activity title' }
    description       { 'test activity description' }
    happened_on       { Time.zone.today - 1.day }

    trait :with_contributors do
      created_by { association :user }
      updated_by { association :user }
    end

    trait :with_image_in_description do
      after(:build) do |activity|
        activity.description = content_with_attachment
      end
    end
  end
end
