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

    def distribution_id_for(label)
      distribution_for(label).distributionid
    end

    def distribution_for(label)
      distributions.find { |distribution| distribution.label == label }
    end

    def distributions
      @distributions ||= api.avail.distributions
    end
  end
end
