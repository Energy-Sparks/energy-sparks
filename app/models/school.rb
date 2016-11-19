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
#  slug              :string
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
  extend FriendlyId
  friendly_id :slug_candidates, use: [:finders, :slugged, :history]
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

  def meters?(supply = nil)
    self.meters.where(meter_type: supply).any?
  end

private

  # Create Merit::Sash relation
  # Having the sash relation makes life easier elsewhere
  def create_sash_relation
    badges
  end
end
