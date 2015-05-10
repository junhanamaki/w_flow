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

        validate_options!(options)

        args << Proc.new if block_given?

        validate_tasks!(args)

        @process_nodes << ProcessNode.new(args, options)
      end

      def run(params = {})
        validate_params!(params)

        flow     = Flow.new(params)
        instance = new(flow)

        begin
          catch :stop do
            catch :skip do
              instance.setup

              @process_nodes.each do |process_node|
                process_node.execute(instance)
              end

              instance.perform
            end
          end
        catch FlowFailure
          rollback(flow)
        end

        final(flow)
      end

      def run_as_task(flow)
        instance = new(flow)
      end

    protected

      def validate_options!(options)
        unless options.keys.all? { |key| [:if, :unless, :around].include?(key) }
          raise InvalidArgument, INVALID_OPTION
        end
      end

      def validate_tasks!(tasks)
        raise InvalidArgument, INVALID_TASKS unless tasks.length > 0
      end

      def validate_params!(params)
        raise InvalidArgument, INVALID_PARAMS unless params.is_a?(Hash)
      end

      INVALID_OPTION = 'valid keys are :if, :unless and :around'
      INVALID_TASKS  = 'execute must be invoked with at least one ' \
                       'WFlow::Process/String/Symbol/Proc as argument or a block'
      INVALID_PARAMS = 'run must be invoked with no arguments or with an Hash'
    end
  end
end