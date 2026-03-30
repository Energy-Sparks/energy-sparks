# frozen_string_literal: true

module Deletable
  extend ActiveSupport::Concern

  included do
    before_destroy :prevent_destroy_unless_deletable
  end

  # Should be overriden by importing class to define specific rules
  def deletable?
    false
  end

  private

  def destroy_error_message
    'Record is not deletable'
  end

  def prevent_destroy_unless_deletable
    return if deletable?

    errors.add(:base, destroy_error_message)
    throw :abort
  end
end
