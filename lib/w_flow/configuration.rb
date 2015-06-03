module WFlow
  class Configuration

    attr_reader :supress_errors

    class << self
      def config
        yield configuration
      end

      def supress_errors?
        configuration.supress_errors
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
      @supress_errors = false
    end

  end
end