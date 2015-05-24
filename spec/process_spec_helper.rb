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
  def perform;  flow.failure!;  end
  def finalize; execution_order << 'b_finalize'; end
  def rollback; execution_order << 'b_rollback'; end
end

class CProcess < Base
  def setup;    flow.skip!;    end
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

  execute AProcess, if: -> { true }

  def perform;  execution_order << 'e_perform';  end
  def finalize; execution_order << 'e_finalize'; end
  def rollback; execution_order << 'e_rollback'; end
end