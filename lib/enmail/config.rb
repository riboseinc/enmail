require "enmail/configuration"

module EnMail
  module Config
    def configure
      if block_given?
        yield configuration
      end
    end

    def configuration
      @configuration ||= EnMail::Configuration.new
    end
  end

  # Expose config module methods as class level method, so we can
  # use those method whenever necessary. Specially `configuration`
  # throughout the gem
  #
  extend Config
end
