# frozen_string_literal: true

module TaskCategory
  extend ActiveSupport::Concern

  def tasks
    raise NoMethodError, 'Implement in including class!'
  end
end
