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

    def run(owner_process, flow)
      @owner_process = owner_process

      if execute?
        @components.each do |component|
          owner_process.wflow_eval(component)
        end
      end
    end

  protected

    def execute?
      allowed_by_if_condition? && allowed_by_unless_condition?
    end

    def allowed_by_if_condition?
      @if_condition.nil? || @owner_process.wflow_eval(@if_condition)
    end

    def allowed_by_unless_condition?
      @unless_condition.nil? || !@owner_process.wflow_eval(@unless_condition)
    end
  end
end