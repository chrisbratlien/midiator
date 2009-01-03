#!/usr/bin/env ruby
#
# A simple example that plays the chromatic scale from C4 to C6 and back
# again.  Also shows how to use the MIDIator::Notes mixin.
#
# == Authors
#
# * Ben Bleything <ben@bleything.net>
#
# == Copyright
#
# Copyright (c) 2008 Ben Bleything
#
# This code released under the terms of the MIT license.
#

require 'rubygems'
require 'midiator'

def bend_note(midi,start,finish,sd=0.2,bd=0.1,fd=0.7)
  #I'm not sure this function is calling midi.driver.pitch_bend in the author's
  #intended way.  I'm a little confused by the bitwise shifting around that I
  #thought, or maybe still think, I needed in here.
  
  st = finish - start

  my_note = start
		
  midi.driver.pitch_bend(1,64 << 8) #return to center
  midi.driver.note_on(my_note,1,100)
  sleep(sd)

	w_start = 64
	w_stop = { -2 => 0, -1 => 32, 0 => 64, 1 =>96, 2 => 127}[st]
	tot_w = w_stop - w_start
	tot_dur = bd	
	bend_steps = 20
	bend_dx = tot_w/bend_steps
	dur_dx = tot_dur / bend_steps
	w_start.step(w_stop,bend_dx) { |x|
		midi.driver.pitch_bend(1,x << 8)
		sleep(dur_dx)
	}

  sleep(fd)	
  midi.driver.note_off(my_note,1,0)
  midi.driver.pitch_bend(1,64 << 8) #return to center

end



midi = MIDIator::Interface.new


midi.autodetect_driver
#midi.instruct_user!

#midi.use :dls_synth


include MIDIator::Notes


puts "(I'm only testing a msb range of 0x7f - 0x70)"
puts "Test #1: Call midi.driver.message(0xe0, lsb, msb) where lsb and msb each can be values between 0x00 and 0x7f"
puts "Get ready to start watching MIDI Patchbay (OSX) or MIDI-OX (Windows) for Pitch Bend events"
puts "Test begins in 5 seconds"
sleep(5)

wink = 0.0025

0x7F.downto(0x00) { |lsb|
  0x7F.downto(0x70) { |msb|
    puts "--------------"
    puts "lsb: #{lsb.to_s(16)} msb: #{msb.to_s(16)}" 
    midi.driver.message(MIDIator::Driver::PB | 0x00, lsb, msb)
    sleep(wink)    
    }
}

puts "---------------"
puts " FIRST TEST COMPLETE"
puts "------------------"

puts "Test #2: Try making some calls to midi.driver.pitch_bend(1,x) where x is 0x00 - 0x7F"
puts "Get ready to start watching MIDI Patchbay (OSX) or MIDI-OX (Windows) for Pitch Bend events"
puts "Test begins in 5 seconds"
sleep(5)

0x7F.downto(0x00) { |val|
  puts "--------------"
  puts "val: #{val.to_s(16)}" 
  midi.driver.pitch_bend(0,val)
  sleep(wink)    
  }


#scale = [ C4, D4, E4, F4, G4, A4, B4, C5 ]

#scale.each do |note|
#	#midi.play note
#	bend_note(midi,note,note-2)
#end

#scale.reverse.each do |note|
#	bend_note(midi,note,note+2)
#end
