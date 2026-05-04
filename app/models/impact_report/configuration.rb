# frozen_string_literal: true

# == Schema Information
#
# Table name: impact_report_configurations
#
#  id                                   :bigint(8)        not null, primary key
#  active                               :boolean          default(FALSE), not null
#  energy_efficiency_note               :text
#  energy_efficiency_school_expiry_date :date
#  engagement_note                      :text
#  engagement_school_expiry_date        :date
#  show_energy_efficiency               :boolean          default(TRUE), not null
#  show_engagement                      :boolean          default(TRUE), not null
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  energy_efficiency_school_id          :bigint(8)
#  engagement_school_id                 :bigint(8)
#  school_group_id                      :bigint(8)        not null
#
# Indexes
#
#  idx_on_energy_efficiency_school_id_a86b38c262               (energy_efficiency_school_id)
#  index_impact_report_configurations_on_engagement_school_id  (engagement_school_id)
#  index_impact_report_configurations_on_school_group_id       (school_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (energy_efficiency_school_id => schools.id)
#  fk_rails_...  (engagement_school_id => schools.id)
#  fk_rails_...  (school_group_id => school_groups.id)
#

module ImpactReport
  class Configuration < ApplicationRecord
    self.table_name = 'impact_report_configurations'

    attribute :engagement_image_remove, :boolean
    attribute :energy_efficiency_image_remove, :boolean

    belongs_to :school_group

    belongs_to :engagement_school, class_name: 'School'
    belongs_to :energy_efficiency_school, class_name: 'School'

    has_one_attached :engagement_image
    has_one_attached :energy_efficiency_image

    before_save :remove_engagement_image, if: -> { engagement_image_remove }
    before_save :remove_energy_efficiency_image, if: -> { energy_efficiency_image_remove }

    validates :engagement_note,
              presence: { message: "can't be blank if a featured school is selected" }, # rubocop:disable Rails/I18nLocaleTexts
              if: :engagement_school

    validates :energy_efficiency_note,
              presence: { message: "can't be blank if a featured school is selected" }, # rubocop:disable Rails/I18nLocaleTexts
              if: :energy_efficiency_school

    def remove_engagement_image
      engagement_image.purge if engagement_image.attached?
    end

    def remove_energy_efficiency_image
      energy_efficiency_image.purge if energy_efficiency_image.attached?
    end
  end
end
