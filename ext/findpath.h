////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// STL A* Search implementation
// (C)2001 Justin Heyes-Jones
//
// Finding a path on a simple grid maze
// This shows how to do shortest path finding using A*

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef STLASTAR_H
#include "stlastar.h" // See header for copyright and usage information
#endif

#include <iostream>
#include <math.h>
#include <time.h>

#define DEBUG_LISTS 0
#define DEBUG_LIST_LENGTHS_ONLY 0

using namespace std;

// Global data
int DEBUG = 0;



// The world map
class Map{
  public:
    enum
    {
      MAP_OUT_OF_BOUNDS = 9,
      MAP_NO_WALK = 10
    };

    int width;
    int height;
    int* map;

    Map(int width = 90, int height = 90) : width(width), height(height)
  {
    map = new int[ width * height ];
    memset( map, 0, sizeof( int ) * width * height );
  }

    ~Map(){
      free(map);
    }

    // map helper functions
    int getCost( int x, int y )
    {
      if( x < 0 ||
          x >= width ||
          y < 0 ||
          y >= height
        )
      {
        return MAP_OUT_OF_BOUNDS;	 
      }
      return map[(y*width)+x];
    }

    void setCost( int x, int y, int value )
    {
      if( x < 0 ||
          x >= width ||
          y < 0 ||
          y >= height
        )
      {
        return;	 
      }
      map[(y*width)+x] = value;
    }
};

Map* MAP = NULL;
int NUMBER_OF_NEIGHBORS;

// Definitions

class MapSearchNode
{
  public:
  unsigned int x;	 // the (x,y) positions of the node
  unsigned int y;	

  MapSearchNode() { x = y = 0; }
  MapSearchNode( unsigned int px, unsigned int py ) { x=px; y=py; }

  float GoalDistanceEstimate( MapSearchNode &nodeGoal );
  bool IsGoal( MapSearchNode &nodeGoal );
  bool GetSuccessors( AStarSearch<MapSearchNode> *astarsearch, MapSearchNode *parent_node );
  float GetCost( MapSearchNode &successor );
  bool IsSameState( MapSearchNode &rhs );

  void PrintNodeInfo(); 
};

class HeyesDriver{
#define MAX_PATH_LENGTH 200
   int path_x[MAX_PATH_LENGTH];
   int path_y[MAX_PATH_LENGTH];
   int path_length;


  public:
   enum{
     FOUR_NEIGHBORS,
     EIGHT_NEIGHBORS
   };

   double timeElapsed;

    HeyesDriver(Map* map, int numMoves=FOUR_NEIGHBORS )
    {
      NUMBER_OF_NEIGHBORS = numMoves;
      MAP = map;
      timeElapsed = 0.0;
    }

    int run(int startx, int starty, int goalx, int goaly, int maxNodes = 10000)
    {

      //cout << "STL A* Search implementation\n(C)2001 Justin Heyes-Jones\n";

      // Our sample problem defines the world as a 2d array representing a terrain
      // Each element contains an integer from 0 to 5 which indicates the cost 
      // of travel across the terrain. Zero means the least possible difficulty 
      // in travelling (think ice rink if you can skate) whilst 5 represents the 
      // most difficult. 9 indicates that we cannot pass.

      // Create an instance of the search class...

      clock_t begin,end;
      begin=clock();
      AStarSearch<MapSearchNode> astarsearch(maxNodes);

      unsigned int SearchCount = 0;

      const unsigned int NumSearches = 1;
      while(SearchCount < NumSearches)
      {
        // Create a start state
        MapSearchNode nodeStart;
        nodeStart.x = startx; 
        nodeStart.y = starty;

        // Define the goal state
        MapSearchNode nodeEnd;
        nodeEnd.x = goalx; //rand()%MAP_WIDTH;						
        nodeEnd.y = goaly; //rand()%MAP_HEIGHT; 

        // Set Start and goal states

        astarsearch.SetStartAndGoalStates( nodeStart, nodeEnd );

        unsigned int SearchState;
        unsigned int SearchSteps = 0;

        do
        {
          SearchState = astarsearch.SearchStep();
          SearchSteps++;
        } while( SearchState == AStarSearch<MapSearchNode>::SEARCH_STATE_SEARCHING );

        if( SearchState == AStarSearch<MapSearchNode>::SEARCH_STATE_SUCCEEDED )
        {

          MapSearchNode *node = astarsearch.GetSolutionStart();

          int steps = 0;

          path_x[steps] = node->x;
          path_y[steps] = node->y;
          for( ;; )
          {
            steps++;
            node = astarsearch.GetSolutionNext();

            if( !node )
            {
              break;
            }

            path_x[steps] = node->x;
            path_y[steps] = node->y;
          };

          path_length = steps;
          // Once you're done with the solution you can free the nodes up
          astarsearch.FreeSolutionNodes();


        }
        else if( SearchState == AStarSearch<MapSearchNode>::SEARCH_STATE_FAILED ) 
        {
          cout << "Search terminated. Did not find goal state\n";
        }

        end=clock();
        timeElapsed = double(diffclock(end,begin));
        // Display the number of loops the search went through
        if (DEBUG){
          cout << "SearchSteps : " << SearchSteps << "\n";
          cout << "Time elapsed: " << timeElapsed << " ms"<< endl;
        }

        SearchCount ++;

        astarsearch.EnsureMemoryFreed();
      }

      return 0;
    }

    Map* getMap(){ return MAP; }

    int getPathLength(){
      return path_length;
    }
    int getPathYAtIndex( int i ){
      if ( i < path_length && i >= 0)
        return path_y[i];
      else
        return -1;
    }

    int getPathXAtIndex( int i ){
      if ( i < path_length && i >= 0 )
        return path_x[i];
      else
        return -1;
    }

    double diffclock(clock_t clock1,clock_t clock2)
    {
      double diffticks=clock1-clock2;
      double diffms=(diffticks*10)/CLOCKS_PER_SEC;
      return diffms;
    }
};



bool MapSearchNode::IsSameState( MapSearchNode &rhs )
{

  // same state in a maze search is simply when (x,y) are the same
  if( (x == rhs.x) &&
      (y == rhs.y) )
  {
    return true;
  }
  else
  {
    return false;
  }

}

void MapSearchNode::PrintNodeInfo()
{
  cout << "Node position : (" << x << ", " << y << ")" << endl;
}

// Here's the heuristic function that estimates the distance from a Node
// to the Goal. 

float MapSearchNode::GoalDistanceEstimate( MapSearchNode &nodeGoal )
{
  float xd = fabs(float(((float)x - (float)nodeGoal.x)));
  float yd = fabs(float(((float)y - (float)nodeGoal.y)));

  return xd + yd;
}

bool MapSearchNode::IsGoal( MapSearchNode &nodeGoal )
{

  if( (x == nodeGoal.x) &&
      (y == nodeGoal.y) )
  {
    return true;
  }

  return false;
}

// This generates the successors to the given Node. It uses a helper function called
// AddSuccessor to give the successors to the AStar class. The A* specific initialisation
// is done for each node internally, so here you just set the state information that
// is specific to the application
bool MapSearchNode::GetSuccessors( AStarSearch<MapSearchNode> *astarsearch, MapSearchNode *parent_node )
{

  int parent_x = -1; 
  int parent_y = -1; 

  if( parent_node )
  {
    parent_x = parent_node->x;
    parent_y = parent_node->y;
  }


  MapSearchNode NewNode;

  // push each possible move except allowing the search to go backwards

  int dx, dy;
  for ( dx=-1; dx<2; dx++ ){
    for ( dy=-1; dy<2; dy++){
      switch (NUMBER_OF_NEIGHBORS){
     
        case HeyesDriver::FOUR_NEIGHBORS:
          if (abs(dx)==abs(dy))
            continue;
          break;
        case HeyesDriver::EIGHT_NEIGHBORS:
          if (dx==0 && dy==0)
            continue;
      }

      if( (MAP->getCost( x+dx, y+dy ) < 9) 
          && !((parent_x == x+dx) && (parent_y == y+dy))
        ) 
      {
        NewNode = MapSearchNode( x+dx, y+dy );
        astarsearch->AddSuccessor( NewNode );
      }	

    }
  }
  return true;
}

// given this node, what does it cost to move to successor. In the case
// of our MAP the answer is the MAP terrain value at this node since that is 
// conceptually where we're moving

float MapSearchNode::GetCost( MapSearchNode &successor )
{
  return (float) MAP->getCost( x, y );

}


// Main
#if 0
int testmain(int startx, int starty, int goalx, int goaly)
{

  //cout << "STL A* Search implementation\n(C)2001 Justin Heyes-Jones\n";

  // Our sample problem defines the world as a 2d array representing a terrain
  // Each element contains an integer from 0 to 5 which indicates the cost 
  // of travel across the terrain. Zero means the least possible difficulty 
  // in travelling (think ice rink if you can skate) whilst 5 represents the 
  // most difficult. 9 indicates that we cannot pass.

  // Create an instance of the search class...

  clock_t begin,end;
  begin=clock();
  AStarSearch<MapSearchNode> astarsearch(10000);

  unsigned int SearchCount = 0;

  const unsigned int NumSearches = 1;
  while(SearchCount < NumSearches)
  {
    // Create a start state
    MapSearchNode nodeStart;
    nodeStart.x = startx; //rand()%MAP_WIDTH;
    nodeStart.y = starty; //rand()%MAP_HEIGHT; 

    // Define the goal state
    MapSearchNode nodeEnd;
    nodeEnd.x = goalx; //rand()%MAP_WIDTH;						
    nodeEnd.y = goaly; //rand()%MAP_HEIGHT; 

    // Set Start and goal states

    astarsearch.SetStartAndGoalStates( nodeStart, nodeEnd );

    unsigned int SearchState;
    unsigned int SearchSteps = 0;

    do
    {
      SearchState = astarsearch.SearchStep();

      SearchSteps++;

#if DEBUG_LISTS

      cout << "Steps:" << SearchSteps << "\n";

      int len = 0;

      cout << "Open:\n";
      MapSearchNode *p = astarsearch.GetOpenListStart();
      while( p )
      {
        len++;
#if !DEBUG_LIST_LENGTHS_ONLY			
        ((MapSearchNode *)p)->PrintNodeInfo();
#endif
        p = astarsearch.GetOpenListNext();

      }

      cout << "Open list has " << len << " nodes\n";

      len = 0;

      cout << "Closed:\n";
      p = astarsearch.GetClosedListStart();
      while( p )
      {
        len++;
#if !DEBUG_LIST_LENGTHS_ONLY			
        p->PrintNodeInfo();
#endif			
        p = astarsearch.GetClosedListNext();
      }

      cout << "Closed list has " << len << " nodes\n";
#endif

    }
    while( SearchState == AStarSearch<MapSearchNode>::SEARCH_STATE_SEARCHING );

    if( SearchState == AStarSearch<MapSearchNode>::SEARCH_STATE_SUCCEEDED )
    {
      //      cout << "Search found goal state\n";

      MapSearchNode *node = astarsearch.GetSolutionStart();

      //#if DISPLAY_SOLUTION
      //      cout << "Displaying solution\n";
      int steps = 0;

      //    node->PrintNodeInfo();
      path_x[steps] = node->x;
      path_y[steps] = node->y;
      for( ;; )
      {
        node = astarsearch.GetSolutionNext();

        if( !node )
        {
          break;
        }

        //       node->PrintNodeInfo();
        steps ++;
        path_x[steps] = node->x;
        path_y[steps] = node->y;
      };

      //      cout << "Solution steps " << steps << endl;
      path_length = steps;
      //#endif
      // Once you're done with the solution you can free the nodes up
      astarsearch.FreeSolutionNodes();


    }
    else if( SearchState == AStarSearch<MapSearchNode>::SEARCH_STATE_FAILED ) 
    {
      cout << "Search terminated. Did not find goal state\n";

    }

    end=clock();
    //    cout << "Time elapsed: " << double(diffclock(end,begin)) << " ms"<< endl;

    // Display the number of loops the search went through
    if (DEBUG){
      cout << "SearchSteps : " << SearchSteps << "\n";
    }

    SearchCount ++;

    astarsearch.EnsureMemoryFreed();
  }

  return 0;
}
#endif

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
