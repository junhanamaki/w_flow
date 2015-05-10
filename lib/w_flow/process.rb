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

      def execute(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}

        unless options.keys.all? { |key| [:if, :unless, :around].include?(key) }
          raise InvalidArgument, INVALID_OPTION_KEYS
        end

        args << Proc.new if block_given?

        raise InvalidArgument, INVALID_TASKS unless args.length > 0

        @process_nodes << ProcessNode.new(args, options)
      end

      def run(params = {})
        raise InvalidArgument, INVALID_RUN_PARAMS unless params.is_a?(Hash)

        instance = new(Flow.new(params))
      end

      def run_as_task(flow)
        instance = new(flow)
      end

      INVALID_OPTION_KEYS = 'valid keys are :if, :unless and :around'
      INVALID_TASKS = 'execute must be invoked with at least one ' \
                      'WFlow::Process/String/Symbol/Proc as argument or a block'
      INVALID_RUN_PARAMS = 'run must be invoked with no arguments or with an Hash'
    end
  end
end