#!/usr/bin/env ruby

require 'benchmark_helper'

#mapfiles=['map1.txt','map2.txt','map3.txt']
#mapfiles.collect! {|x| './smallmap/' + x}
#mapfiles=[ 'map1.txt']
#startx,starty,goalx,goaly=0,0,0,0
mapfiles=['map90.0.txt']
startx,starty,goalx,goaly=0,0,89,89
runner=AstarBenchmark.new(startx,starty,goalx,goaly, {:debug =>true, :print_path =>true, :profile =>false})
mapfiles.each do |mapfile|
  puts "using: file #{mapfile}, start [#{startx},#{starty}], end [#{goalx},#{goaly}]"
  1.times do
#  runner.test_astar(mapfile)
# runner.test_polaris(mapfile)
  runner.test_heyes(mapfile, :number_neighbors => Castar::HeyesDriver::EIGHT_NEIGHBORS)
  end
end

#require 'astar_benchmark'
#mapfile='map90.0.txt'
#startx,starty,goalx,goaly=0,0,89,89
#runner=AstarBenchmark.new(startx,starty,goalx,goaly, {:debug =>true, :print_path =>true, :profile =>false})
#runner.test_heyes(mapfile)
