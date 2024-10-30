class SearchController < ApplicationController
  protect_from_forgery except: :by_letter

  before_action :set_scope

  def by_letter
    @letter = search_params.fetch(:letter)
    @results = @scope.by_letter(@letter).by_name
    @count = @results.count
    respond_to(&:js)
  end

  def by_keyword
    @keyword = search_params.fetch(:keyword)
    @results = @scope.by_keyword(@keyword).by_name
    @count = @results.count
    respond_to(&:js)
  end

  private

  def set_scope
    @tab = SchoolSearchComponent.sanitize_tab(search_params.fetch(:scope).to_sym)
    @scope = if @tab == :schools
               current_user_admin? ? School.active : School.visible
             else
               SchoolGroup.all
             end
  end

  def search_params
    params.permit(:letter, :keyword, :scope).with_defaults(letter: 'A', scope: SchoolSearchComponent::DEFAULT_TAB)
  end
end
