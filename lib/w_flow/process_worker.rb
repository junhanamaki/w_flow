module WFlow
  class ProcessWorker
    def initialize(process_class)
      @process_class = process_class
    end

    def run_as_main(flow)
      setup(flow)

      process_report = Supervisor.supervise { run }

      report = Supervisor.supervise do
        if process_report.failed?
          flow.set_failure_and_log(process_report.message)
          rollback
        end

        finalize
      end

      raise InvalidOperation, INVALID_OPERATION unless report.success?
    end

    def run_as_child(flow)
      setup(flow)

      run
    end

    def finalize
      @executed_nodes.reverse_each(&:finalize)

      @process.finalize if @setup_completed
    end

    def rollback
      @executed_nodes.reverse_each(&:rollback)

      @process.rollback if @perform_completed
    end

  protected

    def setup(flow)
      @flow    = flow
      @process = @process_class.new(flow)

      @executed_nodes    = []
      @setup_completed   = false
      @perform_completed = false
    end

    def run
      @process.setup
      @setup_completed = true

      @process_class.wflow_nodes.each do |node_class|
        node_worker = NodeWorker.new(@process, node_class)

        next unless node_worker.execute?

        @executed_nodes << node_worker

        report = node_worker.run(@flow)
      end

      @process.perform
      @perform_completed = true
    end

  end
end