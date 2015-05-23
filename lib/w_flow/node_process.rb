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

    def run(process, flow)
      @process = process
      @flow    = flow

      unless cancelled?
        flow.supervise(self) do
          if around.nil?
            run_components
          else
#            around.call(Proc.new { run_components })
          end
        end
      end
    end

    def cancel_error?
    end

    def cancel_failure?
    end

    def finalize
    end

    def rollback
    end

  protected

    def cancelled?
      (@if_condition.nil? || node_eval(@if_condition)) &&
      (@unless_condition.nil? || node_eval(@unless_condition))
    end

    def run_components
      @components.each do |component|
      end
    end

    def node_eval(object)
      if object.is_a?(String) || object.is_a?(Symbol)
        @process.send(object.to_s)
      elsif object.is_a?(Proc)
        @process.instance_exec(&object)
      elsif object == Process
        object.new.wflow_run(@flow)
      else
        raise InvalidArguments, UNKNOWN_EXPRESSION
      end
    end
  end
end