class AddLocalAuthorityAreaToSchools < ActiveRecord::Migration[6.0]
  def change
    add_reference :schools, :local_authority_area, index: true
  end
end
