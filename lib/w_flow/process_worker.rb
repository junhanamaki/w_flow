module WFlow
  class ProcessWorker
    extend Forwardable
    def_delegators :@report, :message, :success?, :skipped?, :stopped?, :failed?

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

      @report = Supervisor.supervise do
        process.setup
        @setup_completed = true

        @process.wflow_for_each_active_nodes do |node_class|
          node_worker = NodeWorker.new(node_class)

          node_worker.run(workflow)

          @node_workers << node_worker if node_worker.success?
        end

        process.perform
        @perform_completed = true
      end
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