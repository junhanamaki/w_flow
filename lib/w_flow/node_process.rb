module WFlow
  class NodeProcess
    def initialize(components, options)
      @components        = components
      @around            = options[:around]
      @if_condition      = options[:if]
      @unless_condition  = options[:unless]
      @stop_condition    = options[:stop]
      @failure_condition = options[:failure]
    end

    def execute(supervisor, process)
      @supervisor = supervisor
      @process    = process

      if execute_node?
        supervisor.supervising(self) do |flow|
          if @around.nil?
            run_components
          else
            process_eval(@around, Proc.new { run_components })
          end
        end
      end
    end

    def cancel_stop?
    end

    def cancel_failure?
    end

    def finalize; end
    def rollback; end

  protected

    def execute_node?
      (@if_condition.nil?     || process_eval(@if_condition)) &&
      (@unless_condition.nil? || !process_eval(@unless_condition))
    end

    def run_components
      @components.each { |component| process_eval(component) }
    end

    def process_eval(object, *args)
      if object.is_a?(String) || object.is_a?(Symbol)
        @process.send(object.to_s, *args)
      elsif object.is_a?(Proc)
        @process.instance_exec(*args, &object)
      elsif object == Process
        object.new.wflow_run(@supervisor, *args)
      else
        raise InvalidArguments, UNKNOWN_EXPRESSION
      end
    end
  end
end