# frozen_string_literal: true

# == Schema Information
#
# Table name: countries
#
#  id :bigint(8)        not null, primary key
#
class Country < ApplicationRecord
  extend Mobility

  translates :name, type: :string, fallbacks: { cy: :en }
  translates :abbreviation, type: :string, fallbacks: { cy: :en }
end
