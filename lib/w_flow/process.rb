module WFlow
  module Process
    def self.included(klass)
      klass.extend(ClassMethods)
      klass.instance_variable_set('@wflow_node_description', [])
    end

    attr_reader :flow

    def initialize(flow, options = {})
      @flow    = flow
      @options = options
    end

    def setup;    end
    def perform;  end
    def rollback; end
    def finalize; end

    def wflow_run
      flow.supervise(self) do
        setup

        wflow_node_description.each do |desc|
          Node.new(self, flow, desc[:components], desc[:options]).run
        end

        perform
      end
    end

    def wflow_on_stop

    end

    def wflow_on_failure
    end

    def wflow_expression_eval(expression, *args)
      if expression.is_a?(String) || expression.is_a?(Symbol)
        send(expression.to_s, *args)
      elsif expression.is_a?(Proc)
        expression.call(*args)
      else
        raise InvalidArguments, UNKNOWN_EXPRESSION
      end
    end

  protected

    module ClassMethods
      attr_reader :wflow_node_description

      def data_accessor(*keys)
        data_writer(keys)
        data_reader(keys)
      end

      def data_writer(*keys)
        keys.each do |key|
          define_method "#{key}=" do |val|
            flow.data[key] = val
          end
        end
      end

      def data_reader(*keys)
        keys.each do |key|
          define_method key do
            flow.data[key]
          end
        end
      end

      def execute(*components, &block)
        options = components.last.is_a?(Hash) ? components.pop : {}
        components << block if block_given?
        wflow_node_description << { components: components, options: options }
      end

      def run(params = {})
        unless params.nil? || params.is_a?(Hash)
          raise InvalidArgument, INVALID_RUN_PARAMS
        end

        flow = Flow.new(params)

        new(flow).wflow_run
      end
    end
  end
end