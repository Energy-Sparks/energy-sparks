# frozen_string_literal: true

module AdminDashboardHelper
  def prompt_cache_timestamp(user)
    user.owned_issues.maximum(:updated_at).to_i
  end

  def sort_link(link, label, column = nil, default_order = :asc)
    return label unless link

    column = (column || label.downcase).to_s
    query = request.query_parameters.merge(sort: column, direction: sort_link_direction(column, default_order),
                                           page: 1)
    link_to "#{label}#{sort_link_arrow(column)}", "#{request.path}?#{query.to_query}"
  end

  private

  def sort_link_direction(column, default_order)
    second_order = default_order == :asc ? :desc : :asc
    params[:sort] == column && params[:direction] == default_order.to_s ? second_order : default_order
  end

  def sort_link_arrow(column)
    return unless params[:sort] == column

    params[:direction] == 'asc' ? ' ↑' : ' ↓'
  end
end
