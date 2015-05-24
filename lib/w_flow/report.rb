module WFlow
  class Report
    extend Forwardable
    def_delegators :@flow, :data, :success?, :failure?, :message

    def initialize(flow)
      @flow = flow
    end
  end
end