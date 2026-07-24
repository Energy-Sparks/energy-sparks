# frozen_string_literal: true

module RecordingFilterable
  extend ActiveSupport::Concern

  included do
    helper_method :filter_params
  end

  FILTERS = {
    school_group: :for_school_group,
    admin: :for_admin,
    school: :for_school,
    user_role: :for_user_role
  }.freeze

  private_constant :FILTERS

  private

  def apply_filters(scope)
    FILTERS.reduce(scope) do |filtered_scope, (param, filter_scope)|
      value = filter_params[param]
      value.present? ? filtered_scope.public_send(filter_scope, value) : filtered_scope
    end
  end

  def filter_params
    params.permit(*FILTERS.keys)
  end
end
