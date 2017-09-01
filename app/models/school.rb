# == Schema Information
#
# Table name: schools
#
#  address             :text
#  calendar_id         :integer
#  competition_role    :integer
#  created_at          :datetime         not null
#  electricity_dataset :string
#  enrolled            :boolean          default(FALSE)
#  gas_dataset         :string
#  id                  :integer          not null, primary key
#  level               :integer          default(0)
#  name                :string
#  postcode            :string
#  sash_id             :integer
#  school_type         :integer
#  slug                :string
#  updated_at          :datetime         not null
#  urn                 :integer          not null
#  website             :string
#
# Indexes
#
#  index_schools_on_calendar_id  (calendar_id)
#  index_schools_on_sash_id      (sash_id)
#  index_schools_on_urn          (urn) UNIQUE
#
# Foreign Keys
#
#  fk_rails_379253fa8b  (calendar_id => calendars.id)
#

class School < ApplicationRecord
  include Usage
  extend FriendlyId
  friendly_id :slug_candidates, use: [:finders, :slugged, :history]

  include Merit::UsageCalculations
  has_merit

  has_many :users, dependent: :destroy
  has_many :meters, inverse_of: :school, dependent: :destroy
  has_many :activities, inverse_of: :school, dependent: :destroy
  has_many :meter_readings, through: :meters
  belongs_to :calendar

  enum school_type: [:primary, :secondary, :special, :infant, :junior]
  enum competition_role: [:not_competing, :competitor, :winner]

  scope :enrolled, -> { where(enrolled: true) }

  validates_presence_of :urn, :name
  validates_uniqueness_of :urn
  accepts_nested_attributes_for :meters, reject_if: proc { |attributes| attributes[:meter_no].blank? }

  after_create :create_sash_relation
  after_create :create_calendar

  def should_generate_new_friendly_id?
    slug.blank? || name_changed? || postcode_changed?
  end

  # Prevent the generated urls from becoming too long
  def normalize_friendly_id(string)
    super[0..59]
  end

  # Try building a slug based on the following fields in increasing order of specificity.
  def slug_candidates
    [
      :name,
      [:postcode, :name],
      [:urn, :name]
    ]
  end

  def meters_for_supply(supply)
    self.meters.where(meter_type: supply)
  end

  def meters?(supply = nil)
    self.meters.where(meter_type: supply).any?
  end

  def both_supplies?
    meters?(:electricity) && meters?(:gas)
  end

  def has_badge?(id)
    sash.badge_ids.include?(id)
  end

  def current_term
    calendar.terms.find_by('NOW()::DATE BETWEEN start_date AND end_date')
  end

  def last_term
    calendar.terms.find_by('end_date <= ?', current_term.start_date)
  end

  def badges_by_date(order: :desc, limit: nil)
    sash.badges_sashes.order(created_at: order)
      .limit(limit)
      .map(&:badge)
  end

  def points_since(since = 1.month.ago)
    self.score_points.where("created_at > '#{since}'").sum(:num_points)
  end

  def suggest_activities
    @activity_categories = ActivityCategory.all.order(:name).to_a
  end

  def self.scoreboard
    School.select('schools.*, SUM(num_points) AS sum_points')
        .joins('left join merit_scores ON merit_scores.sash_id = schools.sash_id')
        .joins('left join merit_score_points ON merit_score_points.score_id = merit_scores.id')
        .where("schools.enrolled = true")
        .order('sum_points DESC NULLS LAST')
        .group('schools.id, merit_scores.sash_id')
  end

  def self.top_scored(dates: nil, limit: nil)
    if dates.present?
      start_date = dates.first.beginning_of_day
      end_date = dates.last.end_of_day
    else
      # If no dates are present grab points since the beginning of the academic year
      september = Time.current.beginning_of_month.change(month: 9)
      start_date = september.future? ? september.last_year : september
      end_date = Time.current
    end

    School.select('schools.*, SUM(num_points) AS sum_points')
      .joins('left join merit_scores ON merit_scores.sash_id = schools.sash_id')
      .joins('left join merit_score_points ON merit_score_points.score_id = merit_scores.id')
      .where('merit_score_points.created_at BETWEEN ? AND ?', start_date, end_date)
      .order('sum_points DESC')
      .group('schools.id, merit_scores.sash_id')
      .limit(limit)
  end

private

  def create_calendar
    calendar = Calendar.create_calendar_from_default("#{name} Calendar")
    self.update_attribute(:calendar_id, calendar.id)
  end

  # Create Merit::Sash relation
  # Having the sash relation makes life easier elsewhere
  def create_sash_relation
    badges
  end
end
