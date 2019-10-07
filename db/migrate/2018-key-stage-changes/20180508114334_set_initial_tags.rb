class SetInitialTags < ActiveRecord::Migration[5.1]
  def change

    # No longer runs

    #ks1 = KeyStage.where(name: 'KS1').first_or_create
    #ks2 = KeyStage.where(name: 'KS2').first_or_create
    #KeyStage.where(name: 'KS3').first_or_create

    #School.all.each do |school|
      #school.update!(key_stages: [ks1, ks2])
    #end

    #ActivityType.all.each do |activity_type|
      #activity_type.update!(key_stages: [ks1, ks2])
    #end
  end
end
