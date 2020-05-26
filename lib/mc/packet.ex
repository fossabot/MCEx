defmodule MCEx.MC.Packet do

  @doc """
  read a var Int from a binary string

  # TODO: add test if longer than 5 bytes
  """
  @spec read_varInt(bitstring()) :: {integer(), binary()}
  def read_varInt(data) when is_binary(data) do
    <<size::1, value::7, data::binary>> = data
    case size do
      1 -> read_varInt(<<value::7>>, data)
      0 -> {var_toint(value), data}
    end
  end
  @spec read_varInt(bitstring(), binary()) :: {integer(), binary()}
  def read_varInt(value, data) when is_bitstring(value) and is_binary(data) do
    <<size::1, add::7, data::binary>> = data
    value = << add::7, value::bitstring >>
    case size do
      1 -> read_varInt(value, data)
      0 -> {var_toint(value), data}
    end
  end

  @spec split(binary()) :: {[binary()], binary()} | {[], binary()}
  def split(data) when is_binary(data) do
    if bit_size(data) < 8 do
      {[], data}
    else
      {size, data} = read_varInt(data)
      case data do
        <<data::binary-size(size), rest::binary>> ->  split([data], rest) #{[data], rest}
        _ -> {[], data}
      end
    end
  end
  @spec split([binary()], binary()) :: {[binary()], binary()}
  def split(data, rest) when is_list(data) and is_binary(rest) do
    if bit_size(rest) < 8 do
      {data, rest}
    else
      {size, rest} = read_varInt(rest)
      case rest do
        <<value::binary-size(size), rest::binary>> -> split(data ++ [value], rest)
        _ -> {data, rest}
      end
    end
  end

  #convert the bitstring to int (also usable for long)
  @spec var_toint(bitstring()) :: integer()
  defp var_toint(data) when is_bitstring(data) do
    size = div(bit_size(data), 7)
    <<int::size(size)-unit(7)-signed-big>> = data # TODO: make signed
    int
  end
  @spec var_toint(integer()) :: byte()
  defp var_toint(int) when is_integer(int) do
    var_toint(<<int::7>>)
  end

end
