require_relative './anonymizer'

module Anonymous
  # This module handles anonymization for ActiveRecord models. In order to
  # impliment this module you must define a private #anonymization_definitions
  # method in your model.
  #
  # Retry Functionality:
  # When the model update fails because of an ActiveRecord::RecordNotUnique
  # exception the module will retry the update. This is in the event that the
  # anonymization_definitions randomly produce values that violate a unique
  # constraint in the database.
  module ActiveRecord
    def anonymize!
      anonymizer = Anonymizer.new(attributes, anonymization_definitions)
      update_attributes!(anonymizer.anonymized_attributes)
    rescue ::ActiveRecord::RecordNotUnique => e
      @anonymization_attempts ||= 0
      max_retries = Anonymous.configuration.max_anonymize_retries
      raise e if @anonymization_attempts >= max_retries

      @anonymization_attempts += 1
      retry
    end

    def anonymize
      anonymizer = Anonymizer.new(attributes, anonymization_definitions)
      update_attributes(anonymizer.anonymized_attributes)
    rescue ::ActiveRecord::RecordNotUnique => e
      @anonymization_attempts ||= 0
      max_retries = Anonymous.configuration.max_anonymize_retries
      raise e if @anonymization_attempts >= max_retries

      @anonymization_attempts += 1
      retry
    end
  end
end
