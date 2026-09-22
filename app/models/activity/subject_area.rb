# frozen_string_literal: true

module Activity
  class SubjectArea < ApplicationRecord
    extend Mobility

    include Enums::Country

    translates :name, type: :string, fallbacks: { cy: :en }
  end
end
