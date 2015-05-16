module WFlow
  class Flow
    attr_reader :data

    def initialize(data)
      @data = Data.new(data)
      reset_state
    end

    def start(process_class)
      @worker = Worker.new(self)
      @worker.start(process_class)
    end

    def success?
      !failure?
    end

    def failure?
      @failure[:state]
    end

    def failure!(message = nil, options = {})
      @failure = { state: true, message: message }

      raise FlowFailure unless !!options[:silent]
    end

    def reset_state
      @failure = { state: false, message: nil }
    end

    def stop!
      throw :stop, true
    end

    def skip!
      throw :skip, true
    end

    def failure_message
      @failure[:message]
    end

    def execute!(component)
      @worker.execute_component(component)
    end
  end
end