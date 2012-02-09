module XMLA 
  class << self
    attr_accessor :endpoint, :catalog
  end

  def self.configure
    yield self if block_given?
  end
end
