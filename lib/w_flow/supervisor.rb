module WFlow
  class Supervisor
    def initialize(params)
      @data = Data.new(params)
      @flow = Flow.new(@data)
      @executed_log  = []
      @completed_log = []
    end

    def supervising(supervisable)
      @executed_log << supervisable

      @flow.executing(supervisable) { yield @flow }

      @completed_log.unshift(supervisable)
    end

    def report
      Report.new(@flow)
    end
  end
end