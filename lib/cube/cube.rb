require 'savon'
require 'guerrilla_patch'
require 'bigdecimal'

Savon.configure do |config|
  config.soap_version = 1
  config.log = false
end

HTTPI.log = false

module XMLA

  class Cube
    attr_reader :query, :catalog

    def Cube.execute(query, catalog = XMLA.catalog)
      OlapResult.new(Cube.new(query, catalog).as_table)
    end

    def Cube.execute_scalar(query, catalog = XMLA.catalog)
      BigDecimal.new Cube.new(query, catalog).as_table[0]
    end

    def as_table 
      return [table] if y_size == 0
      clean_table(table, y_size).reduce([]) { |result, row| result << row.flatten }
    end

    private

    let(:x_axe)  { @x_axe ||= axes[0] }
    let(:y_axe)  { @y_axe ||= axes[1] }
    let(:y_size) { (y_axe.nil? || y_axe[0].nil?) ? 0 : y_axe[0].size }
    let(:x_size) { x_axe.size }

    #header and rows
    def table
      if (header.size == 1 && y_size == 0)
        cell_data[0]
      else
        (0...y_axe.size).reduce(header) { |result, j| result << ( y_axe[j] + (0...x_size).map { |i| "#{cell_data[i + j]}" }) }
      end
    end

    def header
      [ ( (0..y_size - 1).reduce([]) { |header| header << '' } << x_axe).flatten ]
    end

    def axes
      axes = @response.to_hash[:execute_response][:return][:root][:axes][:axis].select { |axe| axe[:@name] != "SlicerAxis" }
      @axes ||= axes.reduce([]) do |result, axe|
        result << tuple(axe).reduce([]) { |y, member|
          data = (member[0] == :member) ? member[1] : member[:member]
          y << ( data.class == Hash || data.size == 1 ?
                                      [data[:caption].strip].flatten :
                                      data.select { |item_data| item_data.class == Hash }.reduce([]) { |z,item_data| z << item_data[:caption].strip } )
        }
      end
    end

    def initialize(query, catalog)
      @query = query
      @catalog = catalog
      @response = get_response
      self
    end

    def get_response
      client = Savon::Client.new do
        wsdl.document = File.expand_path("../../wsdl/xmla.xml", __FILE__)
        wsdl.endpoint = XMLA.endpoint
      end

      @response = client.request :execute,  xmlns:"urn:schemas-microsoft-com:xml-analysis" do
        soap.body = Cube.request_body(query, catalog)
      end
    end

    #cleanup table so items don't repeat (if they are same)
    def clean_table(table, number_of_colums)
      above_row = []
      #filter if they are not last column, and they are same as the item on the row above
      table.reduce([]) { |result, row|
        result <<  row.each_with_index.map { |item,i| (i == number_of_colums) ? item : ((item == above_row[i]) ? '' : item ) }
        above_row = row
        result
      }
    end

    def cell_data
      cell_data = @response.to_hash[:execute_response][:return][:root][:cell_data]
      return [""] if cell_data.nil? 
      @data ||= cell_data.reduce([]) do |data, cell|
        cell[1].reduce(data) do |data, value|
          data << (value.class == Hash ?  value[:value] : value[1] )
        end
      end
    end

    def tuple(axe)
      axe[:tuples].nil? ? [] : axe[:tuples][:tuple] 
    end

    def Cube.request_body(query, catalog)
      "<Command> <Statement> <![CDATA[ #{query} ]]> </Statement> </Command> <Properties> <PropertyList> <Catalog>#{catalog}</Catalog>
      <Format>Multidimensional</Format> <AxisFormat>TupleFormat</AxisFormat> </PropertyList> </Properties>"
    end

  end

  class OlapResult 
    attr_reader :header, :rows
    def initialize(table)
      @header = table[0]
      table.delete_at(0)
      @rows = table
    end
  end

end


