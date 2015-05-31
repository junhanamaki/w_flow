module WFlow
  class Workflow

    attr_reader :failure_log

    def initialize(main_process_class)
      @main_process_class = main_process_class
    end

    def run(params)
      @flow = Flow.new(Data.new(params))

      @backlog       = []
      @finalizables  = []
      @rollbackables = []

      @failure     = false
      @failure_log = []

      process = @main_process_class.new(@flow)

      result = Supervisor.supervise { execute_process(process) }

      set_and_log_failure(result.message) if result.failed?

      result = Supervisor.supervise do
        @rollbackables.each(&:rollback) if failure?
        @finalizables.each(&:finalize)
      end

      raise InvalidOperation, INVALID_OPERATION unless result.success?

      WorkflowReport.new(self, @flow)
    rescue StandardError
      raise
    rescue ::StandardError => e
      raise unless Configuration.supress_errors?

      set_and_log_failure(message: e.message, backtrace: e.backtrace)

      WorkflowReport.new(self, @flow)
    end

    def success?
      !failure?
    end

    def failure?
      @failure
    end

  protected

    def execute_process(process)
      process.setup

      @finalizables.unshift(process)

      process.wflow_for_each_active_nodes do |node|
        result = Supervisor.supervise { execute_node(process, node) }

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

    def execute_node(process, node)
      if node.around_handler.nil?
        node.components.each do |component|
          if component.is_a?(Class) && component <= Process
            execute_process(component.new(@flow))
          else
            process.wflow_eval(component)
          end
        end
      end
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