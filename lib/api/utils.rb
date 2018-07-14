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
        Faker::Hipster => [:words, 5 + rand(10), true],
        Faker::Lovecraft => [:words, 5 + rand(10)],
        Faker::Lorem => [:words, 5 + rand(10), true],
        Faker::NatoPhoneticAlphabet => [:code_word],
        Faker::Food => [:dish],
        Faker::Food => [:ingredient],
        Faker::Food => [:spice]
      }

      generators = word_generators.keys.sample(4)

      words = generators.map do |generator|
        args = word_generators[generator]
        generator.send(*args)
      end.flatten.sample(pwd_word_count)

      words \
        .map{ |w| w.split(' ').sample }
        .map{ |w| maybe_capitalize(w) }
        .map{ |w| maybe_digit(w) }
        .join(random_delimiter)
    end

    private

    def pwd_word_count(base=3, range=3)
      base + rand(range)
    end

    def random_delimiter
      (%w[ + $ ! ? . = - _ # | ] << ' ').sample
    end

    def maybe_capitalize(word)
      rand(3) == 0 ? word.capitalize : word
    end

    def maybe_digit(word)
      parts = [word]
      if Faker::Boolean.boolean
        parts << rand(9).to_s
      end
      parts.shuffle.join
    end
  end
end
