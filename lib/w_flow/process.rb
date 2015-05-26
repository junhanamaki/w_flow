module WFlow
  module Process
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    attr_reader :flow

    def wflow_execute(supervisor)
      supervisor.supervise(self) do |flow|
        @flow = flow

        setup

        flow.finalizable!

        self.class.wflow_nodes.each do |node|
          node.execute(supervisor, self)
        end

        perform

        flow.rollbackable!
      end
    end

    def setup;    end
    def perform;  end
    def rollback; end
    def finalize; end

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
        wflow_nodes << Node.new(components, options)
      end

      def run(params = {})
        unless params.nil? || params.is_a?(Hash)
          raise InvalidArgument, INVALID_RUN_PARAMS
        end

        supervisor = Supervisor.new(params)

        new.wflow_execute(supervisor)

        supervisor.report
      end
    end
  end
end