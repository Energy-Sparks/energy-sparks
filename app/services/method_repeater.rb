class MethodRepeater
  def initialize(targets = [])
    @targets = targets.compact
  end

  def method_missing(method_name, *_args)
    self.class.new(@targets.map {|t| t.send(method_name)})
  end

  def respond_to_missing?(_method_name, _include_private = false)
    true
  end
end
