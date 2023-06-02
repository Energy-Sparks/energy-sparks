# == Schema Information
#
# Table name: scoreboards
#
#  academic_year_calendar_id :bigint(8)
#  created_at                :datetime         not null
#  description               :string
#  id                        :bigint(8)        not null, primary key
#  name                      :string           not null
#  public                    :boolean          default(TRUE)
#  slug                      :string           not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_scoreboards_on_academic_year_calendar_id  (academic_year_calendar_id)
#
# Foreign Keys
#
#  fk_rails_...  (academic_year_calendar_id => calendars.id) ON DELETE => nullify
#

class Scoreboard < ApplicationRecord
  extend Mobility
  include TransifexSerialisable
  include Scorable

  translates :name, type: :string, fallbacks: { cy: :en }
  before_save :update_name
  extend FriendlyId

  scope :is_public, -> { where(public: true) }

  FIRST_YEAR = 2018

  friendly_id :name_en, use: [:finders, :slugged, :history]

  has_many :schools
  belongs_to :academic_year_calendar, class_name: 'Calendar', optional: true

  validates :name_en, :academic_year_calendar_id, presence: true

  def safe_destroy
    raise EnergySparks::SafeDestroyError, 'Scoreboard has associated schools' if schools.any?
    destroy
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def current_academic_year(today: Time.zone.today)
    academic_year_calendar.academic_year_for(today)
  end

  def previous_academic_year(today: Time.zone.today)
    academic_year_calendar.academic_year_for(today).previous_year
  end

  private

  def update_name
    self[:name] = self.name_en
  end

  def this_academic_year
    academic_year_calendar.academic_year_for(Time.zone.today)
  end
end
