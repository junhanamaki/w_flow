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

protected

  def unless_option
    execution_order.is_a?(Array)
  end
end

class GProcess < Base
  def setup
    flow.stop!
    execution_order << 'g_setup'
  end

  def perform;  execution_order << 'g_perform';  end
  def finalize; execution_order << 'g_finalize'; end
  def rollback; execution_order << 'g_rollback'; end
end