class CreateAlertsContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :alerts_contacts, id: false do |t|
      t.belongs_to :contact,  index: true
      t.belongs_to :alert,    index: true
    end
  end
end
