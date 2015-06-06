class Base
  include WFlow::Process

  data_reader :execution_order
end

class AProcess < Base
  def setup;    execution_order << 'a_setup';    end
  def perform;  execution_order << 'a_perform';  end
  def finalize; execution_order << 'a_finalize'; end
  def rollback; execution_order << 'a_rollback'; end
end

class BProcess < Base
  def setup;    execution_order << 'b_setup';    end

  def perform
    flow.failure!
    execution_order << 'b_perform'
  end

  def finalize; execution_order << 'b_finalize'; end
  def rollback; execution_order << 'b_rollback'; end
end

class CProcess < Base
  def setup
    flow.skip!
    execution_order << 'c_setup'
  end

  execute AProcess

  def perform;  execution_order << 'c_perform';  end
  def finalize; execution_order << 'c_finalize'; end
  def rollback; execution_order << 'c_rollback'; end
end

class DProcess < Base
  def setup;    execution_order << 'd_setup';    end

  execute AProcess

  def perform;  execution_order << 'd_perform';  end
  def finalize; execution_order << 'd_finalize'; end
  def rollback; execution_order << 'd_rollback'; end
end

class EProcess < Base
  def setup;    execution_order << 'e_setup';    end

  execute AProcess, if: -> { execution_order.is_a?(Array) }

  def perform;  execution_order << 'e_perform';  end
  def finalize; execution_order << 'e_finalize'; end
  def rollback; execution_order << 'e_rollback'; end
end

class FProcess < Base
  def setup;    execution_order << 'f_setup';    end

  execute AProcess, unless: :unless_option

  def perform;  execution_order << 'f_perform';  end
  def finalize; execution_order << 'f_finalize'; end
  def rollback; execution_order << 'f_rollback'; end

  def unless_option
    execution_order.is_a?(Array)
  end
end

class GProcess < Base
  def setup
    flow.stop!
    execution_order << 'g_setup'
  end

  execute AProcess

  def perform;  execution_order << 'g_perform';  end
  def finalize; execution_order << 'g_finalize'; end
  def rollback; execution_order << 'g_rollback'; end
end

class HProcess < Base
  def setup;    execution_order << 'h_setup';    end

  execute BProcess, failure: -> { false }

  def perform;  execution_order << 'h_perform';  end
  def finalize; execution_order << 'h_finalize'; end
  def rollback; execution_order << 'h_rollback'; end
end

class IProcess < Base
  def setup;    execution_order << 'i_setup';    end

  execute GProcess, stop: -> { false }

  def perform;  execution_order << 'i_perform';  end
  def finalize; execution_order << 'i_finalize'; end
  def rollback; execution_order << 'i_rollback'; end
end

class JProcess < Base
  def setup;    execution_order << 'j_setup';    end

  execute AProcess, around: Proc.new { |node| 2.times { node.call } }

  def perform;  execution_order << 'j_perform';  end
  def finalize; execution_order << 'j_finalize'; end
  def rollback; execution_order << 'j_rollback'; end
end

class KProcess < Base
  def setup;    execution_order << 'k_setup';    end

  execute -> { execution_order << 'proc' }, :method_name

  def perform;  execution_order << 'k_perform';  end
  def finalize; execution_order << 'k_finalize'; end
  def rollback; execution_order << 'k_rollback'; end

  def method_name; execution_order << 'method_name'; end
end

class LProcess < Base
  def setup;    execution_order << 'l_setup';    end

  execute KProcess, unless: -> { true }

  execute AProcess, CProcess, BProcess, failure: -> { false }

  execute -> { execution_order << 'proc' }, around: Proc.new { |n| 2.times { n.call } }

  def perform;  execution_order << 'l_perform';  end
  def finalize; execution_order << 'l_finalize'; end
  def rollback; execution_order << 'l_rollback'; end
end

class MProcess < Base
  def setup;    execution_order << 'm_setup';    end

  execute BProcess

  def perform;  execution_order << 'm_perform';  end
  def finalize; execution_order << 'm_finalize'; end
  def rollback; execution_order << 'm_rollback'; end
end

class NProcess < Base
  def setup;    execution_order << 'n_setup';    end

  execute MProcess, failure: -> { false }

  execute LProcess

  def perform;  execution_order << 'n_perform';  end
  def finalize; execution_order << 'n_finalize'; end
  def rollback; execution_order << 'n_rollback'; end
end