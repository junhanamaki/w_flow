module WFlow
  class Supervisor
    def initialize(params)
      @flow = Flow.new(params)
      @executed_processes  = []
      @completed_processes = []
    end

    def supervising(process)
      @executed_processes << process

      @flow.executing(process) { yield @flow }

      @completed_processes.unshift(process)

      finalize if @flow.terminated?
    end

    def report
      Report.new(@flow)
    end

  protected

    def finalize
      if @flow.failure?
        @completed_processes.each(&:rollback)
      end

      @executed_processes.each(&:finalize)
    end
  end
end