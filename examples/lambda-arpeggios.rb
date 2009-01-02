alias :L :lambda

require 'rubygems'
require 'midiator'
require 'cb-music-theory' #git clone git://github.com/chrisbratlien/cb-music-theory.git
 
midi = MIDIator::Interface.new
midi.autodetect_driver

include MIDIator::Notes

def perform(root_note,scale,chord,progression,player, comment ='')
  puts "performing #{root_note.name} #{scale} #{chord} #{progression.join(',')} #{comment}\n"
  chords = progression.map{ |degree| root_note.send(scale).harmonized_chord(degree,chord) }
  chords.each{|chord| player[chord] }
  sleep(1)
end

peggy = L {|chord| 
  #peggy likes to play arpeggios
  a = chord.note_values
  a = a - [a.last] + a.reverse
  a.each{|note|  midi.play note, 0.1 }  
}

george = L {|chord| midi.play chord.note_values, 0.6 }

tony = L {|chord|
  a = chord.note_values
  midi.play a.slice(0..-3), 0.4
  a.slice(-2..-1).each{|note| midi.play note, 0.2}
}

clifton = L {|chord|
  a = chord.note_values
  midi.play a.slice(0..-4), 0.4
  a.slice(-3..-1).each{|note| midi.play note, 0.1}
}


# chord progression
 intro = [1,4,5,2]
 part_a = [8,4,8,4,9,7,2,5]
 part_b = [1,3,6,9,5,7,2,5]
 part_c = [6,2,7,5]
 ending = [8,4,1,7,8]
 prog = intro + part_a + part_b + part_c + ending

players = [george,tony,clifton,peggy]

perform(Note.new("C"), :phrygian_scale, :min7_chord, prog,tony)
perform(Note.new(54), :mixolydian_scale, :eleventh_chord, prog,clifton)
perform(Note.new("C"), :major_scale, :maj7_chord, prog,peggy)


2.times {
	cbnote = Note.new(rand(20) + 40)
	scale_method = Note.random_scale_method
	chord_method = cbnote.send(scale_method).valid_chord_names_for_degree(1).pick
	perform(cbnote,scale_method,chord_method,prog,players.pick)
}

#shush
(0..127).each{|n| midi.driver.note_off(n,0,0) }