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
      klass.init
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

      def init
        @process_nodes ||= []
      end

      def run(params = {})
        if params.is_a?(Hash)
          run_as_main_process(params)
        else
          run_as_task_process(params)
        end
      end

      def execute(*args)
        options = args.pop if args.last.is_a?(Hash)

        args << Proc.new if block_given?

        @process_nodes << ProcessNode.new(args, options)
      end

    protected

      def run_as_main_process(params)
        flow = Flow.new(params)

        instance = new(flow)

        begin
          instance.setup

          @process_nodes.each do |process_node|
            process_node.execute(instance)
          end

          instance.perform
        rescue FlowFailure
          instance.rollback
        end

        instance.final
      end

      def run_as_task_process(flow)
        instance = new(flow)
      end
    end
  end
end