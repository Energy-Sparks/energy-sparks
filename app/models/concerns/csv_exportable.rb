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

    def to_csv(header: true)
      CSV.generate(headers: header) do |csv|
        paths = csv_attributes.map { |a| a.split('.') }

        csv << csv_headers if header == true
        find_each do |record|
          csv << paths.map { |parts| parts.reduce(record) { |obj, m| obj&.public_send(m) } }
        end
      end
    end
  end
end
