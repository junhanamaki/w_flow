module WFlow
  class Configuration
    def supress_errors?
      @supress_errors
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
      @supress_errors = false
    end
  end
end