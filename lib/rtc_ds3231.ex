defmodule RtcDs3231 do
  @moduledoc """
  Use a DS3231 real time clock with a nerves system

  I have only tested this with a raspberry pi and the sunfounder ds3231 board

  ## References

  - https://datasheets.maximintegrated.com/en/ds/DS3231.pdf
  - https://www.sunfounder.com/ds3231-real-time-clock-module.html
  """

  alias ElixirALE.I2C
  alias RtcDs3231.Encoder
  alias RtcDs3231.Decoder

  @doc """
  Read the real time clock and return the time as a NaiveDateTime. 'address` is the 7 bit device address.

  ## Example:

      RtcDs3231.rtc_datetime(0x68)

  The chip apperas to store a 2 digit year and flip the century bit when it overflows, hence the need to
  pass in the century.
  """
  @spec rtc_datetime(byte, integer) :: {:ok, NaiveDateTime}
  def rtc_datetime(address, century \\ 2000) do
    {:ok, pid} = I2C.start_link("i2c-1", address)
    bytes = I2C.write_read(pid, <<0 >> , 7)
    Decoder.decode_datetime(bytes, century)
  end

  @doc """
  Set the real time clock from a NaiveDateTime, discarding the century.

  ## Example:

      RtcDs3231.set_rtc_datetime(0x68, ~N[2018-01-02 11:50:12])

  """
  @spec set_rtc_datetime(byte, naiveDateTime) :: :ok
  def set_rtc_datetime(address, time) do
    {:ok, pid} = I2C.start_link("i2c-1", address)
    {:ok, bytes} = Encoder.encode_datetime(time)

    I2C.write(pid, << 0 >> <> bytes)
  end
end
