#include "wait_seconds.h"

// cl /c wait_seconds.cpp
// link /dll wait_seconds.obj

// cl /c wait_seconds.cpp & link /dll wait_seconds.obj



void wait_seconds(double wait_time)
{
	clock_t goal_time;
	double remaining_time;
	double sleep_res = 25e-3; // sleep resolution is 10-20msec at best
	
	remaining_time = wait_time;

	if(wait_time >= sleep_res)
	{
		Sleep(wait_time*1e3);
		return;
	}

	goal_time = (clock_t)(remaining_time*1e3) + clock();
	while(goal_time > clock())
		;

}
