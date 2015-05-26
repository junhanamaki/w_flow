module WFlow
  class Report
    extend Forwardable
    def_delegators :@supervisor, :data, :message, :success?, :failure?

    def initialize(supervisor)
      @supervisor = supervisor
    end
  end
end