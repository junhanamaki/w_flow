module WFlow
  class NodeWorker
    def initialize(owner_process, node_class)
      @owner_process = owner_process
      @tasks   = node_class.tasks

      options  = node_class.options

      @execute_if      = options[:if]
      @execute_unless  = options[:unless]
      @around_proc     = options[:around]
      @confirm_stop    = options[:stop]
      @confirm_failure = options[:failure]
    end

    def execute?
      (@execute_if.nil?     || process_eval(@execute_if)) &&
      (@execute_unless.nil? || !process_eval(@execute_unless))
    end

    def run(flow)
      @flow = flow
      @executed_tasks_workers = []

      report = Supervisor.supervise do
        if @around_proc.nil?
          execute_tasks
        else
          process_eval(@around_proc, method(:execute_tasks))
        end
      end

      if report.failed?
        rollback
        finalize

        @executed_tasks_workers.clear

        if signal_failure?
          Supervisor.resignal!(report)
        else
          @flow.log_failure(report.message)
        end
      elsif report.stopped? && signal_stop?
        Supervisor.resignal!(report)
      end
    end

    def finalize
      executed_do(:finalize)
    end

    def rollback
      executed_do(:rollback)
    end

    def process_eval(object, *args)
      if object.is_a?(String) || object.is_a?(Symbol)
        @owner_process.send(object.to_s, *args)
      elsif object.is_a?(Proc)
        @owner_process.instance_exec(*args, &object)
      else
        raise InvalidArguments, UNKNOWN_EXPRESSION
      end
    end

  protected

    def execute_tasks(options = {})
      tasks_worker = TasksWorker.new(self, @tasks)

      @executed_tasks_workers << tasks_worker

      tasks_worker.run(@flow, options)
    end

    def signal_stop?
      @confirm_stop.nil? || process_eval(@confirm_stop)
    end

    def signal_failure?
      @confirm_failure.nil? || process_eval(@confirm_failure)
    end

    def executed_do(order)
      @executed_tasks_workers.reverse_each(&order)
    end
  end
end