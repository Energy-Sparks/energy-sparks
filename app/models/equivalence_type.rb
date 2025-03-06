# == Schema Information
#
# Table name: equivalence_types
#
#  created_at  :datetime         not null
#  id          :bigint(8)        not null, primary key
#  image_name  :integer          default("no_image"), not null
#  meter_type  :integer          not null
#  time_period :integer          not null
#  updated_at  :datetime         not null
#

class EquivalenceType < ApplicationRecord
  has_many :content_versions, class_name: 'EquivalenceTypeContentVersion'

  enum :meter_type, { electricity: 0, gas: 1, solar_pv: 2, storage_heaters: 3 }
  enum :time_period, {
    last_week: 10,
    last_school_week: 15,
    last_work_week: 16,
    last_month: 20,
    last_year: 30,
    last_academic_year: 31
  }

  enum :image_name, { no_image: 0, petrol_car: 1, electric_car: 2, meal: 3, solar_panel: 4, books: 5,
                      electric_shower: 6, house: 7, kettle: 8, phone: 9, pizza: 10, roast_meal: 11, television: 12,
                      tree: 13, video_game: 14, offshore_wind_turbine: 15, onshore_wind_turbine: 16, gas_shower: 17,
                      solar_panel_bw: 18, electric_car_bw: 19, meal_bw: 20 }

  validates :meter_type, :time_period, :image_name, presence: true

  def current_content
    content_versions.latest.first
  end

  def update_with_content!(attributes, content)
    to_replace = current_content
    self.attributes = attributes
    if valid? && content.valid?
      save_and_replace(content, to_replace)
      true
    else
      false
    end
  end

  private

  def save_and_replace(content, to_replace)
    transaction do
      save!
      content.save!
      to_replace.update!(replaced_by: content) if to_replace
    end
  end
end
