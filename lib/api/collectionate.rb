require 'json'

module Api
  module Collectionate
    include Utils

    def list(format=:table)
      case format
      when :table
        as_table
      when :json
        as_json
      else
        raise "Invalid format for #{resource_name} list: #{format}"
      end
    end

    def find(label)
      collection.find do |resource|
        resource.label == label
      end.tap do |resource|
        unless resource
          raise "#{resource_name} \"#{label}\" was not found!"
        end
      end
    end

    def id_from(label)
      find(label).send "#{resource_name}id"
    end

    private

    def as_json
      JSON.pretty_generate(collection.map(&:to_h))
    end

    def as_table
      collection.each_with_object(standard_table) do |resource, table|
        table << make_table_row(resource)
      end
    end

    def make_table_row(resource)
      resource.to_h
    end

    def resource_name
      self.name.gsub(/^Api::/, '').downcase
    end

    def collection
      raise "You need to implement the .collection method!"
    end
  end
end
