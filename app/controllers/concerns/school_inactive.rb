# frozen_string_literal: true

module SchoolInactive
  extend ActiveSupport::Concern

  private

  def school_inactive
    render '/schools/inactive', status: :gone unless @school.active
  end
end
