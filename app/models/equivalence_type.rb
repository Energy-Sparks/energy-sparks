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

  enum meter_type: [:electricity, :gas]
  enum time_period: {
    last_week: 10,
    last_school_week: 15,
    last_work_week: 16,
    last_month: 20,
    last_year: 30,
    last_academic_year: 31
  }

  enum image_name: [:no_image, :petrol_car, :electric_car, :meal, :solar_panel, :books, :electric_shower, :house, :kettle, :phone, :pizza, :roast_meal, :television, :tree, :video_game, :offshore_wind_turbine, :onshore_wind_turbine, :gas_shower, :solar_panel_bw, :electric_car_bw, :meal_bw]

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

  def show_image?
    image_name.to_sym != :no_image
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
