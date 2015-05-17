module WFlow
  class Report
    def initialize
      @failure = false
      @message = nil
    end

    def register_failure(message)
      @failure = true
      @message = message
    end

    def success?
      !failure?
    end

    def failure?
      @failure
    end
  end
end