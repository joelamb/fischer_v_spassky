use_bpm 55

bass = "/Users/joelamb/Documents/SonicPi/chess-sonification/fischer_v_spassky/samples/double-bass-c-2.wav"
trumpet = "/Users/joelamb/Documents/SonicPi/chess-sonification/fischer_v_spassky/samples/trumpet.wav"

P = 0.125
N = 0.25
B = 0.25
R = 0.5
Q = 1
K = 2
O = 0

# Bobby Fischer vs Boris Spassky, World Chess Championship 1972, Game 6

moves = [
          [P,:c4],
          [P,:e6],[N,:f3],[P,:d5],[P,:d4],[N,:f6],[N,:c3],[B,:e7],
          [B,:g5],
          [O-O],
          [P,:e3],[P,:b6],[B,:b4],[P,:bb6],[P,:d5],[N,:d5],
          [B,:e7],[Q,:e7],[N,:d5],[P,:d5],[R,:c1],[B,:e6],[Q,:a4],[P,:c5],
          [Q,:a3],[R,:c8],[B,:bb5],[P,:a6],[P,:c5],[P,:c5],
          [O-O],
          [R,:a7],
          [B,:e2],[N,:d7],[N,:d4],[Q,:f8],[N,:e6],[P,:e6],[P,:e4],[P,:d4],
          [P,:f4],[Q,:e7],[P,:e5],[R,:bb8],[B,:c4],[K,:b8],[Q,:b3],[N,:f8],
          [P,:bb3],[P,:a5],[P,:f5,],[P,:f5],[R,:f5],[N,:b7],[R,:f1],[Q,:d8],
          [Q,:g3],[R,:e7],[P,:b4],[R,:bb7],[P,:e6],[R,:c7],[Q,:e5],[Q,:e8],
          [P,:a4],[Q,:d8],[R,:f2],[Q,:e8],[R,:f3],[Q,:d8],[B,:d3],[Q,:e8],
          [Q,:e4],[N,:f6],[R,:f6],[P,:f6],[R,:f6],[K,:g8],[B,:c4],[K,:b8],[Q,:f4]
        ]


define :transpose do |n|
  if n
    offset = (n-:c4)/12
    n = n - (12 * offset)
  end
end

  define :melody do | moves, ratio = 0.9 |
    moves.each_with_index do |item, index|
      puts item
      if item[0] == 0
        sample trumpet, rpitch: -1
        sleep 2
      else
        p,n = item
        n = transpose(n)
        if index > 0
          x = transpose(moves[index-1][1])
          if n == x
            n += [12,0,-12].choose
          end
          play n, sustain: ratio * p, release: (1-ratio) * p, amp: ((2-p)/2)+0.5
          sleep p
        end
      end
    end
  end

define :chords do | moves ,ratio = 0.9 |
  count = 0
  moves.each do |item|
    p, n = item;
    n = transpose(n)
    if(count % 1 === 0 && count != 0 )
      play chord(n-5, "dim7"), release: p, amp: 2
      sleep p/2
      play chord(n-12, "add9"), release: 5*p, amp: 1
    end
    count = count + p
    sleep p
  end
end

define :bassline do | moves, ratio = 0.9|
  moves.each_with_index do |item,index|
    p, n = item
    if n
      n = transpose(n)
      r = chord(n-24, :m7).mirror.shuffle
      if index % 8 == 0
        r.each do |n|
          sample bass, rpitch: n-36, start: 0.05, finish: 0.2, lpf: 70, amp: 0.5
          play n, amp: 0.5
          sleep 0.5
        end
      end
    end
  end
end

with_fx :reverb do
  in_thread(name: :lead) do
    wait 4
    with_synth :piano do
      melody(moves)
    end
  end

  in_thread(name: :chords) do
    with_synth :piano do
      chords(moves)
    end
  end


  in_thread(name: :bass) do
    with_synth :fm do
      with_synth_defaults depth: 0.5, cutoff: 100, sustain: 0.2, release: 0.5, amp: rrand(0.8, 1) do
        bassline(moves)
      end
    end
  end

  in_thread(name: :cymbals) do
    wait 2
    (moves.length*2.8).round.times do
      with_swing 0.1, pulse:4 do
        sample :drum_cymbal_soft, sustain: rrand(0.2, 0.3), release: rrand(0.3, 0.6), amp: rrand(0.15, 0.25) if !one_in 8
        sleep 0.25
      end
    end
    sample :drum_splash_soft, amp: 0.1
  end

  in_thread(name: :drums) do
    wait 1
    sample :drum_splash_soft, amp: 0.1
    with_fx :echo, phase: 0.325, decay: 3 do
      sample :drum_snare_soft, amp: rrand(0.6, 0.8)
      sleep 1
    end
    (moves.length*0.33).round.times do
      sample :bd_fat if !one_in 3
      sleep 0.5 if !one_in 8
      sample :bd_fat if !one_in 5
      sleep 0.25 if !one_in 3
      with_fx :echo, phase: 0.625, decay: 2 do
        sample :drum_snare_soft, amp: rrand(0.6, 0.8) if one_in 2
      end
      sleep 0.75 if !one_in 5
      sample :bd_fat if !one_in 8
      sleep 0.75 if one_in 2
    end
    sample :drum_splash_soft, amp: 0.5
  end
end
