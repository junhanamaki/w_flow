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

      def execute(*elements, &block)
        options = elements.last.is_a?(Hash) ? elements.pop : {}

        elements << block if block_given?

        @process_nodes << ProcessNode.new(elements, options)
      end

      def run(params = {})

      end
    end
  end
end