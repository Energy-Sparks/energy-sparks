class AddEstablishmentReferenceToSchools < ActiveRecord::Migration[7.2]
  def change
    add_reference :schools, :establishment
  end
end
