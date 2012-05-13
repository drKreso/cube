class OlapResult 
  attr_reader :header, :rows
  def initialize(table)
    @header = table[0]
    table.delete_at(0)
    @rows = table
  end

  def prepare_data
    result = [] << [@header] << @rows
    result.flatten(1)
  end
end
