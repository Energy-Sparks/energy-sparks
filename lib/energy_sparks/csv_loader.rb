require 'csv'
module EnergySparks
  class CsvLoader
    def self.default_options
      {
        headers: true,
        header_converters: :symbol,
        skip_blanks: true,
        converters: lambda {|f| f ? f.strip : nil}
      }
    end

    def self.from_text(csv, options = {})
      process(CSV.parse(csv, **default_options.merge(options)))
    end

    def self.process(rows)
      rows.reject {|row| row.fields.all?(&:nil?) }
    end
  end
end
