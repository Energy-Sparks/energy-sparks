class RemoveNullConstraintFromUnitsOnUserTariffCharges < ActiveRecord::Migration[6.0]
  def change
    change_column_null :user_tariff_charges, :units, true
  end
end
