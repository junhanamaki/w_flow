module WFlow
  class Flow
    extend Forwardable
    def_delegators :@supervisor, :data, :success?, :failure?
    def_delegator  :@supervisor, :add_to_finalizables,  :finalizable!
    def_delegator  :@supervisor, :add_to_rollbackables, :rollbackable!

    def initialize(supervisor)
      @supervisor = supervisor
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
  end
end