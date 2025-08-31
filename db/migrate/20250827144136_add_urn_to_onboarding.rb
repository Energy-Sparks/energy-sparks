class AddUrnToOnboarding < ActiveRecord::Migration[7.2]
  def change
    add_column :school_onboardings, :urn, :int
  end
end
