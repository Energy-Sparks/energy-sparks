# frozen_string_literal: true

module ActivityInterventionFilterable
  extend ActiveSupport::Concern

  private

  def apply_filters(scope)
    {
      for_school_group: params[:school_group],
      for_admin: params[:admin],
      for_school: params[:school],
      for_user_role: params[:user_role]
    }.reduce(scope) do |filtered_scope, (method, param)|
      param.present? ? filtered_scope.public_send(method, param) : filtered_scope
    end
  end
end
