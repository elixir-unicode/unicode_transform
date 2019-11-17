defmodule Unicode.Transform.Parser.Character do
  import NimbleParsec

  @syntax_chars [
    {:not, ?;},
    {:not, ?\s},
    {:not, ?[},
    {:not, ?]},
    {:not, ?;},
    {:not, ?*},
    {:not, ?+},
    {:not, ?$},
    {:not, ??}
  ]

  def one_character do
    choice([
      ignore(string("\\")) |> utf8_char([]),
      ignore(string("''")) |> replace("'"),
      ignore(string("'")) |> concat(encoded_character()) |> ignore(string("'")),
      ignore(string("'")) |> repeat(utf8_char([{:not, ?'}])) |> ignore(string("'")),
      utf8_char(@syntax_chars)
    ])
  end

  def encoded_character do
    choice([
      ignore(string("\\u"))
      |> times(ascii_char([?a..?f, ?A..?F, 0..9]), 4),
      ignore(string("\\x{"))
      |> times(ascii_char([?a..?f, ?A..?F, 0..9]), min: 1, max: 4)
      |> ignore(string("}"))
    ])
    |> reduce(:hex_to_integer)
  end

  @class_chars [{:not, ?\s}, {:not, ?[}, {:not, ?]}, {:not, ?:}]

  def class_character do
    choice([
      ignore(string("\\")) |> utf8_char([]),
      ignore(string("''")) |> replace("'"),
      ignore(string("'")) |> concat(encoded_character()) |> ignore(string("'")),
      ignore(string("'")) |> repeat(utf8_char([{:not, ?'}])) |> ignore(string("'")),
      utf8_char(@class_chars)
    ])
  end

  def class_characters do
    class_character()
    |> repeat(ignore(optional(parsec(:whitespace))) |> concat(class_character()))
    |> reduce(:consolidate_string)
  end
end