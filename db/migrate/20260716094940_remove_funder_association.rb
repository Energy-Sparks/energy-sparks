# frozen_string_literal: true

class RemoveFunderAssociation < ActiveRecord::Migration[8.1]
  def change
    remove_reference :schools, :funder, foreign_key: false
    remove_reference :school_onboardings, :funder, foreign_key: false
  end
end
