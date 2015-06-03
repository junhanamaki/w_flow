module WFlow
  class NodeWorker
    def initialize(process, node_class)
      @process = process
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
      @executed_task_groups = []

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

        @executed_task_groups.clear

        if cancel_failure?
          @flow.log_failure(report.message)
        else
          Supervisor.resignal!(report)
        end
      elsif report.stopped? && !cancel_stop?
        Supervisor.resignal!(report)
      end
    end

    def finalize
      executed_groups_do(:finalize)
    end

    def rollback
      executed_groups_do(:rollback)
    end

  protected

    def execute_tasks(options = {})
      executed_task_group = []

      @tasks.each do |task|
        report = Supervisor.supervise do
          if task.is_a?(Class) && task <= Process
            process_worker = ProcessWorker.new(task)

            executed_task_group << process_worker

            process_worker.run_as_child(@flow)
          else
            process_eval(task)
          end
        end

        if report.failed?
          executed_task_group.reverse_each(&:rollback)
          executed_task_group.reverse_each(&:finalize)

          if options[:failure].nil? || options[:failure].call
            Supervisor.resignal!(report)
          else
            @flow.log_failure(report.message)
            return
          end
        else
          if report.stopped? && (options[:stop].nil? || !options[:stop].call)
            @executed_task_groups << executed_task_group
            Supervisor.resignal!(report)
          end
        end
      end

      @executed_task_groups << executed_task_group
    end

    def process_eval(object, *args)
      if object.is_a?(String) || object.is_a?(Symbol)
        @process.send(object.to_s, *args)
      elsif object.is_a?(Proc)
        @process.instance_exec(*args, &object)
      else
        raise InvalidArguments, UNKNOWN_EXPRESSION
      end
    end

    def cancel_stop?
      !@confirm_stop.nil? && !process_eval(@confirm_stop)
    end

    def cancel_failure?
      !@confirm_failure.nil? && !process_eval(@confirm_failure)
    end

    def executed_groups_do(order)
      @executed_task_groups.reverse_each do |executed_task_group|
        executed_task_group.reverse_each(&order)
      end
    end
  end
end