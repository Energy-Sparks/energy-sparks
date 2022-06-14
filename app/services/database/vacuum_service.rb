module Database
  class VacuumService
    def initialize(tables)
      @tables = tables
    end

    def perform
      @tables.each do |table|
        ActiveRecord::Base.connection.execute("VACUUM ANALYSE #{table}")
      end
    end
  end
end
