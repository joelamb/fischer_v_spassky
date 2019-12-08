use_bpm 40

P = 0.125
N = 0.25
B = 0.25
R = 0.5
Q = 1
K = 2
O = 0

# Bobby Fischer vs Boris Spassky, World Chess Championship 1972, Game 6

moves = [
  [P,:c4],[P,:e6],
  [N,:f3],[P,:d5],
  [P,:d4],[N,:f6],
  [N,:c3],[B,:e7],
  [B,:g5],[O-O],
  [P,:e3],[P,:b6],
  [B,:b4],[P,:bb6],
  [P,:d5],[N,:d5],
  [B,:e7],[Q,:e7],
  [N,:d5],[P,:d5],
  [R,:c1],[B,:e6],
  [Q,:a4],[P,:c5],
  [Q,:a3],[R,:c8],
  [B,:bb5],[P,:a6],
  [P,:c5],[P,:c5],
  [O-O],[R,:a7],
  [B,:e2],[N,:d7],
  [N,:d4],[Q,:f8],
  [N,:e6],[P,:e6],
  [P,:e4],[P,:d4],
  [P,:f4],[Q,:e7],
  [P,:e5],[R,:bb8],
  [B,:c4],[K,:b8],
  [Q,:b3],[N,:f8],
  [P,:bb3],[P,:a5],
  [P,:f5,],[P,:f5],
  [R,:f5],[N,:b7],
  [R,:f1],[Q,:d8],
  [Q,:g3],[R,:e7],
  [P,:b4],[R,:bb7],
  [P,:e6],[R,:c7],
  [Q,:e5],[Q,:e8],
  [P,:a4],[Q,:d8],
  [R,:f2],[Q,:e8],
  [R,:f3],[Q,:d8],
  [B,:d3],[Q,:e8],
  [Q,:e4],[N,:f6],
  [R,:f6],[P,:f6],
  [R,:f6],[K,:g8],
  [B,:c4],[K,:b8],
  [Q,:f4]
]


define :transpose do |n|
  if n
    offset = (n-:c4)/12
    n = n - (12 * offset)
  end
end

define :melody do | moves|
  moves.each_with_index do |item, index|
    p,n = item
    n = transpose(n)
    if index > 0
      x = transpose(moves[index-1][1])
      if n == x
	n += [12,0,-12].choose
      end
      if p == 0.125
        midi n+7, sustain: p, vel_f: ((0.8-(p))/2)+0.1, port: "iac_driver_iac_bus_3"
      else
        midi n+7, sustain: p, vel_f: ((0.8-(p))/2)+0.1, port: "iac_driver_iac_bus_4"
      end
      sleep p
    end
  end
end

define :chords do | moves ,ratio = 0.9 |
  count = 0
  moves.each do |item|
    p, n = item;
    n = transpose(n)
    if(count % 1 === 0 && count != 0 )
      (chord(n-5, "dim7")).each.with_index do |n, index|
        midi n, sustain: 3, vel_f: rrand(0.1, 0.3), port: "iac_driver_iac_bus_1"
      end
      sleep p/2
      (chord(n-12, "add9")).each.with_index do |n, index|
	midi n, sustain: 3, vel_f: rrand(0.1, 0.3), port: "iac_driver_iac_bus_1"
      end
    end
    count = count + p
    sleep p
  end
end
      
      
define :bassline do | moves|
  moves.each_with_index do |item,index|
    p, n = item
    if n
      r = chord(n-24, :m7).mirror.shuffle
      if index % 8 == 0
	r.each do |n|
	  midi n, vel_f: rrand(0.2, 0.4), port: "iac_driver_iac_bus_2"
	  sleep 0.5
	end
      end
    end
  end
end

in_thread(name: :bass) do
  bassline(moves)
end

in_thread(name: :chords) do
  chords(moves)
end

in_thread(name: :cymbals) do
  wait 2
  (moves.length*2.4).round.times do
    with_swing 0.2, pulse:6 do
      midi 51, port:"iac_driver_iac_bus_5" if !one_in 8
      sleep 0.25
    end
  end
  midi 51, port:"iac_driver_iac_bus_5"
end

in_thread(name: :melody) do
  wait 6
  melody(moves)
end
