require "w_flow/version"
require "w_flow/configuration"
require "w_flow/data"
require "w_flow/report"
require "w_flow/flow_supervisor"
require "w_flow/flow"
require "w_flow/node_process"
require "w_flow/node"
require "w_flow/process"

module WFlow
  # WFlow errors
  class StandardError < ::StandardError; end

  class InvalidArguments < StandardError; end
  class FlowFailure      < StandardError; end

  # WFlow message constants
  INVALID_RUN_PARAMS = "run must be invoked without arguments or an Hash"
  UNKNOWN_EXPRESSION = "can't evaluate expression"
end
