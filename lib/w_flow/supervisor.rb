module WFlow
  class Supervisor
    attr_reader :executed_log, :completed_log

    def initialize
      @executed_log  = []
      @completed_log = []
    end

    def supervise(supervisable)
      @executed_log << supervisable

      yield

      @completed_log.unshift(supervisable)
    end

    def rollback_all
      @completed_log.each { |completed| completed.rollback }
    end

    def finalize_all
      @executed_log.each { |executed| executed.finalize }
    end
  end
end