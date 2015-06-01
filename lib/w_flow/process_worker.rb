module WFlow
  class ProcessWorker

    def initialize(process_class)
      @process_class = process_class
    end

    def init_state(flow)
      @process           = @process_class.new(flow)
      @node_workers      = []
      @setup_completed   = false
      @perform_completed = false
    end

    def run(flow)
      init_state(flow)

      @process.setup
      @setup_completed = true

      @process_class.wflow_nodes.each do |node_class|
        next unless node_class.execute?(@process)

        node_worker = NodeWorker.new(node_class, @process)

        report = Supervisor.supervise { node_worker.run(flow) }

        if report.failed?
          node_worker.rollback
          node_worker.finalize

          if node_class.cancel_failure?(@process)
            flow.log_failure(report.message)
          else
            binding.pry
            Supervisor.resignal!(report)
          end
        else
          @node_workers << node_worker

          if report.stopped? && !node_class.cancel_stop?(@process)
            Supervisor.resignal!(report)
          end
        end
      end

      @process.perform
      @perform_completed = true
    end

    def finalize
      @node_workers.reverse_each(&:finalize)

      @process.finalize if @setup_completed
    end

    def rollback
      @node_workers.reverse_each(&:rollback)

      @process.rollback if @perform_completed
    end

  end
end