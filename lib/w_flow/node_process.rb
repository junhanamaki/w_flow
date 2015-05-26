module WFlow
  class NodeProcess
    def initialize(components, options)
      @components     = components
      @around_option  = options[:around]
      @if_option      = options[:if]
      @unless_option  = options[:unless]
      @stop_option    = options[:stop]
      @failure_option = options[:failure]
    end

    def execute(supervisor, process)
      @supervisor = supervisor
      @process    = process

      if execute_node?
        supervisor.supervise(self) do
          if @around_option.nil?
            execute_components
          else
            process_eval(@around_option, method(:execute_components))
          end
        end
      end
    end

    def cancel_stop?
      !@stop_option.nil? && !process_eval(@stop_option)
    end

    def cancel_failure?
      !@failure_option.nil? && !process_eval(@failure_option)
    end

  protected

    def execute_node?
      (@if_option.nil?     || process_eval(@if_option)) &&
      (@unless_option.nil? || !process_eval(@unless_option))
    end

    def execute_components
      @components.each { |component| process_eval(component) }
    end

    def process_eval(object, *args)
      if object.is_a?(String) || object.is_a?(Symbol)
        @process.send(object.to_s, *args)
      elsif object.is_a?(Proc)
        @process.instance_exec(*args, &object)
      elsif object <= Process
        object.new.wflow_execute(@supervisor, *args)
      else
        raise InvalidArguments, UNKNOWN_EXPRESSION
      end
    end
  end
end