class AddSlugToSchools < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :slug, :string, index: true

    # Save will prompt a new slug to be built
    School.find_each(&:save)
  end
end
