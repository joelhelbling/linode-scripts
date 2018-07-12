require 'dotenv/load'
require 'singleton'
require 'linode'

module Api
  class Client
    include Singleton

    def initialize
      @api = Linode.new api_key: ENV['LINODE_API_KEY']
    end

    def method_missing(method, *args, &block)
      @api.send method, *args, &block
    end
  end
end
