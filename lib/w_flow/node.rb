module WFlow
  class Node

    class << self

      attr_reader :components, :options

      def build(components, options)
        Class.new(self) do |klass|
          @components = components
          @options    = options
        end
      end

    end

    def initialize(process)
      @process    = process
      @components = self.class.components

      options = self.class.options

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
      @executed_node_groups = []

      report = Supervisor.supervise do
        if @around_proc.nil?
          execute_components
        else
          process_eval(@around_proc, method(:execute_components))
        end
      end

      if report.failed?
        rollback
        finalize

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

    def execute_components(options = {})
      execution_chain = []

      @components.each do |component|
        report = Supervisor.supervise do
          if component.is_a?(Class) && component <= Process
            process_worker = ProcessWorker.new(component)

            execution_chain << process_worker

            process_worker.run_as_child(@flow)
          else
            process_eval(component)
          end
        end

        if report.failed?
          execution_chain.reverse_each(&:rollback)
          execution_chain.reverse_each(&:finalize)

          if options[:failure].nil? || options[:failure].call
            @flow.log_failure(report.message)
            return
          else
            Supervisor.resignal!(report)
          end
        else
          if report.stopped? && (options[:stop].nil? || !options[:stop].call)
            @executed_node_groups << execution_chain
            Supervisor.resignal!(report)
          end
        end
      end

      @executed_node_groups << execution_chain
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
      @executed_node_groups.reverse_each do |execution_chain|
        execution_chain.reverse_each(&order)
      end

      @executed_node_groups.clear
    end

  end
end