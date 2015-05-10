module WFlow
  class Flow
    attr_reader :data, :failure_message

    def initialize(data = {})
      @data    = Data.new(data)
      @failure = false
      @failure_message = nil
    end

    def success?
      !failure?
    end

    def failure?
      @failure
    end

    def failure!(message = nil)
      @failure = true
      @failure_message = message
    end

    def stop!
      throw :stop
    end

    def skip!
      throw :skip
    end
  end
end