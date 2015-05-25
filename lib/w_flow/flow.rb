module WFlow
  class Flow
    attr_reader :data, :message

    def initialize(params)
      @flow_supervisor = FlowSupervisor.new(self)
      @data    = Data.new(params)
      @backlog = []
      @failure = false
      @message = []
    end

    def supervise(process, &block)
      @flow_supervisor.supervise(process) do
        if @flow_supervisor.parent_process?
          execute_parent_process(&block)
          finalize_processes
        else
          execute_child_process(&block)
        end
      end
    end

    def success?
      !failure?
    end

    def failure?
      @failure
    end

    def skip!
      throw :skip, :wflow_skip
    end

    def stop!
      throw :stop, :wflow_stop
    end

    def failure!(message = nil)
      @failure = true
      @message << message

      raise FlowFailure
    end

  protected

    def execute_parent_process
      catch :stop do
        catch :skip do
          yield @flow_supervisor
        end
      end
    rescue FlowFailure
    rescue ::StandardError => e
      raise unless Configuration.supress_errors?

      failure!(message: e.message, backtrace: e.backtrace) rescue nil
    end

    def execute_child_process
      stopped = catch :stop do
        catch :skip do
          yield @flow_supervisor
        end
      end

      stop! if stopped == :wflow_stop && @flow_supervisor.rethrow_stop?
    rescue FlowFailure
      @flow_supervisor.reraise_error? ? raise : @failure = false
    end

    def finalize_processes
      @flow_supervisor.do_rollbacks if failure?

      @flow_supervisor.do_finalizations
    end
  end
end