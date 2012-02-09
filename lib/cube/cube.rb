require 'savon'
require 'guerrilla_patch'

Savon.configure do |config|
  config.soap_version = 1
  config.log = false
end

HTTPI.log = false

module XMLA

  class Cube

    def Cube.execute(query, catalog = XMLA.catalog)
      Cube.new(query, catalog).as_table
    end

    def as_table 
      clean_table(table, y_size).reduce([]) { |result, row| result << row.flatten.join('|') }
    end

    let(:x_axe)  { @x_axe ||= axes[0] }
    let(:y_axe)  { @y_axe ||= axes[1] }
    let(:y_size) { y_axe[0].size }
    let(:x_size) { x_axe.size }

    private

    #header and rows
    def table
      (0...y_axe.size).reduce(header) { |result, j| result << ( y_axe[j] + (0...x_size).map { |i| "#{cell_data[i + j]}" }) }
    end

    def header
      [ ( (0..y_size - 1).reduce([]) { |header| header << '' } << x_axe).flatten ]
    end

    def axes
      axes = @response.to_hash[:execute_response][:return][:root][:axes][:axis].select { |axe| axe[:@name] != "SlicerAxis" }
      @axes ||= axes.reduce([]) do |result, axe|
        result << tuple(axe).reduce([]) { |y, member|
          data = (member[0] == :member) ? member[1] : member[:member]
          if data.class == Hash
            y << [data[:caption].strip]
          elsif data.size == 1
            y <<  data[:caption].strip
          else
            y << data.reduce([]) { |z, item_data|
              if (item_data.class == Hash)
                caption = item_data[:caption].strip
                z << caption
              end
            }
          end
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
        soap.body = "<Command> <Statement> <![CDATA[ #{@query} ]]> </Statement> </Command> <Properties> <PropertyList> <Catalog>#{@catalog}</Catalog>
                     <Format>Multidimensional</Format> <AxisFormat>TupleFormat</AxisFormat> </PropertyList> </Properties>"
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
      @data ||= cell_data.reduce([]) { |data, cell| cell[1].reduce(data) { |data, value| data << value[:value] } }
    end

    let(:tuple) { |axe| axe[:tuples][:tuple] }

  end
end
