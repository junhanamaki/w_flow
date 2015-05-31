module WFlow
  class Workflow

    attr_reader :failure_log

    def initialize(main_process_class)
      @main_process_class = main_process_class

      @backlog       = []
      @finalizables  = []
      @rollbackables = []

      @failure     = false
      @failure_log = []
    end

    def run(params)
      @flow = Flow.new(Data.new(params))

      process = @main_process_class.new(@flow)

      result = execute_process(process)

      set_and_log_failure(result.message) if result.failed?

      finalize_processes
    rescue ::StandardError => e
      raise unless Configuration.supress_errors?

      set_and_log_failure(message: e.message, backtrace: e.backtrace)
    ensure
      return WorkflowReport.new(self, @flow)
    end

    def success?
      !failure?
    end

    def failure?
      @failure
    end

  protected

    def execute_process(process)
      Supervisor.supervise do
        process.setup

        @finalizables.unshift(process)

        process.wflow_for_each_active_nodes do |node|
          result = Supervisor.supervise { execute_node(node) }

          if result.stopped?
            Supervisor.resignal!(result) unless node.cancel_stop?(process)
          elsif result.failed?
            if node.cancel_failure?(process)
              log_failure(false, result.message)
            else
              Supervisor.resignal!(result)
            end
          end
        end

        process.perform

        @rollbackables << process
      end
    end

    def execute_node(node)



      if node.around_handler.nil?
        result = Supervisor.supervise do
        end
      else
      end
    end

    def finalize_processes
      result = Supervisor.supervise do
        @rollbackables.each(&:rollback) if failure?
        @finalizables.each(&:finalize)
      end

      raise InvalidOperation, INVALID_OPERATION unless result.success?
    end

    def log_failure(message)
      @failure_log << message unless message.nil?
    end

    def set_and_log_failure(message)
      @failure = true
      log_failure(message)
    end

  end
end