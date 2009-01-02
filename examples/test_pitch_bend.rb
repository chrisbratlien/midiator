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


def bend_note(midi,start,finish,sd=0.2,bd=0.1,fd=0.4)
  semitones = finish - start

  my_note = start

  #midi.driver.pitch_bend(1,8192) #return to center
  midi.driver.note_on(my_note,1,100)
  sleep(sd) #start note duration

	w_start = 8192  #centered pitch wheel
	w_stop = { -2 => 0, -1 => 4096, 0 => 8192, 1 => 12288, 2 => 16383}[semitones]
	tot_w = w_stop - w_start
	tot_dur = bd	#bend duration
	bend_steps = 20
	bend_dx = tot_w/bend_steps
	dur_dx = tot_dur / bend_steps
	w_start.step(w_stop,bend_dx) { |x|
		midi.driver.pitch_bend(1,x)
		sleep(dur_dx)
	}

  sleep(fd)	#finish note duration
  midi.driver.note_off(my_note,1,0)
  midi.driver.pitch_bend(1,8192) #return to center
end



midi = MIDIator::Interface.new


midi.autodetect_driver
midi.instruct_user!

#midi.use :dls_synth


include MIDIator::Notes

scale = [ C4, D4, E4, F4, G4, A4, B4, C5 ]

scale.each do |note|
	#midi.play note
	bend_note(midi,note,note-2)
end

scale.reverse.each do |note|
	bend_note(midi,note,note+2)
end
