require 'w_flow/version'
require 'w_flow/configuration'
require 'w_flow/data'
require 'w_flow/flow'
require 'w_flow/node'
require 'w_flow/process'
require 'w_flow/worker'

module WFlow
  # WFlow errors
  class StandardError < ::StandardError; end
  class InvalidArgument < StandardError; end
  class UnknownNodeElement < StandardError; end
  class FlowFailure < StandardError; end

  # WFlow message constants
  INVALID_KEYS       = 'valid option keys are :if, :unless and :around'
  INVALID_COMPONENTS =
    <<-EOS
      First argument for WFLow::Node must be an array containing
      at least one WFlow::Process, String, Symbol or Proc
    EOS
end
