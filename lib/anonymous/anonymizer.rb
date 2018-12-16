module Anonymous
  class Anonymizer
    attr_reader :anonymization_definitions

    def initialize(attributes, anonymization_definitions)
      @attributes = symbolize_keys(attributes)
      @anonymization_definitions = symbolize_keys(anonymization_definitions)
      @anonymization_attempts = 0
    end

    def anonymized_attributes
      attributes_to_anonymise = non_nil_attributes

      attributes_to_anonymise.each_with_object({}) do |(attr_name, value), result|
        anonymization_definition = anonymization_definitions.fetch(attr_name)

        if anonymization_definition.respond_to?(:call)
          result[attr_name] = anonymization_definition.call(value)
        else
          result[attr_name] = anonymization_definition
        end
      end
    end

    private

    attr_reader :attributes

    def non_nil_attributes
      @non_nil_attributes ||= attributes.select do |attr_name, value|
        !value.nil? && anonymization_definitions[attr_name]
      end
    end

    def symbolize_keys(hash)
      hash.each_with_object({}) do |(key, value), obj|
        key = key.to_sym rescue key
        obj[key] = value
      end
    end
  end
end
