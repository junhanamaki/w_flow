module WFlow
  class Node

    class << self

      attr_reader :components,
                  :if_condition,
                  :unless_condition,
                  :stop_condition,
                  :failure_condition,
                  :around_handler

      def build(components, options)
        Class.new(self) do |klass|
          @components        = components
          @if_condition      = options[:if]
          @unless_condition  = options[:unless]
          @stop_condition    = options[:stop]
          @failure_condition = options[:failure]
          @around_handler    = options[:around]
        end
      end

      def execute?(process)
        (if_condition.nil?     || process.wflow_eval(if_condition)) &&
        (unless_condition.nil? || !process.wflow_eval(unless_condition))
      end

      def cancel_stop?(process)
        !stop_condition.nil? && !process.wflow_eval(stop_condition)
      end

      def cancel_failure?(process)
        !failure_condition.nil? && !process.wflow_eval(failure_condition)
      end

    end

  end
end