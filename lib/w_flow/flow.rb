module WFlow
  class Flow
    extend Forwardable
    def_delegator  :@supervisor, :add_to_finalizables,  :finalizable!
    def_delegator  :@supervisor, :add_to_rollbackables, :rollbackable!
    def_delegators :@supervisor,
                   :skip!,
                   :stop!,
                   :failure!,
                   :data,
                   :success?,
                   :failure?

    def initialize(supervisor)
      @supervisor = supervisor
    end
  end
end