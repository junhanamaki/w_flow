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
      @nodes.reverse_each(&:finalize)

      @process.finalize if @setup_completed
    end

    def rollback
      @nodes.reverse_each(&:rollback)

      @process.rollback if @perform_completed
    end

  protected

    def run
      @process.setup
      @setup_completed = true

      @process_class.wflow_nodes.each do |node_class|
        next unless node_class.execute?(@process)

        node = node_class.new(@process)

        report = node.run(@flow)

        if report.failed?
          node.rollback
          node.finalize

          if node_class.cancel_failure?(@process)
            @flow.log_failure(report.message)
          else
            Supervisor.resignal!(report)
          end
        else
          @nodes << node

          if report.stopped? && !node_class.cancel_stop?(@process)
            Supervisor.resignal!(report)
          end
        end
      end

      @process.perform
      @perform_completed = true
    end

    def setup(flow)
      @flow    = flow
      @process = @process_class.new(flow)
      @nodes   = []
      @setup_completed   = false
      @perform_completed = false
    end

  end
end