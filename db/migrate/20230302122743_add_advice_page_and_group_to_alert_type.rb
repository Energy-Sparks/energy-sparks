class AddAdvicePageAndGroupToAlertType < ActiveRecord::Migration[6.0]
  def change
    add_reference :alert_types, :advice_page, index: true
    add_column :alert_types, :group, :integer, default: 0, null: false
  end
end
