module Api
  class Distribution
    class << self
      include Api::Utils

      def id_from(label)
        binding.pry
        from(label).distributionid
      end

      def from(label)
        list.find { |distribution| distribution.label == label }
      end

      def list
        api.avail.distributions
      end
    end
  end
end
