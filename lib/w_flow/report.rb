module WFlow
  class Report
    attr_reader :data

    def initialize(data, failure, message)
      @data    = data
      @failure = failure
      @message = message
    end

    def success?; !failure?; end
    def failure?; @failure;  end
  end
end