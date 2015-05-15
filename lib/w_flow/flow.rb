module WFlow
  class Flow
    attr_reader :data, :failure_message

    def initialize(data)
      @data            = Data.new(data)
      @executed        = []
      @failed          = false
      @failure_message = nil
    end

    def success?
      !failure?
    end

    def failure?
      @failed
    end

    def failure!(message = nil)
      @failed          = true
      @failure_message = message

      raise FlowFailure
    end

    def stop!
      throw :stop, true
    end

    def skip!
      throw :skip, true
    end

    def execute!(element)

    end
  end
end