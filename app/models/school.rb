# == Schema Information
#
# Table name: schools
#
#  address           :text
#  calendar_id       :integer
#  created_at        :datetime         not null
#  eco_school_status :integer
#  enrolled          :boolean          default(FALSE)
#  id                :integer          not null, primary key
#  level             :integer          default(0)
#  name              :string
#  postcode          :string
#  sash_id           :integer
#  school_type       :integer
#  updated_at        :datetime         not null
#  urn               :integer          not null
#  website           :string
#
# Indexes
#
#  index_schools_on_calendar_id  (calendar_id)
#  index_schools_on_urn          (urn) UNIQUE
#
# Foreign Keys
#
#  fk_rails_379253fa8b  (calendar_id => calendars.id)
#

class School < ApplicationRecord
  include Usage
  has_merit

  has_many :users, dependent: :destroy
  has_many :meters, inverse_of: :school, dependent: :destroy
  has_many :activities, inverse_of: :school, dependent: :destroy
  has_many :meter_readings, through: :meters
  belongs_to :calendar

  enum school_type: [:primary, :secondary]
  enum eco_school_status: [:bronze, :silver, :green]

  scope :enrolled, -> { where(enrolled: true) }

  validates_presence_of :urn, :name
  validates_uniqueness_of :urn
  accepts_nested_attributes_for :meters, reject_if: proc { |attributes| attributes[:meter_no].blank? }

  after_create :create_sash_relation

  def meters?(supply = nil)
    self.meters.where(meter_type: supply).any?
  end

  # Retrieve badges by date awarded
  def badges_by_date(order: :desc, limit: nil)
    sash.badges_sashes.order(created_at: order)
      .limit(limit)
      .map(&:badge)
  end

  def self.top_scored(options = {})
    options[:since_date] ||= 1.month.ago

    School.select(:id, :name, 'SUM(num_points) AS sum_points')
      .joins('left join merit_scores ON merit_scores.sash_id = schools.sash_id')
      .joins('left join merit_score_points ON merit_score_points.score_id = merit_scores.id')
      .where('merit_score_points.created_at > ?', options[:since_date])
      .order('sum_points DESC')
      .group('schools.id, merit_scores.sash_id')
      .limit(options[:limit])
  end

  private

  # Create Merit::Sash relation
  # Having the sash relation makes life easier elsewhere
  def create_sash_relation
    badges
  end
end
