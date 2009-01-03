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

midi = MIDIator::Interface.new


midi.autodetect_driver
#midi.instruct_user!
#midi.use :dls_synth


include MIDIator::Notes

wink = 0.0025

if midi.driver.class.to_s == "MIDIator::Driver::DLSSynth"
  puts "dls_synth found, skipping test #1"
else  
  puts "Test #1: Call midi.driver.message(0xe0, lsb, msb) where lsb and msb each can be values between 0x00 and 0x7f"
  puts "Hook up to o sound module and listen to the following Notes.  You should hear a pitch bend."
  sleep(2)

  midi.driver.note_on(60,0,100)
  midi.driver.note_on(64,0,100)
  midi.driver.note_on(67,0,100)

  0x7F.downto(0x00) { |val|
      #puts "val: #{val.to_s(16)}" 
      midi.driver.message(MIDIator::Driver::PB | 0x00, val, val)
      sleep(wink)    
  }

  midi.driver.note_off(60,0,0)
  midi.driver.note_off(64,0,0)
  midi.driver.note_off(67,0,0)
end


puts
puts
puts
puts "Test #2: Try making some calls to midi.driver.pitch_bend(channel,x) where x is 0x00 - 0x7F"
puts "This test wouldn't bend until I modified driver.rb"
sleep(2)

midi.driver.note_on(60,0,100)
midi.driver.note_on(64,0,100)
midi.driver.note_on(67,0,100)

0x7F.downto(0x00) { |val|
  #puts "val: #{val.to_s(16)}" 
  midi.driver.pitch_bend(0,val)
  sleep(wink)    
  }
midi.driver.note_off(60,0,0)
midi.driver.note_off(64,0,0)
midi.driver.note_off(67,0,0)

#hush
(0..127).each{|n| midi.driver.note_off(n,0,0) }
