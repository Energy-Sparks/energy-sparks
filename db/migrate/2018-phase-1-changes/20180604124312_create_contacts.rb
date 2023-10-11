class CreateContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :contacts do |t|
      t.references  :school, foreign_key: true
      t.text        :name
      t.text        :description
      t.text        :email_address
      t.text        :mobile_phone_number
    end
  end
end
