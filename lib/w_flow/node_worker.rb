module WFlow
  class NodeWorker

    def initialize(node_class, process)
      @node_class = node_class
      @process    = process
    end

    def init_state(workflow)
      @workflow         = workflow
      @execution_chains = []
    end

    def run(workflow)
      init_state(workflow)

      if @node_class.around_handler.nil?
        execute_components
      else
        @node_class.around_handler.call(method(:execute_components))
      end
    end

    def execute_components(options = {})
      execution_chain = []


      @node_class.components.each do |component|
        report = Supervisor.supervise do
          if component.is_a?(Class) && component <= Process
            process_worker = ProcessWorker.new(component)

            execution_chain << process_worker

            report = process_worker.run(@workflow)
          else
            @process.wflow_eval(component)
          end
        end

        if report.failed?
          execution_chain.reverse_each(&:rollback)
          execution_chain.reverse_each(&:finalize)

          if options[:failure].nil? || options[:failure].call
            @workflow.log_failure(report.message)
          else
            Supervisor.resignal!(report)
          end
        else
          @execution_chains << execution_chain

          if report.stopped? && (options[:stop].nil? || !options[:stop].call)
            Supervisor.resignal!(report)
          end
        end
      end
    end

    def finalize
      @execution_chains.reverse_each do |execution_chain|
        execution_chain.reverse_each(&:finalize)
      end
    end

    def rollback
      @execution_chains.reverse_each do |execution_chain|
        execution_chain.reverse_each(&:rollback)
      end
    end

  end
end