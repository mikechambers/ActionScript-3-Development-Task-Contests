ActionScript 3 Development Task Contest #1
http://www.mikechambers.com/blog/2009/11/10/actionscript-3-development-task-contest-1/

Mike Chambers
mesh@adobe.com

Change Log

Release 0.5 (November 12, 2009)
	-All circles are now drawn so the top left of their bounds is at 0,0.

Release 0.4 (November 11, 2009)
	-bounds argument is now required in ProximityManager constructor. This specifies the bounds of the collision detection / grid area.

Release 0.3 (November 11, 2009)
	-Fixed Release dates in README.txt
	-Added visual validation code to TestRunner.as (thanks to Sean Christmann for the help)
	-Made a minor change to how circles are drawn in Display Objects on stage.
		From : 
			disp.graphics.drawCircle( 0 , 0 , 5 );
		To:
			disp.graphics.drawCircle( 5 , 5 , 5 );

Release 0.2 (November 10, 2009)
	-Move SWF meta data from ProximityManager to TestRunner
	-Added README.txt file

Release 0.1 (November 10, 2009)
	-Initial Release