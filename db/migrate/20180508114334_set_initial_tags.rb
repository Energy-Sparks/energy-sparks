class SetInitialTags < ActiveRecord::Migration[5.1]
  def change
    School.all.each do |school|
      school.key_stage_list.add('KS1', 'KS2')
      school.save!
    end

    ActivityType.all.each do |activity_type|
      activity_type.key_stage_list.add('KS1', 'KS2')
      activity_type.save!
    end

    ActsAsTaggableOn::Tag.create(name: 'KS3')
  end
end
