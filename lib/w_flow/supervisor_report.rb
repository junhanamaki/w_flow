module WFlow
  class SupervisorReport

    attr_reader :key, :message

    def initialize(key = :success, message = nil)
      @key     = key
      @message = message
    end

    def success?
      @key == :success
    end

    def skipped?
      @key == :skip
    end

    def stopped?
      @key == :stop
    end

    def failed?
      @key == :failure
    end

  end
end