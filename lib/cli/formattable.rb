module Cli
  module Formattable
    private

    def format
      as_json? ? :json : :table
    end

    def as_json?
      options[:raw]
    end
  end
end
