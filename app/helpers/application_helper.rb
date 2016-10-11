module ApplicationHelper
  def active(bool = true)
    bool ? '' : 'bg-warning'
  end
end
