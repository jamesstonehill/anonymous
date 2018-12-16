module Anonymous
  class Configuration
    DEFAULTS = {
      max_anonymize_retries: 1
    }.freeze

    attr_accessor :max_anonymize_retries

    def initialize
      @max_anonymize_retries = DEFAULTS[:max_anonymize_retries]
    end
  end
end
