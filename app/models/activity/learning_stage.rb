# frozen_string_literal: true

module Activity
  class LearningStage < ApplicationRecord
    extend Mobility
    include Enums::Country

    # Currently we have school_key_stages and activity_type_key_stages
    # So need to look at replacing / supporting these, if this is what we would like to do

    # Eng: KS1 KS2 KS3 KS4 KS5
    # Wales: PS1 PS2 PS3 PS4 PS5
    # Scotland: 1st Level, 2nd Level, 3rd Level, 4th Level, Senior Phase

    translates :name, type: :string, fallbacks: { cy: :en }
    translates :abbreviation, type: :string, fallbacks: { cy: :en }
  end
end
