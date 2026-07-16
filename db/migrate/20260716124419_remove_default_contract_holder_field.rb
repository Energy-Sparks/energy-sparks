# frozen_string_literal: true

class RemoveDefaultContractHolderField < ActiveRecord::Migration[8.1]
  def change
    remove_column :schools, :default_contract_holder_id, :bigint
    remove_column :schools, :default_contract_holder_type, :string
  end
end
