defmodule AdventOfCode.Day12 do
  @move_regex ~r/^(N|S|E|W|L|R|F)(\d+)$/
  @angles %{
    :E => 0,
    :N => 90,
    :W => 180,
    :S => 270
  }
  @inverse_angles %{
    0 => :E,
    90 => :N,
    180 => :W,
    270 => :S
  }

  @spec move_ship(
          [{:E | :F | :L | :N | :R | :S | :W, number}],
          {{number, number}, :E | :F | :L | :N | :R | :S | :W}
        ) ::
          {{number, number}, :E | :F | :L | :N | :R | :S | :W}
  def move_ship([], {{_, _}, _} = position) do
    position
  end

  def move_ship([{:F, units} | directions], {{lat, long}, :E}) do
    move_ship(directions, {{lat + units, long}, :E})
  end

  def move_ship([{:F, units} | directions], {{lat, long}, :W}) do
    move_ship(directions, {{lat - units, long}, :W})
  end

  def move_ship([{:F, units} | directions], {{lat, long}, :N}) do
    move_ship(directions, {{lat, long + units}, :N})
  end

  def move_ship([{:F, units} | directions], {{lat, long}, :S}) do
    move_ship(directions, {{lat, long - units}, :S})
  end

  def move_ship([{:N, units} | directions], {{lat, long}, facing}) do
    move_ship(directions, {{lat, long + units}, facing})
  end

  def move_ship([{:S, units} | directions], {{lat, long}, facing}) do
    move_ship(directions, {{lat, long - units}, facing})
  end

  def move_ship([{:E, units} | directions], {{lat, long}, facing}) do
    move_ship(directions, {{lat + units, long}, facing})
  end

  def move_ship([{:W, units} | directions], {{lat, long}, facing}) do
    move_ship(directions, {{lat - units, long}, facing})
  end

  def move_ship([{:R, units} | directions], {{lat, long}, facing}) do
    %{^facing => current_angle} = @angles
    new_angle = Integer.mod(current_angle - units, 360)
    %{^new_angle => new_direction} = @inverse_angles
    move_ship(directions, {{lat, long}, new_direction})
  end

  def move_ship([{:L, units} | directions], {{lat, long}, facing}) do
    %{^facing => current_angle} = @angles
    new_angle = Integer.mod(current_angle + units, 360)
    %{^new_angle => new_direction} = @inverse_angles
    move_ship(directions, {{lat, long}, new_direction})
  end

  @spec rotate(integer, {number, number}) :: {float, float}
  def rotate(angle, {x, y}) do
    units = Integer.mod(angle, 360) * :math.pi() / 180
    rot_sin = :math.sin(units)
    rot_cos = :math.cos(units)
    new_x = x * rot_cos - y * rot_sin
    new_y = x * rot_sin + y * rot_cos
    {new_x, new_y}
  end

  @spec move_waypoint(
          [{:E | :F | :L | :N | :R | :S | :W, number}],
          {number, number},
          {number, number}
        ) :: {{number, number}, {number, number}}
  def move_waypoint([], position, waypoint_position) do
    {position, waypoint_position}
  end

  def move_waypoint([{:F, units} | directions], {lat, long}, {waypoint_lat, waypoint_long}) do
    new_position = {lat + units * waypoint_lat, long + units * waypoint_long}
    move_waypoint(directions, new_position, {waypoint_lat, waypoint_long})
  end

  def move_waypoint([{:N, units} | directions], position, {waypoint_lat, waypoint_long}) do
    new_waypoint = {waypoint_lat, waypoint_long + units}
    move_waypoint(directions, position, new_waypoint)
  end

  def move_waypoint([{:S, units} | directions], position, {waypoint_lat, waypoint_long}) do
    new_waypoint = {waypoint_lat, waypoint_long - units}
    move_waypoint(directions, position, new_waypoint)
  end

  def move_waypoint([{:E, units} | directions], position, {waypoint_lat, waypoint_long}) do
    new_waypoint = {waypoint_lat + units, waypoint_long}
    move_waypoint(directions, position, new_waypoint)
  end

  def move_waypoint([{:W, units} | directions], position, {waypoint_lat, waypoint_long}) do
    new_waypoint = {waypoint_lat - units, waypoint_long}
    move_waypoint(directions, position, new_waypoint)
  end

  def move_waypoint([{:R, units} | directions], position, waypoint_pos) do
    new_waypoint = rotate(-units, waypoint_pos)
    move_waypoint(directions, position, new_waypoint)
  end

  def move_waypoint([{:L, units} | directions], position, waypoint_pos) do
    new_waypoint = rotate(units, waypoint_pos)
    move_waypoint(directions, position, new_waypoint)
  end

  def l1_dist(x, y) do
    abs(x) + abs(y)
  end

  def day12() do
    directions =
      "day12_input"
      |> AdventOfCode.read_file()
      |> Enum.map(fn movement ->
        [_, direction, units] = Regex.run(@move_regex, movement)
        direction = String.to_atom(direction)
        {units, _} = Integer.parse(units)
        {direction, units}
      end)

    {{lat, long}, direction} = move_ship(directions, {{0, 0}, :E})
    part1 = l1_dist(lat, long)

    {{lat_2, long_2}, waypoint} = move_waypoint(directions, {0, 0}, {10, 1})
    part2 = l1_dist(lat_2, long_2)

    {{{lat, long}, direction, part1}, {{lat_2, long_2}, waypoint, part2}}
  end
end
