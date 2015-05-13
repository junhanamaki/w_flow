module WFlow
  class Flow
    attr_reader :data, :failure_message

    def initialize(main_process_class, data)
      @main_process_class = main_process_class
      @data               = Data.new(data)
      @failure            = false
      @failure_message    = nil
      @executed           = []
    end

    def success?
      !failure?
    end

    def failure?
      @failure
    end

    def failure!(message = nil)
      @failure         = true
      @failure_message = message

      raise FlowFailure
    end

    def stop!
      throw :stop, true
    end

    def skip!
      throw :skip, true
    end

    def execute(element)
      if element.is_a?(String) || element.is_a?(Symbol)
        owner_process.instance_eval(element.to_s)
      elsif element.is_a?(Proc)
        execute_procedure(element)
      elsif element == Process
        execute_process(element)
      else
        raise UnknownNodeElement, "don't know how to execute node element #{element}"
      end
    end

    def start
      begin
        catch :stop do
          execute_process(@main_process_class)
        end
      catch FlowFailure
        execute_rollback
      end

      execute_final
    end

  protected



    def execute_procedure(element)
      owner_process.instance_eval(&element)
    end

    def execute_process(process_class)
      instance = process_class.new

      skipped = catch :skip do
        instance.setup

        @executed << instance

        process_class.process_nodes.each do |process_node|

        end

        instance.perform
      end
    end
  end
end