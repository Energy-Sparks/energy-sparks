class CreateEstablishments < ActiveRecord::Migration[7.2]
  def change
    create_table(:lists_establishments) do |t|
      t.integer   :la_code
      t.integer   :establishment_number
      t.string    :establishment_name
      t.integer   :establishment_status_code
      t.string    :postcode
      t.string    :school_website
      t.integer   :type_of_establishment_code
      t.string    :uprn
      t.integer   :number_of_pupils
      t.string    :percentage_fsm
      t.datetime  :last_changed_date

      t.timestamps
    end
  end
end
