class AddOrganisationTypeToCaseStudies < ActiveRecord::Migration[7.2]
  def change
    add_column :case_studies, :organisation_type, :integer, null: false, default: 0 # enum
  end
end
