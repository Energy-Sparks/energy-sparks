# frozen_string_literal: true

module Activity
  class Duration < ApplicationRecord
    extend Mobility

    translates :name, type: :string, fallbacks: { cy: :en }
  end
end
