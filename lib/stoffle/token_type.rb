module Stoffle
  module TokenType
    # Single-character tokens.
    T_LEFT_PAREN = :left_paren
    T_RIGHT_PAREN = :right_paren
    T_COMMA = :comma
    T_DOT = :dot
    T_MINUS = :minus
    T_PLUS = :plus
    T_SLASH = :slash
    T_STAR = :star

    # One or two character tokens.
    T_BANG = :bang
    T_BANG_EQUAL = :bang_equal
    T_EQUAL = :equal
    T_EQUAL_EQUAL = :equal_equal
    T_GREATER = :greater
    T_GREATER_EQUAL = :greater_equal
    T_LESS = :less
    T_LESS_EQUAL = :less_equal

    # Literals.
    IDENTIFIER = :identifier
    STRING = :string
    NUMBER = :number

    # Keywords.
    T_AND = :and
    T_ELSE = :else
    T_ELSIF = :elsif
    T_END = :end
    T_FALSE = :false
    T_FN = :fn
    T_IF = :if
    T_NIL = :nil
    T_OR = :or
    T_PRINTLN = :println
    T_RETURN = :return
    T_TRUE = :true
    T_WHILE = :while

    T_EOF = :eof
    T_NEW_LINE = :new_line
  end
end
