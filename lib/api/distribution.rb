module Api
  class Distribution
    class << self
      include Collectionate
      include Utils

      private def collection
        @collection ||= api.avail.distributions
      end
    end
  end
end
