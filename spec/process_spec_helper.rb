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