module WFlow
  class Supervisor
    attr_reader :data, :message

    def initialize(params)
      @data    = Data.new(params)
      @flow    = Flow.new(self)
      @failure = false
      @message = false
      @backlog = []
      @finalizables  = []
      @rollbackables = []
    end

    def supervise(process, &block)
      @backlog << @current_process unless @current_process.nil?
      @current_process = process

      if parent_process?
        supervise_parent_process(&block)
        finalize_processes
      else
        supervise_child_process(&block)
      end
    ensure
      @current_process = @backlog.pop
    end

    def add_to_finalizables
      @finalizables << @current_process
    end

    def add_to_rollbackables
      @rollbackables << @current_process
    end

    def skip!
      throw :wflow_interrupt, :wflow_skip
    end

    def stop!
      throw :wflow_interrupt, :wflow_stop
    end

    def failure!(message = nil)
      raise FlowFailure, Marshal.dump(message)
    end

    def success?
      !failure?
    end

    def failure?
      @failure
    end

    def report
      Report.new(self)
    end

  protected

    def parent_process?
      !@current_process.nil? && @backlog.empty?
    end

    def supervise_parent_process
      catch :wflow_interrupt do
        yield @flow
      end
    rescue FlowFailure => e
      set_failure(true, Marshal.load(e.message))
    rescue ::StandardError => e
      raise unless Configuration.supress_errors?

      set_failure(true, message: e.message, backtrace: e.backtrace)
    end

    def supervise_child_process
      interrupt = catch :wflow_interrupt do
        yield @flow
      end

      stop! if interrupt == :wflow_stop && rethrow_stop?
    rescue FlowFailure => e
      if reraise_error?
        set_failure(true, Marshal.load(e.message))
        raise
      else
        set_failure(false, Marshal.load(e.message))
      end
    end

    def finalize_processes
      interrupt = catch :wflow_interrupt do
        @rollbackables.each(&:rollback) if failure?
        @finalizables.each(&:finalize)
      end

      raise FlowFailure if [:wflow_stop, :wflow_skip].include?(interrupt)
    rescue FlowFailure
      raise InvalidOperation, INVALID_OPERATION
    end

    def set_failure(state, message)
      @failure = state
      @message << message unless message.nil?
    end

    def rethrow_stop?
      !@current_process.is_a?(NodeProcess) || !@current_process.cancel_stop?
    end

    def reraise_error?
      !@current_process.is_a?(NodeProcess) || !@current_process.cancel_failure?
    end
  end
end