require 'time'
require 'ruby-prof'
require 'polaris'
require 'two_d_grid_map'
require 'pry'
require 'castar'

class AstarBenchmark  
  def initialize(startx, starty, goalx, goaly, options={})
    @startx=startx
    @starty=starty
    @goalx=goalx
    @goaly=goaly
    defaults = {:debug => false, :print_path => true, :profile => false}
    options = defaults.merge(options)
    @debug=options[:debug]
    @print_path=options[:print_path]
    @profile=options[:profile]
  end

  def test_heyes(mapfile, options={})
    defaults = {:number_neighbors => Castar::HeyesDriver::FOUR_NEIGHBORS}
    options = defaults.merge(options)
    if @debug
      Castar.DEBUG = 1;
    end
    map = load_heyes_map(mapfile)
    driver =Castar::HeyesDriver.new(map, options[:number_neighbors] )
    driver.run(@startx, @starty, @goalx, @goaly)
    if @print_path
      pathstr = get_heyes_path(driver)
      print_path(pathstr, mapfile + "-heyes")
    end
  end

  def test_polaris(mapfile)
    map = load_polaris_map(mapfile)
    pather=Polaris.new(map)
    from=TwoDGridLocation.new(@startx, @starty)
    to=TwoDGridLocation.new(@goalx, @goaly)
    path=nil
    max_closed_nodes=100_000
    if @profile
      result = RubyProf.profile do 
        path=pather.guide(from,to,nil,max_closed_nodes)
      end
      print_graph(result, mapfile + "-polaris")
    else
      path=pather.guide(from,to,nil,max_closed_nodes)
    end

    if @print_path
      pathstr = get_polaris_path(map,path)
      print_path(pathstr, mapfile + "-polaris")
    end

    if @debug
      puts "Nodes considered: #{pather.nodes_considered}"
    end

  end

  def print_path(path, fname)
    File.open(fname + '-path.txt', 'w') do |file|
      file.puts(path)
    end
  end

  def print_graph(result, fname)
    printer=RubyProf::FlatPrinter.new(result)
    printer.print(File.new(fname + '.txt', 'w'), :min_percent => 5) 
  end

  def load_heyes_map(mapfile)
    map = nil
    y = 0
    File.open(mapfile) do |f|
      f.each_line do |line|
        entries = line.chomp.split(',')
        map ||= Castar::Map.new( entries.size, entries.size )
        x = 0
        line.chomp.split(',').each do |cost|
          map.setCost(x,y,cost.to_i)
          x += 1
        end
        y += 1
      end
    end
    return map
  end

  def load_polaris_map(mapfile)
    amap = []
    File.open(mapfile) do |f|
      f.each_line do |line|
        linearr = []
        line.chomp.split(',').each do |cost|
          linearr << cost.to_i
        end
        amap << linearr
      end
    end

    map=TwoDGridMap.new(amap.size, amap.first.size)
    amap.each_index do |row|
      amap[row].each_index do |col|
        if amap[row][col] == 9 
          obstacle = TwoDGridLocation.new(col,row)
          map.place(obstacle, "OBSTACLE")
        end
      end
    end
    return map
  end

  def get_heyes_path(driver)
    path = [];
    (0..driver.getPathLength-1).each do |i|
      path << [driver.getPathXAtIndex(i), driver.getPathYAtIndex(i)]
    end
    pathstr="\n"
    map = driver.getMap
    (0..map.height-1).each do |row|
      (0..map.width-1).each do |col|
        value = map.getCost(col,row)
        if(row==@startx and col==@starty)
          pathstr<<"|S"
        elsif(row==@goalx and col==@goaly)
          pathstr<<"|G"
        elsif(path.include?([col,row]) )
          pathstr<<"|*"
        else
          pathstr<<"|#{value}"
        end
      end
      pathstr<<"|\n"
    end
    return pathstr
  end

  def get_polaris_path(map,path)
    pathstr="\n"
    (0..map.h-1).to_a.each do |row|
      (0..map.w-1).to_a.each do |col|
        location=TwoDGridLocation.new(col,row)
        pathelement=PathElement.new(location)
        if map.blocked?(location)
          pathstr<<"|B"
        elsif(row==@startx and col==@starty)
          pathstr<<"|S"
        elsif(row==@goalx and col==@goaly)
          pathstr<<"|G"
        elsif(!path.nil? and path.include?(pathelement) )
          pathstr<<"|*"
        else
          pathstr<<"|O"
        end
      end
      pathstr<<"|\n"
    end
    return pathstr
  end
end
