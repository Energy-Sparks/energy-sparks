class CreateHeatingComingOnTooEarly < ActiveRecord::Migration[6.1]
  def change
    create_view :heating_coming_on_too_early
  end
end
