module WFlow
  class FlowReport

    extend Forwardable
    def_delegators :@flow, :data, :success?, :failure?, :failure_log

    def initialize(flow)
      @flow = flow
    end

  end
end