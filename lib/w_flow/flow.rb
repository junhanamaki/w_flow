module WFlow
  class Flow

    attr_reader :data

    def initialize(params)
      @data        = Data.new(params)
      @failure     = false
      @failure_log = []
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

    def success?
      !failure?
    end

    def failure?
      @failure
    end

    def log_failure(message)
      @failure_log << message unless message.nil?
    end

    def set_failure_and_log(message)
      @failure = true
      log_failure(message)
    end

  end
end