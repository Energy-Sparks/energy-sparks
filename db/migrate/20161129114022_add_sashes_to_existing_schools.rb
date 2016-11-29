class AddSashesToExistingSchools < ActiveRecord::Migration[5.0]
  def change
    School.all.each(&:badges)
  end
end
