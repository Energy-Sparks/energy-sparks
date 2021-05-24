class SchoolRemover
  class Error < StandardError; end

  def initialize(school)
    @school = school
  end

  def can_remove_school?
    return false unless @school.active?
    return false if @school.visible?
    # return false if @school.meters.any?(&:active)
    true
  end

  def remove_school!
    raise SchoolRemover::Error.new('Cannot remove school while it is still visible') if @school.visible?
    @school.transaction do
      @school.update(active: false, process_data: false, removal_date: Time.zone.today)
    end
  end

  def remove_meters!
    raise SchoolRemover::Error.new('Cannot remove meters while school is still visible') if @school.visible?
    @school.transaction do
      @school.meters.each do |meter|
        service = MeterManagement.new(meter)
        service.deactivate_meter!
        service.remove_data!
      end
      # deactivate all meters and remove tariffs and data
    end
  end
end
