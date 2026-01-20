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
      after(:create) do |activity|
        # Create a blob for the image
        blob = ActiveStorage::Blob.create_and_upload!(
          io: File.open(Rails.root.join('spec/fixtures/images/placeholder.png')),
          filename: 'placeholder.png',
          content_type: 'image/png'
        )

        # Attach the blob to the description
        activity.description.embeds.attach(blob)

        # Ensure the description body references the attachment
        activity.description.body = <<~HTML
          <div>
            <action-text-attachment sgid="#{blob.attachable_sgid}">
            </action-text-attachment>
          </div>
        HTML

        activity.save!
      end
    end
  end
end
