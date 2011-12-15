require "castar/version"

module Castar
  require 'heyes' # the .bundle file
  include Heyes   # so we don't have to specify Castar::Heyes:: ...

  
  #convenience functions
  module_function #make all the following instance methods module methods

  def init_map( options={} )
    defaults = {:width => 90, :height => 90}
    options = defaults.merge(options)
    nrow = options[:height]
    ncol = options[:width]

    # set cost for each cell to 1
    a = Array.new(nrow).fill( Array.new(ncol).fill(1) )
    map = Map.new(ncol, nrow)
    a.each_with_index do |row, y| 
      row.each_with_index do |cost, x|
        map.setCost(x,y,cost)
      end
    end

    return map
  end


  def load_map(mapfile)
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

  def get_path(driver)
    path = [];
    (0..driver.getPathLength-1).each do |i|
      path << {:x => driver.getPathXAtIndex(i), :y =>  driver.getPathYAtIndex(i)}
    end
    path
  end

  def get_map_with_path(driver)
    path = get_path(driver)
    pathstr="\n"
    map = driver.getMap
    (0..map.height-1).each do |row|
      (0..map.width-1).each do |col|
        value = map.getCost(col,row)
        if(row==driver.nodeStart.y and col==driver.nodeStart.x)
          pathstr<<"|S"
        elsif(row==driver.nodeEnd.y and col==driver.nodeEnd.x)
          pathstr<<"|G"
        elsif(path.include?(:x => col, :y => row) )
          pathstr<<"|*"
        else
          pathstr<<"|#{value}"
        end
      end
      pathstr<<"|\n"
    end
    return pathstr
  end

end
