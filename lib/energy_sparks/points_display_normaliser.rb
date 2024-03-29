module EnergySparks
  class PointsDisplayNormaliser
    def self.normalise(points)
      points.map!(&:to_i) # turns any nil values to 0

      return points if points.empty?
      range = points.max - points.min
      return Array.new(points.size, 0.5) if range.zero?
      points.map {|point| point / points.max.to_f}
    end
  end
end
