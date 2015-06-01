module WFlow
  module Process

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    attr_reader :flow

    def initialize(flow)
      @flow = flow
    end

    def setup;    end
    def perform;  end
    def rollback; end
    def finalize; end

    def wflow_eval(object, *args)
      if object.is_a?(String) || object.is_a?(Symbol)
        send(object.to_s, *args)
      elsif object.is_a?(Proc)
        instance_exec(*args, &object)
      else
        raise InvalidArguments, UNKNOWN_EXPRESSION
      end
    end

  protected

    module ClassMethods
      attr_reader :wflow_nodes

      def self.extended(klass)
        klass.instance_variable_set('@wflow_nodes', [])
      end

      def inherited(klass)
        klass.instance_variable_set('@wflow_nodes', wflow_nodes.dup)
      end

      def data_accessor(*keys)
        data_writer(*keys)
        data_reader(*keys)
      end

      def data_writer(*keys)
        keys.each do |key|
          define_method("#{key}=") { |val| flow.data.send("#{key}=", val) }
        end
      end

      def data_reader(*keys)
        keys.each do |key|
          define_method(key) { flow.data.send(key.to_s) }
        end
      end

      def execute(*components, &block)
        options = components.last.is_a?(Hash) ? components.pop : {}
        components << block if block_given?
        wflow_nodes << Node.build(components, options)
      end

      def run(params = {})
        unless params.nil? || params.is_a?(Hash)
          raise InvalidArgument, INVALID_RUN_PARAMS
        end

        flow = Flow.new(params)

        process_worker = ProcessWorker.new(self)

        process_report = Supervisor.supervise { process_worker.run(flow) }

        report = Supervisor.supervise do
          if process_report.failed?
            flow.set_failure_and_log(process_report.message)
            process_worker.rollback
          end

          process_worker.finalize
        end

        raise InvalidOperation, INVALID_OPERATION unless report.success?

        FlowReport.new(flow)
      rescue ::StandardError => e
        raise if e.is_a?(StandardError) || !Configuration.supress_errors?

        set_failure_and_log(message: e.message, backtrace: e.backtrace)

        FlowReport.new(flow)
      end

    end
  end
end