# == Schema Information
#
# Table name: programme_types
#
#  active            :boolean          default(FALSE)
#  created_at        :datetime         default(Wed, 06 Jul 2022 12:00:00 UTC +00:00), not null
#  default           :boolean          default(FALSE)
#  document_link     :string
#  id                :bigint(8)        not null, primary key
#  short_description :text
#  title             :text
#  updated_at        :datetime         default(Wed, 06 Jul 2022 12:00:00 UTC +00:00), not null
#

class ProgrammeType < ApplicationRecord
  extend Mobility
  include TransifexSerialisable
  translates :title, type: :string, fallbacks: { cy: :en }
  translates :short_description, type: :string, fallbacks: { cy: :en }
  translates :description, backend: :action_text

  has_one_attached :image
  has_many :programme_type_activity_types
  has_many :activity_types, through: :programme_type_activity_types

  has_many :programmes

  scope :active, -> { where(active: true) }
  scope :default, -> { where(default: true) }
  scope :by_title, -> { i18n.order(title: :asc) }

  scope :default_first, -> { order(default: :desc) }
  scope :featured, -> { active.default_first.by_title }

  validates_presence_of :title

  validates_uniqueness_of :default, if: :default

  accepts_nested_attributes_for :programme_type_activity_types, reject_if: proc {|attributes| attributes['position'].blank? }

  def activity_types_by_position
    programme_type_activity_types.order(:position).map(&:activity_type)
  end

  def programme_for_school(school)
    programmes.where(school: school).last
  end

  def activity_of_type_for_school(school, activity_type)
    if (programme = programme_for_school(school))
      programme.activity_of_type(activity_type)
    end
  end

  def update_activity_type_positions!(position_attributes)
    transaction do
      programme_type_activity_types.destroy_all
      update!(programme_type_activity_types_attributes: position_attributes)
    end
  end

  def activity_types_and_school_activity(school)
    programme_type_activity_types.order(:position).map do |programme_type_activity_type|
      activity = school.activities.find_by(activity_type_id: programme_type_activity_type.activity_type_id)
      [programme_type_activity_type.activity_type, activity]
    end
  end

  def self.tx_resources
    active.order(:id)
  end
end
