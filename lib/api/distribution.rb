module Api
  class Distribution
    class << self
      include Api::Utils

      def id_from(label)
        from(label).distributionid
      end

      def from(label)
        list.find { |distribution| distribution.label == label }
      end

      def list(format=:table)
        case format
        when :table
          as_table
        when :json
          as_jason
        else
          raise "Invalid format for Distributions: #{format}"
        end
      end

      private

      def as_table?(format)
        format == :table
      end

      def as_json
        JSON.pretty_generate(distributions.map(&:to_h))
      end

      def as_table
        distributions.each_with_object(standard_table) do |d, t|
          t << d.to_h
        end
      end

      def distributions
        api.avail.distributions
      end
    end
  end
end
