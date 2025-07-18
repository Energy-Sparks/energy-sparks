# == Schema Information
#
# Table name: transport_surveys
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  run_on     :date             not null
#  school_id  :bigint(8)        not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_transport_surveys_on_school_id             (school_id)
#  index_transport_surveys_on_school_id_and_run_on  (school_id,run_on) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#
class TransportSurvey < ApplicationRecord
  belongs_to :school
  has_many :responses, inverse_of: :transport_survey
  has_many :observations, as: :observable, dependent: :destroy

  validates :run_on, :school_id, presence: true
  validates :run_on, uniqueness: { scope: :school_id }

  scope :recently_added, ->(date_range) { where(created_at: date_range)}

  def to_param
    run_on.to_s
  end

  def total_responses
    self.responses.count
  end

  def total_carbon
    self.responses.sum(&:carbon)
  end

  def today?
    run_on == Time.zone.today
  end

  def responses_per_category
    responses_per_cat = responses.with_transport_type.group(:category).count
    # also include counts of zero for categories without responses
    TransportSurvey::TransportType.categories_with_other.transform_values { |v| responses_per_cat[v] || 0 }
  end

  def percentage_per_category
    responses_per_category.transform_values { |v| v == 0 ? 0 : (v.to_f / total_responses * 100) }
  end

  def responses_per_time_for_category(category)
    responses_per_time = responses.with_transport_type.where(transport_types: { category: category }).group(:journey_minutes).count
    # also include counts of zero for times without responses
    TransportSurvey::Response.journey_minutes_options.index_with { |mins| responses_per_time[mins] || 0 }
  end

  def responses_per_time_for_category_car
    results, thirty_plus = responses_per_time_for_category(:car).partition { |mins, _count| mins < 30 }.map(&:to_h)
    results['30+'] = thirty_plus.values.sum || 0
    results
  end

  def pie_chart_data
    percentage_per_category.collect { |k, v| { name: TransportSurvey::TransportType.human_enum_name(:category, k), y: v } }
  end

  def self.equivalence_images
    { tree: '🌳', tv: '📺', computer_console: '🎮', smartphone: '📱', carnivore_dinner: '🍲', vegetarian_dinner: '🥗' }
  end

  def self.equivalence_svgs
    { tree: 'tree', tv: 'television', computer_console: 'video_game', smartphone: 'phone', carnivore_dinner: 'roast_meal', vegetarian_dinner: 'meal', neutral: 'tree' }
  end

  def self.equivalence_devisors
    { tree: 365 }
  end

  def self.equivalences
    equivalence_images.collect do |name, image|
      { rate: EnergyEquivalences.all_equivalences[name][:conversions][:co2][:rate] / (equivalence_devisors[name] || 1),
        statement: I18n.t(name, scope: 'schools.transport_surveys.equivalences'),
        image: image,
        name: name }
    end
  end

  def equivalences
    if total_carbon == 0
      return [{ statement: I18n.t('schools.transport_surveys.equivalences.neutral'), svg: self.class.equivalence_svgs[:neutral] }]
    else
      self.class.equivalences.collect do |equivalence|
        amount = (total_carbon / equivalence[:rate]).round
        if amount > 0
          { statement: I18n.t(equivalence[:name], scope: 'schools.transport_surveys.equivalences', image: equivalence[:image], count: amount),
            svg: self.class.equivalence_svgs[equivalence[:name]] }
        end
      end.compact.shuffle
    end
  end

  def responses=(responses_attributes)
    responses_attributes.each do |response_attributes|
      responses.create_with(response_attributes).find_or_create_by(response_attributes.slice(:run_identifier, :surveyed_at))
    end
    add_observation
  end

  def add_observation
    return unless responses.any?
    return if observations.transport_survey.any? # only one observation permitted per survey day

    observations.transport_survey.create!(at: run_on)
  end
end
