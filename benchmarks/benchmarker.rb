require 'benchmark_helper'
require 'rbench'

map1 = 'map90.0.txt'
map2 = 'map90.1.txt'
startx,starty,goalx,goaly=0,0,89,89

runner=AstarBenchmark.new(startx,starty,goalx,goaly, {:debug => false, :print_path => false, :profile =>false})

RBench.run(2) do
  column :big_obstacle
  column :small_obstacles
  
  report "using polaris" do
    big_obstacle { runner.test_polaris(map1) }
    small_obstacles { runner.test_polaris(map2) }
  end

#  report "using pure ruby" do
#    big_obstacle { runner.test_astar(map1) }
#    small_obstacles { runner.test_astar(map2) }
#  end

  report "using c++ implementation" do
    big_obstacle { runner.test_heyes(map1) }
    small_obstacles { runner.test_heyes(map2) }
  end

  report "using c++ implementation, eight neighbors" do
    options = { :number_neighbors => Heyes::HeyesDriver::EIGHT_NEIGHBORS}
    big_obstacle { runner.test_heyes(map1, options) }
    small_obstacles { runner.test_heyes(map2, options) }
  end
end

