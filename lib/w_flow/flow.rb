module WFlow
  class Flow
    attr_reader :data

    def initialize(data)
      @data = Data.new(data)
    end

    def success?
    end

    def failure?
    end

    def failure!(code, message = nil)
      raise FlowFailure
    end

    def stop!
      throw :stop
    end

    def skip!
      throw :skip
    end
  end
end