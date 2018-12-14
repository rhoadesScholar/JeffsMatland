#include "Mightex_LEDDriver_SDK.h"

// cl /c wait_seconds.cpp & link /dll wait_seconds.obj & cl LED_control.cpp Mightex_LEDDriver_SDK.lib wait_seconds.obj

// cl LED_control.cpp Mightex_LEDDriver_SDK.lib wait_seconds.obj
// usage LED_control.exe channel power [duration] [strobeperiod_if_relevant] [strobe_on_time] [strobe_pause_time]

void strobe(int DevHandle, int channel, int current, double duration, double strobeperiod)
{
	double elapsed_time, strobeperiod_usec;
	TLedChannelData	led_struct;

	//clock_t now, start_time;
	//elapsed_time=0;
	//start_time = clock();
	//while(elapsed_time < duration)
	//{
	//	MTUSB_LEDDriverSetNormalCurrent(DevHandle, channel,  current ); // turn on
	//	//printf("on %lf\n",strobeperiod);
	//	wait_seconds(strobeperiod); 
	//	//printf("off\n");
	//	MTUSB_LEDDriverSetNormalCurrent(DevHandle, channel, 0); // turn off
	//	
	//	wait_seconds(strobeperiod); 

	//	now = clock(); elapsed_time = (double)(now-start_time)/CLOCKS_PER_SEC; 
	//}
	//return;

    led_struct.Strobe_CurrentMax = 1000;
	strobeperiod_usec = strobeperiod*1e6;
	
	led_struct.Strobe_Profile[0][0] = current;
	led_struct.Strobe_Profile[0][1] = strobeperiod_usec;

	led_struct.Strobe_Profile[1][0] = 0;
	led_struct.Strobe_Profile[1][1] = strobeperiod_usec;

	led_struct.Strobe_Profile[2][0] = 0;
	led_struct.Strobe_Profile[2][1] = 0;
		
	led_struct.Strobe_RepeatCnt = duration/(2*strobeperiod);
    
	MTUSB_LEDDriverSetMode(DevHandle, channel, STROBE_MODE ); 
	MTUSB_LEDDriverSetStrobePara(DevHandle, channel, &led_struct );
	
	return;

}

int main(int argc, char *argv[])

{
	double duration, elapsed_time, time_remaining ;
	double strobeperiod, strobe_on_time, strobe_pause_time, strobe_cycle;
	int numDevices;
	int DevHandle;
	int channel, current;
	int DriverDeviceModuleType;
	clock_t now, start_time;
	TLedChannelData	led_struct;

	elapsed_time=0;
	start_time = clock();

	strobeperiod = -10;

	channel = 1;
	current = 1000;

	duration = 0;

	strobe_on_time = 0;
	strobe_pause_time = 0;

	sscanf(argv[1], "%d", &channel );
	if(argc > 2)
		sscanf(argv[2], "%d", &current);
	if(argc > 3)
		sscanf(argv[3], "%lf", &duration);
	if(argc > 4)
		sscanf(argv[4], "%lf", &strobeperiod );
	if(argc > 5)
	{
		sscanf(argv[5], "%lf", &strobe_on_time );
		sscanf(argv[6], "%lf", &strobe_pause_time );
	}

	// printf("%d %d %lf %lf", channel, current, duration, strobeperiod);

	// initialization
	MTUSB_LEDDriverResetDevice(0);
	numDevices = MTUSB_LEDDriverInitDevices(); 

	if(channel==0) // turn off everything
	{
		DevHandle = MTUSB_LEDDriverOpenDevice(0);
		DriverDeviceModuleType = MTUSB_LEDDriverDeviceModuleType(DevHandle ); 
		MTUSB_LEDDriverSetMode(DevHandle, channel, NORMAL_MODE ); 
		MTUSB_LEDDriverSetNormalCurrent(DevHandle, 1,  0 ); 
		MTUSB_LEDDriverSetNormalCurrent(DevHandle, 2,  0 ); 
		MTUSB_LEDDriverSetNormalCurrent(DevHandle, 3,  0 ); 
		MTUSB_LEDDriverSetNormalCurrent(DevHandle, 4,  0 ); 
		MTUSB_LEDDriverCloseDevice(DevHandle );

		if(numDevices == 2)
		{
			DevHandle = MTUSB_LEDDriverOpenDevice(1);
			DriverDeviceModuleType = MTUSB_LEDDriverDeviceModuleType(DevHandle ); 
			MTUSB_LEDDriverSetMode(DevHandle, channel, NORMAL_MODE ); 
			MTUSB_LEDDriverSetNormalCurrent(DevHandle, 1,  0 ); 
			MTUSB_LEDDriverSetNormalCurrent(DevHandle, 2,  0 ); 
			MTUSB_LEDDriverSetNormalCurrent(DevHandle, 3,  0 ); 
			MTUSB_LEDDriverSetNormalCurrent(DevHandle, 4,  0 ); 
			MTUSB_LEDDriverCloseDevice(DevHandle );
		}
		return(0);
	}


	if(numDevices == 1 || channel < 10)
	{
		DevHandle = MTUSB_LEDDriverOpenDevice(0);  
	}

    if(numDevices == 2 && channel > 10)
    {
        DevHandle = MTUSB_LEDDriverOpenDevice(1);
		channel = channel-10;
    }
	
	//printf("%d %d %d %d", DevHandle, channel, current, numDevices);
    
	DriverDeviceModuleType = MTUSB_LEDDriverDeviceModuleType(DevHandle ); 
	

	led_struct.Normal_CurrentMax = 1000;
    led_struct.Normal_CurrentSet = 0;
	MTUSB_LEDDriverSetNormalPara(DevHandle, channel, &led_struct);

	if(duration == 0) // turn on
	{
		MTUSB_LEDDriverSetMode(DevHandle, channel, NORMAL_MODE ); 
		MTUSB_LEDDriverSetNormalCurrent(DevHandle, channel,  current ); 
		return(0);
	}

	// normal mode
	if(strobeperiod <= 0)
	{
		MTUSB_LEDDriverSetMode(DevHandle, channel, NORMAL_MODE ); 
		MTUSB_LEDDriverSetNormalCurrent(DevHandle, channel,  current ); // turn on
		wait_seconds(duration); 
		MTUSB_LEDDriverSetNormalCurrent(DevHandle, channel, 0); // turn off

		// now = clock(); elapsed_time = (double)(now-start_time)/CLOCKS_PER_SEC; printf("%lf\n",elapsed_time);

		MTUSB_LEDDriverCloseDevice(DevHandle );

		return(0);
	}

	// continuous strobe
	if(strobe_pause_time == 0)
	{
		strobe(DevHandle, channel, current, duration, strobeperiod);
		MTUSB_LEDDriverCloseDevice(DevHandle );
		return(0);
	}

	// strobe w/ pauses
	strobe_cycle = strobe_on_time + strobe_pause_time;
	if(duration >= strobe_on_time)
	{
		time_remaining = duration;

		while(time_remaining > 0)
		{
			if(time_remaining >= strobe_cycle)
			{
				strobe(DevHandle, channel, current, strobe_on_time, strobeperiod);
				time_remaining = time_remaining - strobe_on_time;
				wait_seconds(strobe_pause_time);
				time_remaining = time_remaining - strobe_pause_time;
			}
			else
			{
				if(time_remaining > strobe_on_time)
				{
					strobe(DevHandle, channel, current, strobe_on_time, strobeperiod);
					time_remaining = time_remaining - strobe_on_time;
					wait_seconds(time_remaining);
					time_remaining = 0;
				}
				else
				{
					strobe(DevHandle, channel, current, time_remaining, strobeperiod);
					time_remaining = 0;
				}
			}
		}
	}
	else
	{
		MTUSB_LEDDriverSetNormalCurrent(DevHandle, channel,  current ); // turn on
		wait_seconds(duration); 
		MTUSB_LEDDriverSetNormalCurrent(DevHandle, channel, 0); // turn off
	}

	// now = clock(); elapsed_time = (double)(now-start_time)/CLOCKS_PER_SEC; printf("%lf\n",elapsed_time);

	MTUSB_LEDDriverCloseDevice(DevHandle );
	return(0);

}
