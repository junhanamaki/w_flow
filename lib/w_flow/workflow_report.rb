module WFlow
  class WorkflowReport

    extend Forwardable
    def_delegators :@workflow, :success?, :failure?, :failure_log
    def_delegators :@flow, :data

    def initialize(workflow, flow)
      @workflow = workflow
      @flow     = flow
    end

  end
end