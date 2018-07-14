require 'legitable'
require 'faker'
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

    def random_password
      word_generators = {
        Faker::Hipster => [:words, 5 + rand(10)],
        Faker::Lovecraft => [:words, 5 + rand(10)],
        Faker::Lorem => [:words, 5 + rand(10)],
        Faker::NatoPhoneticAlphabet => [:code_word],
        Faker::Food => [:dish],
        Faker::Food => [:ingredient],
        Faker::Food => [:spice]
      }

      generators = word_generators.keys.sample(4)

      words = generators.map do |generator|
        args = word_generators[generator]
        generator.send(*args)
      end.flatten.sample(2+rand(3))

      words.map{|w| maybe_digit(w) }.join(random_delimiter)
    end

    private

    def random_delimiter
      %w[ + $ ! ? . = - _ # | ].sample
    end

    def maybe_digit(word)
      if Faker::Boolean.boolean
        word + rand(9).to_s
      else
        word
      end
    end
  end
end
