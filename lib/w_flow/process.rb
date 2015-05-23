module WFlow
  module Process
    def self.included(klass)
      klass.extend(ClassMethods)
      klass.instance_variable_set('@wflow_nodes', [])

      class << klass
        def inherited(klass)
          klass.instance_variable_set('@wflow_nodes', @wflow_nodes.dup)
        end
      end
    end

    attr_reader :flow

    def initialize(flow)
      @flow = flow
    end

    def wflow_nodes
      self.class.wflow_nodes do |node|
        node_process = node.build_node_process(self)

        yield(node_process) if node_process.execute?
      end
    end

    def setup;    end
    def perform;  end
    def rollback; end
    def finalize; end

  protected

    module ClassMethods
      attr_reader :wflow_nodes

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
        wflow_nodes << Node.new(components, options)
      end

      def run(params = {})
        unless params.nil? || params.is_a?(Hash)
          raise InvalidArgument, INVALID_RUN_PARAMS
        end

        Flow.new(params).run(self)
      end
    end
  end
end