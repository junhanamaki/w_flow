module WFlow
  class Node
    def initialize(components, options)
      @components        = components
      @if_condition      = options[:if]
      @unless_condition  = options[:unless]
      @around            = options[:around]
      @stop_condition    = options[:stop]
      @failure_condition = options[:failure]
    end

    def run(owner, flow)
      if execute?(owner)
        flow.supervise(self) do
          if @around.nil?
            execute_node(owner, flow)
          else
            @around.call(Proc.new { execute_node(owner, flow) })
          end
        end
      end
    end

  protected

    def execute?(owner)
      (@if_condition.nil? || owner.wflow_eval(@if_condition)) &&
      (@unless_condition.nil? || !owner.wflow_eval(@unless_condition))
    end

    def execute_node(owner, flow)
      @components.each do |component|
        wflow_eval(owner, component, flow)
      end
    end

    def wflow_eval(process, object, flow, *args)
      if object.is_a?(String) || object.is_a?(Symbol)
        process.send(object.to_s, *args)
      elsif object.is_a?(Proc)
        process.instance_exec(*args, &object)
      elsif object == Process
        object.new.wflow_run(flow, *args)
      else
        raise InvalidArguments, UNKNOWN_EXPRESSION
      end
    end
  end
end