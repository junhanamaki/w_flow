module WFlow
  class Report
    attr_reader :data

    def initialize(data)
      @failure = false
      @message = nil
      @data    = data
    end

    def failure!(message)
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