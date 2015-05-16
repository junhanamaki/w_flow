module WFlow
  class Configuration
    def raise_errors?
      @raise_errors
    end

    class << self
      def config
        yield configuration
      end

      def configuration
        @configuration ||= new
      end

      def reset_configuration
        @configuration = new
      end
    end

  protected

    def initialize
      @raise_errors = false
    end
  end
end