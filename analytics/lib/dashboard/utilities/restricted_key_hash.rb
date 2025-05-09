class RestrictedKeyHash < Hash
  def self.instance
    new.merge!(unique_keys.map { |k| [k, nil] }.to_h)
  end

  def self.unique_keys
    %i[]
  end

  def [](type)
    raise EnergySparksUnexpectedStateException, "Unknown #{self.class.name} type #{type}" unless self.class.unique_keys.include?(type)
    super(type)
  end
end
