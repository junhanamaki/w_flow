module WFlow
  class Node

    class << self

      attr_reader :components,
                  :if_condition,
                  :unless_condition,
                  :stop_condition,
                  :failure_condition,
                  :around_handler

      def build(components, options)
        Class.new(self) do |klass|
          @components        = components
          @if_condition      = options[:if]
          @unless_condition  = options[:unless]
          @stop_condition    = options[:stop]
          @failure_condition = options[:failure]
          @around_handler    = options[:around]
        end
      end

      def execute?(process)
        (if_condition.nil?     || process_eval(process, if_condition)) &&
        (unless_condition.nil? || !process_eval(process, unless_condition))
      end

      def cancel_stop?(process)
        !stop_condition.nil? && !process_eval(process, stop_condition)
      end

      def cancel_failure?(process)
        !failure_condition.nil? && !process_eval(process, failure_condition)
      end

      def process_eval(process, object, *args)
        if object.is_a?(String) || object.is_a?(Symbol)
          process.send(object.to_s, *args)
        elsif object.is_a?(Proc)
          process.instance_exec(*args, &object)
        else
          raise InvalidArguments, UNKNOWN_EXPRESSION
        end
      end

    end

    def initialize(owner_process)
      @owner_process = owner_process
    end

    def run(flow)
      @flow             = flow
      @execution_chains = []

      Supervisor.supervise do
        if around_handler.nil?
          execute_components
        else
          around_handler.call(method(:execute_components))
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

  protected

    def execute_components(options = {})
      execution_chain = []

      components.each do |component|
        report = Supervisor.supervise do
          if component.is_a?(Class) && component <= Process
            process_worker = ProcessWorker.new(component)

            execution_chain << process_worker

            report = process_worker.run_as_child(@flow)
          else
            self.class.process_eval(@owner_process, component)
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
            @execution_chains << execution_chain
            Supervisor.resignal!(report)
          end
        end
      end

      @execution_chains << execution_chain
    end

    def components
      @components ||= self.class.components
    end

    def around_handler
      @around_handler ||= self.class.around_handler
    end

    def stop_condition
      @stop_condition ||= self.class.stop_condition
    end

    def failure_condition
      @failure_condition ||= self.class.failure_condition
    end

  end
end