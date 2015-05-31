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

    def run(workflow)
      init_state(workflow.flow)

      @process.setup
      @setup_completed = true

      @process.wflow_for_each_active_nodes do |node_class|
        node_worker = NodeWorker.new(node_class)

        report = Supervisor.supervise { node_worker.run(workflow) }

        if report.failed?
          node_worker.rollback
          node_worker.finalize

          Supervisor.resignal!(report) unless node_worker.cancel_failure?
        else
          @node_workers << node_worker

          if report.stopped? && !node_worker.cancel_stop?
            Supervisor.resignal!(report)
          end
        end
      end

      @process.perform
      @perform_completed = true
    end

    def finalize
      @node_workers.reverse_each(&:finalize)

      @process.finalize
    end

    def rollback
      @node_workers.reverse_each(&:rollback)

      @process.rollback
    end

  end
end