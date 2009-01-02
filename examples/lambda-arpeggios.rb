alias :L :lambda

require 'rubygems'
require 'midiator'
require 'cb-music-theory' #git clone git://github.com/chrisbratlien/cb-music-theory.git
 
midi = MIDIator::Interface.new
midi.autodetect_driver

include MIDIator::Notes

def perform(root_note, scale_name, chord_name, progression, player, comment ='')
  puts "performing #{root_note.name} #{scale_name} #{chord_name} #{progression.join(',')} #{comment}\n"
  progression.each{ |degree| 
    puts "playing chord on degree #{degree} "
    chord = root_note.send(scale_name).harmonized_chord(degree,chord_name)
    [player].flatten.pick[chord.note_values]  #picking a player lambda and then invoking it 
  }
  sleep(2)
end

peggy = L { |notes| 
  #peggy likes to play arpeggios
  (notes - [notes.last] + notes.reverse).each{|note|  midi.play note, 0.1 }  
}

hammett_up = L { |notes| 
  #hammett likes to play arpeggios like those guitar finger tappers
  (notes * [1,2].pick).each{|note| midi.play note, 0.075 }  
}

hammett_down = L { |notes| 
  #hammett likes to play arpeggios like those guitar finger tappers
  (notes.reverse * [1,2].pick).each{|note| midi.play note, 0.075 }  
}

hammett_bend = L { |notes|
#FIXME: can't seem to get pitch bends working
  bend_distance = notes.first - notes.last
  # n,c,v
  midi.driver.note_on(notes.last,1,100)

(0..100).each{|i| 
   midi.driver.bend(1,i*30000)
    puts i
    sleep(0.01)
  }
  
  sleep(0.1)
  #n,c,v
  midi.driver.note_off(notes.last,1,0)
  
}


bassguy1 = L { |notes| 
  [[0,0.4],[1,0.2],[0,0.2]].each{|i,dur| midi.play notes[i], dur}
}
bassguy2 = L { |notes| 
  [[0,0.4],[1,0.1],[0,0.1],[1,0.2]].each{|i,dur| midi.play notes[i], dur}
}

george = L { |notes| midi.play notes, 0.4 }

calmer = L { |notes| 
  [notes,notes.first].each{ |i| midi.play i, 0.4}  
}

inward_a = L { |notes|
 tmp = notes.clone
 while !tmp.empty?
   midi.play tmp.pop, 0.2
   tmp.reverse!
  end
}

inward_b = L { |notes|
 tmp = notes.clone.reverse
 while !tmp.empty?
   midi.play tmp.pop, 0.2
   tmp.reverse!
 end
}

outward_a = L { |notes|
  pivot = notes.size / 2
  tmp = notes[0,pivot].reverse + notes[pivot..-1].reverse
  while !tmp.empty?
    midi.play tmp.pop, 0.2
    tmp.reverse!
  end  
}

outward_b = L { |notes|
  pivot = notes.size / 2
  tmp = notes[0,pivot].reverse + notes[pivot..-1].reverse
  tmp.reverse!
  while !tmp.empty?
    midi.play tmp.pop, 0.2
    tmp.reverse!
  end  
}

tony = L { |notes|
  pivot = -1 * [3, notes.size-1].min
  midi.play notes[0..pivot], 0.4
  notes[pivot+1..-1].each{|note| midi.play note, 0.1}
}

clifton = L { |notes|
  pivot = -1 * [4, notes.size-1].min
  midi.play notes[0..pivot], 0.4
  notes[pivot+1..-1].each{|note| midi.play note, 0.1}
}


# map degrees to their next "allowed" degrees
# DANGER, THIS CHORD LADDER IS TOO SIMPLE, FORMULAIC, RIGID, ETC, AND NOT MEANT TO BE FOR EVERY TYPE OF SCALE
# BUT IT'S ALL I HAVE AT THIS POINT
# TODO: STOP SHOUTING
major_ladder = {}
  major_ladder[1] = [3,4,5,6] #pulled out of my ass
  major_ladder[2] = [5,7]
  major_ladder[3] = [6]
  major_ladder[4] = [5,7]
  major_ladder[5] = [1,6]
  major_ladder[6] = [2,4]
  major_ladder[7] = [1,6]

#get the next octave in (assuming 7-degree scales)
(8..15).each{|n| major_ladder[n] = major_ladder[n-7]}  

def next_degree(start,ladder)
  # also may pick from next octave (assuming 7-degree scales)
  ladder[start].map{|deg| [deg,deg + 7] }.flatten.pick
end


puts "If you have Propellerhead Reason, try picking one of these:"
puts "Combinator->Piano and Keyboard->Accoustic Piano->Concert Piano"
puts "Combinator->Combinator Patches->Guitar and Plucked->Misc Guitar and Plucked->Whale Calls"
puts
puts
puts "first, a few canned examples"

players = [george,tony,clifton,peggy,hammett_up,hammett_down,calmer,inward_a,inward_b,outward_a,outward_b,bassguy1,bassguy2]


# chord progression
prog = [1,4,5,2,8,4,8,4,9,7,2,5,1,3,6,9,5,7,2,5,6,2,7,5,8,4,1,7,8]

perform(Note.new("C"), :phrygian_scale, :min7_chord, prog,tony)
perform(Note.new(54), :mixolydian_scale, :eleventh_chord, prog,clifton)
perform(Note.new("F"), :major_scale, :maj9_chord, prog,peggy)

#perform(Note.new("F"), :major_scale, :maj9_chord, prog,hammett_bend) zzz doesn't work yet, don't know how to pitch bend yet
#perform(Note.new("F"), :major_scale, :maj9_chord, prog,inward_a)
#perform(Note.new("F"), :major_scale, :maj9_chord, prog,inward_b)
#perform(Note.new("F"), :major_scale, :maj9_chord, prog,outward_a)
#perform(Note.new("F"), :major_scale, :maj9_chord, prog,outward_b)
  
  
puts "now... time for some gambling with your ears"
50.times {
	note = Note.new(rand(20) + 40)
	scale_method = Note.random_scale_method
	chord_method = note.send(scale_method).valid_chord_names_for_degree(1).pick
  new_prog = [rand(7)+1]  #initial degree
  (rand(8) + 32).times { new_prog << next_degree(new_prog.last,major_ladder) }
	perform(note,scale_method,chord_method,new_prog,players)
}

#shush
(0..127).each{|n| midi.driver.note_off(n,0,0) }