module WFlow
  class Workflow

    attr_reader :data, :flow, :failure_log

    def initialize(process_class)
      @process_class = process_class
    end

    def run(params)
      @data          = Data.new(params)
      @flow          = Flow.new(@data)
      @failure       = false
      @failure_log   = []
      process_worker = ProcessWorker.new(@process_class)

      process_worker.run(self)

      report = Supervisor.supervise do
        if process_worker.failed?
          set_failure_and_log(process_worker.message)
          process_worker.rollback
        end

        process_worker.finalize
      end

      raise InvalidOperation, INVALID_OPERATION unless report.success?

      WorkflowReport.new(self)
    rescue StandardError
      raise
    rescue ::StandardError => e
      raise unless Configuration.supress_errors?

      set_failure_and_log(message: e.message, backtrace: e.backtrace)

      WorkflowReport.new(self)
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

  protected

    def set_failure_and_log(message)
      @failure = true
      log_failure(message)
    end

  end
end