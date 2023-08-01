class AddBonusScoreToProgrammeType < ActiveRecord::Migration[6.0]
  def change
    add_column :programme_types, :bonus_score, :integer, default: 0
  end
end
