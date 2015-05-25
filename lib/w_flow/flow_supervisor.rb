module WFlow
  class FlowSupervisor
    attr_reader :current_process

    def initialize(flow)
      @flow    = flow
      @backlog = []
      @finalizables  = []
      @rollbackables = []
    end

    def mark_as_finalizable
      @finalizables << current_process
    end

    def mark_as_rollbackable
      @rollbackables << current_process
    end

    def supervise(process)
      @backlog << @current_process unless @current_process.nil?
      @current_process = process

      yield
    ensure
      @current_process = @backlog.pop
    end

    def rethrow_stop?
      !@current_process.is_a?(NodeProcess) || !@current_process.cancel_stop?
    end

    def reraise_error?
      !@current_process.is_a?(NodeProcess) || !@current_process.cancel_failure?
    end

    def parent_process?
      !@current_process.nil? && @backlog.empty?
    end

    def do_rollbacks
      @rollbackables.each(&:rollback)
    end

    def do_finalizations
      @finalizables.each(&:finalize)
    end
  end
end