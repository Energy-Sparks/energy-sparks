class SearchController < ApplicationController
  protect_from_forgery except: :by_letter

  def by_letter
    @letter = search_params.fetch(:letter)
    @schools = scope.where('substr(upper(name), 1, 1) = ?', @letter).order(:name)
    @count = @schools.count
    respond_to(&:js)
  end

  def by_keyword
    @keyword = search_params.fetch(:keyword)
    @schools = scope.where('name LIKE ?', "%#{@keyword}%").order(:name) # TODO
    @count = @schools.count
    respond_to(&:js)
  end

  private

  def scope
    School.active # TODO
  end

  def search_params
    params.permit(:letter, :keyword).with_defaults(letter: 'A')
  end
end
