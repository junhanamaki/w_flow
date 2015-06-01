module WFlow
  class Flow

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def skip!
      Supervisor.signal_skip!
    end

    def stop!
      Supervisor.signal_stop!
    end

    def failure!(message = nil)
      Supervisor.signal_failure!(message)
    end

  end
end