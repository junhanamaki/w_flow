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

    def run(owner)
      if execute?(owner)
        if @around.nil?
          execute_node(owner)
        else
          @around.call(Proc.new { execute_node(owner) })
        end
      end
    end

  protected

    def execute?(owner)
      (@if_condition.nil? || owner.wflow_eval(@if_condition)) &&
      (@unless_condition.nil? || !owner.wflow_eval(@unless_condition))
    end

    def execute_node(owner)
      @components.each do |component|
        owner.wflow_eval(component)
      end
    end
  end
end