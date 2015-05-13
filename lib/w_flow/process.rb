module WFlow
  module Process
    attr_reader :flow

    def initialize(flow)
      @flow = flow
    end

    def setup;    end
    def perform;  end
    def rollback; end
    def final;    end

    def self.included(klass)
      klass.extend(ClassMethods)

      klass.instance_variable_set('@process_nodes', [])
    end

    module ClassMethods
      attr_reader :process_nodes

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

      def execute(*elements)
        options = elements.last.is_a?(Hash) ? elements.pop : {}

        validate_node_options(options)

        elements << Proc.new if block_given?

        validate_node_elements(elements)

        process_nodes << ProcessNode.new(elements, options)
      end

      def run(params = {})
        validate_flow_params(params)

        Flow.new(self, params).start
      end

    protected

      def validate_node_options(options)
        unless options.keys.all? { |key| [:if, :unless, :around].include?(key) }
          raise InvalidArgument, INVALID_OPTION
        end
      end

      def validate_node_elements(elements)
        unless elements.length > 0
          raise InvalidArgument, INVALID_ELEMENTS
        end
      end

      def validate_flow_params(params)
        unless params.is_a?(Hash)
          raise InvalidArgument, INVALID_PARAMS
        end
      end

      INVALID_OPTION   = 'valid option keys are :if, :unless and :around'
      INVALID_ELEMENTS = 'execute must be invoked with at least one ' \
                         'WFlow::Process/String/Symbol/Proc as argument or a block'
      INVALID_PARAMS   = 'run must be invoked with no arguments or with an Hash'
    end
  end
end