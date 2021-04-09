module NonPublicSchools
  extend ActiveSupport::Concern

private

  def redirect_unless_permitted(permission)
    redirect_to school_private_path(@school) unless can?(permission, @school)
  end
end
