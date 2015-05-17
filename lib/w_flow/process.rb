module WFlow
  module Process
    def self.included(klass)
      klass.extend(ClassMethods)
      klass.instance_variable_set('@wflow_node_description', [])
    end

    attr_reader :flow

    def initialize(flow, options)
      @flow = flow

      @handlers = {}

      unless options[:stop].nil?
        @handlers[:stop] = Proc.new { wflow_eval(@handlers[:stop]) }
      end

      unless options[:failure].nil?
        @handlers[:failure] = Proc.new { wflow_eval(@handlers[:failure]) }
      end
    end

    def setup;    end
    def perform;  end
    def rollback; end
    def finalize; end

    def wflow_run
      flow.supervise(self, @handlers) do
        setup

        wflow_node_description.each do |desc|
          Node.new(desc[:components], desc[:options]).run(self, flow)
        end

        perform
      end
    end

    def wflow_eval(object, *args)
      if object.is_a?(String) || object.is_a?(Symbol)
        send(object.to_s, *args)
      elsif object.is_a?(Proc)
        instance_exec(*args, &object)
      elsif object == Process
        object.new(flow, *args).wflow_run
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