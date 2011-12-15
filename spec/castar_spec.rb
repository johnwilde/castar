$: << File.join(File.expand_path(File.dirname(__FILE__)), '..')
require "castar"

include Heyes

describe "astar pathfinding wrapper" do
  it "should load a map" do
    num_column = 4
    num_row = 2
    map = Map.new(num_column, num_row)
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
    nrow = 2
    ncol = 4
    a = Array.new(nrow).fill( Array.new(ncol).fill(1) )
    @map = Map.new(ncol, nrow)
    a.each_with_index do |row, y| 
      row.each_with_index do |cost, x|
        @map.setCost(x,y,cost)
      end
    end
    @startx = 0
    @starty = 0
    @goalx = 3
    @goaly = 0
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

  it "should have tests for memory management"

  def get_path( driver )
    path = [];
    (0..driver.getPathLength-1).each do |i|
      path << {:x => driver.getPathXAtIndex(i), :y => driver.getPathYAtIndex(i)}
    end
    path
  end
end

