module CsvExportable
  extend ActiveSupport::Concern

  class_methods do
    def csv_attributes
      []
    end

    def csv_headers
      csv_attributes.map do |attr|
        (attr, relation) = attr.split('.').reverse
        if relation
          klass = reflections[relation].klass
          "#{klass.model_name.human} #{klass.human_attribute_name(attr).downcase}"
        else
          human_attribute_name(attr)
        end
      end
    end

    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << csv_headers
        all.find_each do |record|
          csv << csv_attributes.map { |attr| attr.split('.').inject(record, :try) }
        end
      end
    end
  end
end
