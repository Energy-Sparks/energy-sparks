class MethodRepeater
  attr_reader :targets

  def initialize(targets = [])
    @targets = targets.compact
  end

  def method_missing(method_name, *args)
    if @targets.one?
      send_method_args(@targets.first, method_name, args)
    else
      self.class.new(@targets.map {|t| send_method_args(t, method_name, args)})
    end
  end

  def respond_to_missing?(_method_name, _include_private = false)
    true
  end

  def send_method_args(target, method_name, args)
    if args.empty?
      target.send(method_name)
    else
      target.send(method_name, args)
    end
  end
end
