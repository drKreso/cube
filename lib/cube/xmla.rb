module Xmla
  def self.configure
    yield self if block_given?
  end

  def self.endpoint=(value)
    @endpoint = value
  end

  def self.catalog=(value)
    @catalog = value
  end

  def self.endpoint() @endpoint end
  def self.catalog() @catalog end
end
