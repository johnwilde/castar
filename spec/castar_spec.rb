$: << File.join(File.expand_path(File.dirname(__FILE__)), '..')
require "castar"
include Castar

describe "astar pathfinding wrapper" do
  it "should load a map" do
    num_column = 4
    num_row = 2
    map = init_map(:width => num_column, :height => num_row)
    map.height.should eq(num_row)
    map.width.should eq(num_column)

    (0..num_column-1).each do |x|
     (0..num_row-1).each  do |y|
       num = rand(10)
       map.setCost(x,y,num)
       map.getCost(x,y).should eq(num)
     end
    end
    
    map.getCost(4,1).should eq(Map::MAP_OUT_OF_BOUNDS)
    map.getCost(1,2).should eq(Map::MAP_OUT_OF_BOUNDS)
    map.getCost(10,10).should eq(Map::MAP_OUT_OF_BOUNDS)
  end
  it "map saved in driver should work" do
    num_column = 4
    num_row = 2
    map1 = Map.new(num_column, num_row)
    driver = HeyesDriver.new(map1)
    map = driver.getMap
    map.height.should eq(num_row)
    map.width.should eq(num_column)

    (0..num_column-1).each do |x|
     (0..num_row-1).each  do |y|
       num = rand(10)
       map.setCost(x,y,num)
       map.getCost(x,y).should eq(num)
     end
    end
    
    map.getCost(4,1).should eq(Map::MAP_OUT_OF_BOUNDS)
    map.getCost(1,2).should eq(Map::MAP_OUT_OF_BOUNDS)
    map.getCost(10,10).should eq(Map::MAP_OUT_OF_BOUNDS)
  end

  before :each do
    @map = init_map(:width => 4, :height => 2)
    @startx = 0
    @starty = 0
    @goalx = 3
    @goaly = 0
  end

  it "should allow access to start and goal nodes" do
    driver = HeyesDriver.new(@map)
    driver.run(@startx, @starty, @goalx, @goaly)
    driver.nodeStart.x.should eq @startx
    driver.nodeStart.y.should eq @starty
    driver.nodeEnd.x.should eq @goalx
    driver.nodeEnd.y.should eq @goaly
  end

  it "should find a path when start and goal are the same" do
    driver = HeyesDriver.new(@map)
    driver.run(@startx, @starty, @startx, @starty)
    path = get_path(driver)
    path.length.should eq(1)
    path.first.should eq({:x => 0, :y => 0})
  end

  it "should find the shortest path (no obstacle) " do
    driver = HeyesDriver.new(@map)
    driver.run(@startx, @starty, @goalx, @goaly)
    path = get_path(driver)
    path.length.should eq(4)
    path.should eq([ {:x => 0, :y => 0}, {:x => 1, :y => 0}, {:x => 2, :y => 0}, {:x => 3, :y => 0}])
  end

  it "should find the shortest path allowing diagonal moves(no obstacle) " do
    driver = HeyesDriver.new(@map, HeyesDriver::EIGHT_NEIGHBORS)
    @starty=1
    driver.run(@startx, @starty, @goalx, @goaly)
    path = get_path(driver)
    path.length.should eq(4)
    #path.should eq([ {:x => 0, :y => 0}, {:x => 1, :y => 0}, {:x => 2, :y => 0}, {:x => 3, :y => 0}])
  end

  it "should find the shortest path (obstacle) " do
    @map.setCost(1,0,Map::MAP_NO_WALK)
    driver = HeyesDriver.new(@map)
    driver.run(@startx, @starty, @goalx, @goaly)
    path = get_path(driver)
    path.length.should eq(6)
  end

  it "should load mapfile and find path" do
    map =load_map('./spec/map_20.txt')
    astar = HeyesDriver.new(map, HeyesDriver::EIGHT_NEIGHBORS)
    astar.run(0,0,19,19)
    astar.getPathLength.should eq 28 
  end

  it "should have tests for memory management"

end

