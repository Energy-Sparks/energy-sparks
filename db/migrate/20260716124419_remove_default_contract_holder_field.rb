# frozen_string_literal: true

class RemoveDefaultContractHolderField < ActiveRecord::Migration[8.1]
  def change
    reversible do |dir|
      dir.up do
        change_table :schools, bulk: true do |t|
          t.remove :default_contract_holder_id
          t.remove :default_contract_holder_type
        end
      end

      dir.down do
        change_table :schools, bulk: true do |t|
          t.column :default_contract_holder_id, :bigint
          t.column :default_contract_holder_type, :string
        end
      end
    end
  end
end
