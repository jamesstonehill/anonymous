require "anonymous/version"
require "anonymous/configuration"
require "anonymous/anonymizer"
require "anonymous/active_record" if defined? ::ActiveRecord

module Anonymous
  def configure
    yield configuration
  end

  def configuration
    @configuration ||= Configuration.new
  end

  module_function :configure, :configuration
end
