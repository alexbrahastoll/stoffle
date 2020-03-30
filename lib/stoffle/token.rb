require 'forwardable'

module Stoffle
  class Token
    extend Forwardable

    attr_reader :type, :lexeme, :literal, :location
    def_delegators :@location, :line, :col, :length

    def initialize(type, lexeme, literal, location)
      @type = type
      @lexeme = lexeme
      @literal = literal
      @location = location
    end

    def to_s
      "#{type} #{lexeme} #{literal}"
    end

    def ==(other)
      type == other.type &&
      lexeme == other.lexeme &&
      literal == other.literal &&
      location == other.location
    end
  end
end
