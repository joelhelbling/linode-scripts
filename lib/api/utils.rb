require 'legitable'
require_relative 'client'

module Api
  module Utils
    def api
      Api::Client.instance
    end

    def standard_table
      Legitable::Table.new(delimiter: '  ')
    end

    def read_local(label)
      File.read "./stackscripts/#{label}"
    end

  end
end
