class Base
  include WFlow::Process

  attr_reader :execution_order
end

class AProcess < Base
  def setup;   execution_order << 'a_setup'; end
  def perform; execution_order << 'a_perform'; end
  def final;   execution_order << 'a_final'; end
end

class BProcess < Base
  def setup;   execution_order << 'b_setup';   end
  def perform; execution_order << 'b_perform'; end
  def final;   execution_order << 'b_final';   end
end

class CProcess < Base
  def setup;   execution_order << 'c_setup'; end
  execute AProcess
  def perform; execution_order << 'c_perform'; end
  def final;   execution_order << 'c_final'; end
end