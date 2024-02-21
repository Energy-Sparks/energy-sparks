class CreateBaseloadPerPupils < ActiveRecord::Migration[6.1]
  def change
    create_view :baseload_per_pupils
  end
end
