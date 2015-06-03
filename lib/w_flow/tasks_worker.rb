module WFlow
  class TasksWorker

    def initialize(owner_node, tasks)
      @owner_node = owner_node
      @tasks      = tasks
    end

    def run(flow, options = {})
      @executed_tasks = []
      @options        = options

      @tasks.each do |task|
        report = Supervisor.supervise do
          if task.is_a?(Class) && task <= Process
            process_worker = ProcessWorker.new(task)

            @executed_tasks << process_worker

            process_worker.run_as_child(flow)
          else
            @owner_node.process_eval(task)
          end
        end

        if report.failed?
          rollback
          finalize

          @executed_tasks.clear

          if signal_failure?
            Supervisor.resignal!(report)
          else
            flow.log_failure(report.message)
            return
          end
        else
          Supervisor.resignal!(report) if report.stopped? && signal_stop?
        end
      end
    end

    def finalize
      executed_do(:finalize)
    end

    def rollback
      executed_do(:rollback)
    end

  protected

    def signal_failure?
      @options[:failure].nil? || @options[:failure].call
    end

    def signal_stop?
      @options[:stop].nil? || @options[:stop].call
    end

    def executed_do(order)
      @executed_tasks.reverse_each(&order)
    end

  end
end