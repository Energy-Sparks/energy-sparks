# frozen_string_literal: true

module Commercial
  module LicenceHolder
    extend ActiveSupport::Concern

    included do
      has_many :licences, class_name: 'Commercial::Licence', dependent: :restrict_with_exception
    end
  end
end
