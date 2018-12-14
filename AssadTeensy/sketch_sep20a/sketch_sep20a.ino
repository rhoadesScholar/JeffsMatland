/*********************************************************************
  Arduino state machine code for Pavlovian-Operant Training (mice)
  
  Training Paradigm and Architecture    - Allison Hamilos (ahamilos@g.harvard.edu)
  Optogenetics Control System       - Allison Hamilos (ahamilos@g.harvard.edu)
  Matlab Serial Communication Interface - Ofer Mazor
  State System Architecture             - Lingfeng Hou (lingfenghou@g.harvard.edu)

  Created       9/16/16 - ahamilos
  Last Modified 6/20/18 - ahamilos
  
  (prior version: Pav-Op-FIBER_camera_ChR2)
  New to THIS version:
  --> Added capacity to stimulate at non-zero times with probability-UI controlled
      If stim time is not 0, then there's a dice throw if you make it to the time specified before lick (good)
  --> Added capacity for accelerometer-based lick ckt (ready to test)
  --> Stop stim when lick (good)
    -- I will write a line to track just the first lick on a digital line and send this to the optocontroller

  Update Hx:
  --> Added pin to trigger ChR2 stimulation and stim parameters (time of onset in trial)
  --> fixed position of first_lick_received = false;                 // Reset tracker of first licks to prewindow
  --> Added a IR houselamp on pin 0 
  --> Added a falling edge for IR LED
  --> Added a 3.3V src to power the camera I/O
 (note had previously used Pav-Op-FIBER_emg on Rig 1/2 for emg/acc)

  --> Add trigger for Arduino to match Matlab and Arduino timestamps
  New to prior version: Make quinine or enforced no lick more flexible - 
  can choose a separate enforced no lick window before the opening of the reward window
  that is distinct from the prewindow opening
  --> Create flexible shock and abort add ons
  --> Create a joint pav-op condition in which a fixed % of trials are pav vs op
  --> Added an event marker to track whether trial is pavlovian or operant
  --> Mixed trial type now decided at TRIAL INIT
  --> Added new Hybrid Pav-Op state - is op if lick before target, is pav if wait beyond target. (AH 11/12/16)
  --> Add event markers for first lick in window (1st lick abort, 1st lick reward, 1st reward late)
  ------------------------------------------------------------------
  COMPATIBILITY REPORT:
    Matlab HOST: Matlab 2016a - FileName = MouseBehaviorInterface.m (depends on ArduinoConnection.m)
    Arduino:
      Default: TEENSY
      Others:  UNO, TEENSY, DUE, MEGA
  ------------------------------------------------------------------
  Reserved:
    
    Event Markers: 0-16
    States:        0-8
    Result Codes:  0-3
    Parameters:    0-24
  ------------------------------------------------------------------
  Task Architecture: Pavlovian-Operant

  Init Trial                (event marker = 0)
    -  House Lamp OFF       (event marker = 1)
    -  Random delay
  Trial Body
    -  Cue presentation     (event marker = 2)
    -  Pre-window interval
    -  Window opens         (event marker = 3)
    -  1st half response window
    -  Target time          (event marker = 4)    - (Pavlovian-only) reward dispensed (event marker = 8)
    -  2nd half response window
    -  Window closes        (event marker = 5)
    -  Post-window Interval                       - trial aborted at this point           
  End Trial                 (event marker = 6)    - House lamps ON (if not already)
    -  ITI                  (event marker = 7)

  Behavioral Events:
    -  Lick                 (event marker = 8)
    -  Reward dispensed     (event marker = 9)
    -  Quinine dispensed    (event marker = 10)
    -  Waiting for ITI      (event marker = 11)   - enters this state if trial aborted by behavioral error, House lamps ON
    -  Correct Lick         (event marker = 12)   - first correct lick in the window
    -  1st Lick             (event marker = 16)   - first relevant lick in trial

  Trial Type Markers:
    -  Pavlovian            (event marker = 13)   - marks current trial as Pavlovian
    -  Operant              (event marker = 14)   - marks current trial as Operant
    -  Hybrid               (event marker = 15)   - marks current trial as Hybrid
  --------------------------------------------------------------------
  States:
    0: _INIT                (private) 1st state in init loop, sets up communication to Matlab HOST
    1: IDLE_STATE           Awaiting command from Matlab HOST to begin experiment
    2: TRIAL_INIT           House lamp OFF, random delay before cue presentation
    3: PRE_WINDOW           (+/-) Enforced no lick before response window opens
    4: RESPONSE_WINDOW      First lick in this interval rewarded (operant). Reward delivered at target time (pavlov)
    5: POST_WINDOW          Checking for late licks
    6: REWARD               Dispense reward, wait for trial Timeout
    7: ABORT_TRIAL          Behavioral Error - House lamps ON, await trial Timeout
    8: INTERTRIAL           House lamps ON (if not already), write data to HOST and DISK
  ---------------------------------------------------------------------
  Result Codes:
    0: CODE_CORRECT         First lick within response window               
    1: CODE_EARLY_LICK      Early lick -> Abort (Enforced No-Lick Only)
    2: CODE_LATE_LICK       Late Lick  -> Abort (Operant Only)
    3: CODE_NO_LICK         No Response -> Time Out
  ---------------------------------------------------------------------
  Parameters:
    0:  _DEBUG              (private) 1 to enable debug messages to HOST
    1:  HYBRID              1 to overrule pav/op - is op if before target, pav if target reached
    2:  PAVLOVIAN           1 to enable Pavlovian Mode
    3:  OPERANT             1 to enable Operant Mode
    4:  ENFORCE_NO_LICK     1 to enforce no lick in the pre-window interval
    5:  INTERVAL_MIN        Time to start of reward window (ms)
    6:  INTERVAL_MAX        Time to end of reward window (ms)
    7:  TARGET              Target time (ms)
    8:  TRIAL_DURATION      Total alloted time/trial (ms)
    9:  ITI                 Intertrial interval duration (ms)
    10: RANDOM_DELAY_MIN    Minimum random pre-Cue delay (ms)
    11: RANDOM_DELAY_MAX    Maximum random pre-Cue delay (ms)
    12: CUE_DURATION        Duration of the cue tone and LED flash (ms)
    13: REWARD_DURATION     Duration of reward dispensal (ms)
    14: QUININE_DURATION    Duration of quinine dispensal (ms)
    15: QUININE_TIMEOUT     Minimum time between quinine deterrants (ms)
    16: QUININE_MIN         Minimum time after cue before quinine available (ms)
    17: QUININE_MAX         Maximum time after cue before quinine turns off (ms)
    18: SHOCK_ON            1 to connect tube shock circuit
    19: SHOCK_MIN           Miminum time after cue before shock connected (ms)
    20: SHOCK_MAX           Maxumum time after cue before shock disconnected (ms)
    21: EARLY_LICK_ABORT    1 to abort trial with early lick
    22: ABORT_MIN           Minimum time after cue before early lick aborts trial (ms)
    23: ABORT_MAX           Maximum time after cue when abort available (ms)
    24: PERCENT_PAVLOVIAN   Percent of mixed trials that should be pavlovian (decimal)
    25: PERCENT_CHR2_TRIALS % of trials (0-1) to stimulate with ChR2
    26: CHR2_STIM_TIME      0 ms for at cue, -time for lights-off, in ms wrt cue

  ---------------------------------------------------------------------
    Incoming Message Syntax: (received from Matlab HOST)
      "(character)#"        -- a command
      "(character int1 int2)# -- update parameter (int1) to new value (int2)"
      Command characters:
        P  -- parameter
        O# -- HOST has received updated paramters, may resume trial
        Q# -- quit and go to IDLE_STATE
        G# -- begin trial (from IDLE_STATE)
  ---------------------------------------------------------------------
    Outgoing Message Syntax: (delivered to Matlab HOST)
      ONLINE:  
        "~"                           Tells Matlab HOST arduino is running
      STATES:
        "@ (enum num) stateName"      Defines state names for Matlab HOST
        "$(enum num) num num"         State-number, parameter, value
 -                                          param = 0: current time
 -                                          param = 1: result code (enum num)
      EVENT MARKERS:
        "+(enum num) eventMarker"     Defines event markers with string
        "&(enum num) timestamp"       Event Marker with timestamp

      RESULT CODES:
      "* (enum num) result_code_name" Defines result code names with str 
      "` (enum num of result_code)"   Send result code for trial to Matlab HOST

      MESSAGE:
        "string"                      String to Matlab HOST serial monitor (debugging) 
  ---------------------------------------------------------------------
  STATE MACHINE
    - States are written as individual functions
    - The main loop calls the appropriate state function depending on current state.
    - A state function consists of two parts
     - Action: executed once when first entering this state.
     - Transitions: evaluated on each loop and determines what the next state should be.
*********************************************************************/



/*****************************************************
  Global Variables
*****************************************************/

/*****************************************************
Arduino Pin Outs (Mode: TEENSY)
*****************************************************/

// Digital OUT
#define PIN_HOUSE_LAMP     6   // House Lamp Pin         (DUE = 34)  (MEGA = 34)  (UNO = 5?)  (TEENSY = 6?)
#define PIN_LED_CUE        4   // Cue LED Pin            (DUE = 35)  (MEGA = 28)  (UNO =  4)  (TEENSY = 4)
#define PIN_REWARD         7   // Reward Pin             (DUE = 37)  (MEGA = 52)  (UNO =  7)  (TEENSY = 7)
#define PIN_SHOCK          13  // Shock Pin*** modified so can use line 1 for first lick (MEGA = 22)              (TEENSY = 9)
#define PIN_TRIGGER        12  // Clock Trigger Pin*** note, changed to unused!               (TEENSY = 3)  ** Links CED time to Arduino/Matlab time
#define PIN_IR_LED_TRIGGER 9   // IR LED Trigger Pin
#define PIN_3_3            11  // 3.3V src
#define PIN_IR_HOUSE     0   // IR Houselamp for camera
#define PIN_CHR2           10  // Trigger 2nd Arduino for ChR2 stim
#define PIN_ALICK_OUT    3   // Sends analog lick receipt to CED/Ripple/Intan
#define PIN_FIRST_LICK     1   // Sends receipt of first lick -- used to halt stimulation

// PWM OUT --- n.b! 2 tones can't play at the same time!
#define PIN_SPEAKER        5    // Speaker Pin            (DUE =  2)  (MEGA =  8)  (UNO =  9)  (TEENSY = 5)
#define PIN_QUININE        14   // Quinine Pin            (DUE = 22)  (MEGA =  9)  (UNO =  8)  (TEENSY = 8) ** Must be PWM

// Digital IN
#define PIN_LICK           2    // Lick Pin               (DUE = 36)  (MEGA =  2)  (UNO =  2)  (TEENSY = 2)
#define PIN_RECEIPT        8    // Confirms Optogenetics Command Received

// Analog IN
#define PIN_LICK_ACC       A4   // Accelerometer-Based Lick Pin                          (TEENSY = A4)


/*****************************************************
Enums - DEFINE States
*****************************************************/
// All the states
enum State
{
  _INIT,                // (Private) Initial state used on first loop. 
  IDLE_STATE,           // Idle state. Wait for go signal from host.
  INIT_TRIAL,           // House lamp OFF, random delay before cue presentation
  PRE_WINDOW,           // (+/-) Enforced no lick before response window opens
  RESPONSE_WINDOW,      // First lick in this interval rewarded (operant). Reward delivered at target time (pavlov)
  POST_WINDOW,          // Check for late licks
  REWARD,               // Dispense reward, wait for trial Timeout
  ABORT_TRIAL,          // Behavioral Error - House lamps ON, await trial Timeout
  INTERTRIAL,           // House lamps ON (if not already), write data to HOST and DISK, receive new params
  _NUM_STATES           // (Private) Used to count number of states
};

// State names stored as strings, will be sent to host
// Names cannot contain spaces!!!
static const char *_stateNames[] = 
{
  "_INIT",
  "IDLE_STATE",
  "INIT_TRIAL",
  "PRE_WINDOW",
  "RESPONSE_WINDOW",
  "POST_WINDOW",
  "REWARD",
  "ABORT_TRIAL",
  "INTERTRIAL"
};

// Define which states allow param update
static const int _stateCanUpdateParams[] = {0,1,0,0,0,0,0,0,1}; 
// Defined to allow Parameter upload from host during IDLE_STATE and INTERTRIAL


/*****************************************************
Event Markers
*****************************************************/
enum EventMarkers
/* You may define as many event markers as you like.
    Assign event markers to any IN/OUT event
    Times and trials will be defined by global time, 
    which can be parsed later to validate time measurements */
{
  EVENT_TRIAL_INIT,       // New trial initiated
  EVENT_HOUSE_LAMP_OFF,   // House lamp off - start random pre-cue delay
  EVENT_CUE_ON,           // Begin cue presentation
  EVENT_WINDOW_OPEN,      // Response window open
  EVENT_TARGET_TIME,      // Target time
  EVENT_WINDOW_CLOSED,    // Response window closed
  EVENT_TRIAL_END,        // Trial end
  EVENT_ITI,              // Enter ITI
  EVENT_LICK,             // Lick detected
  EVENT_REWARD,           // Reward dispensed
  EVENT_QUININE,          // Quinine dispensed
  EVENT_ABORT,            // Abort (behavioral error)
  EVENT_CORRECT_LICK,     // Marks the "Peak" Lick (First within window)
  EVENT_PAVLOVIAN,        // Marks trial as Pavlovian
  EVENT_OPERANT,          // Marks trial as Operant
  EVENT_HYBRID,           // Marks trial as Hybrid
    EVENT_FIRST_LICK,       // Marks first relevant lick in trial (abort, reward, or late)
    EVENT_CH2R_STIM_REQ,  // Marks time of stim command to Optogenetics Arduino
    EVENT_CH2R_STIM_END,  // Marks receipt of stim command from Optogenetics Arduino
  _NUM_OF_EVENT_MARKERS
};

static const char *_eventMarkerNames[] =    // * to define array of strings
{
  "TRIAL_INIT",
  "HOUSE_LAMP_OFF",
  "CUE_ON",
  "WINDOW_OPEN",
  "TARGET_TIME",
  "WINDOW_CLOSED",
  "TRIAL_END",
  "ITI",
  "LICK",
  "REWARD",
  "QUININE",
  "ABORT",
  "CORRECT_LICK",
  "PAVLOVIAN",
  "OPERANT",
  "HYBRID",
    "FIRST_LICK",
    "CHR2_STIM_REQ",
    "CH2R_STIM_END"
};

/*****************************************************
Result codes
*****************************************************/
enum ResultCode
{
  CODE_CORRECT,                              // Correct    (1st lick w/in window)
  CODE_EARLY_LICK,                           // Early Lick (-> Abort in Enforced No-Lick)                         // NOTE: Early lick should be removed
  CODE_LATE_LICK,                            // Late Lick  (-> Abort in Operant)
  CODE_NO_LICK,                              // No Lick    (Timeout -> ITI)
  CODE_CORRECT_OP_HYBRID,                    // Licked before target in window
  CODE_PAVLOV_HYBRID,                        // Reached target time and dispensed before lick
  _NUM_RESULT_CODES                          // (Private) Used to count how many codes there are.
};

// We'll send result code translations to MATLAB at startup
static const char *_resultCodeNames[] =
{
  "CORRECT",
  "EARLY_LICK",
  "LATE_LICK",
  "NO_LICK",
  "CORRECT_OP_HYBRID",
  "PAVLOV_HYBRID"
};


/*****************************************************
Audio cue frequencies
*****************************************************/
enum SoundEventFrequencyEnum
{
  TONE_REWARD  = 5050,             // Correct tone: (prev C8 = 4186)
  TONE_ABORT   = 440,              // Error tone: (prev C3 = 131)
  TONE_CUE     = 3300,             // 'Start counting the interval' cue: (prev C6 = 1047)
  TONE_ALERT   = 131,              // Reserved for system errors
  TONE_QUININE = 10000,            // Quinine delivery -- using tone so don't require own state to deliver for set time
    TONE_TRIGGER = 12345             // A brief pulse of this frequency marks when Arduino starts to match Arduino start time
};

/*****************************************************
Parameters that can be updated by HOST
*****************************************************/
// Storing everything in array _params[]. Using enum ParamID as array indices so it's easier to add/remove parameters. 
enum ParamID
{
  _DEBUG,                         // (Private) 1 to enable debug messages from HOST. Default 0.
  ANALOG_LICK,          // Analog lick ckt mode - 0 or 1
  A_LICK_THRESH,          // Analog lick ckt threshold [0, 1023]
  HYBRID,                         // 1 to overrule pav or op -- allows operant pre-target lick, but is otherwise pavlovian
  PAVLOVIAN,                      // 1 to enable Pavlovian Mode
  OPERANT,                        // 1 to enable Operant Mode (exclusive to PAVLOVIAN)
  ENFORCE_NO_LICK,                // 1 to enforce no lick in the pre-window interval
  INTERVAL_MIN,                   // Time to start of reward window (ms)
  INTERVAL_MAX,                   // Time to end of reward window (ms)
  TARGET,                         // Target time (ms)
  TRIAL_DURATION,                 // Total alloted time/trial (ms)
  ITI,                            // Intertrial interval duration (ms)
  RANDOM_DELAY_MIN,               // Minimum random pre-Cue delay (ms)
  RANDOM_DELAY_MAX,               // Maximum random pre-Cue delay (ms)
  CUE_DURATION,                   // Duration of the cue tone and LED flash (ms)
  REWARD_DURATION,                // Duration of reward dispensal (ms)
  QUININE_DURATION,               // Duration of quinine dispensal (ms)
  QUININE_TIMEOUT,                // Minimum time between quinine dispensals (ms)
  QUININE_MIN,                    // Minimum time post cue before quinine available (ms)
  QUININE_MAX,                    // Maximum time post cue before quinine not available (ms)
  SHOCK_ON,                       // 1 to enable Shock Mode
  SHOCK_MIN,                      // Minimum time post cue before shock ckt connected (ms)
  SHOCK_MAX,                      // Maximum time post cue before shock ckt disconnected (ms)
  EARLY_LICK_ABORT,               // 1 to Abort with Early Licks in window (ms)
  ABORT_MIN,                      // Miminum time post cue before lick causes abort (ms)
  ABORT_MAX,                      // Maximum time post cue before abort unavailable (ms)
  PERCENT_PAVLOVIAN,              // Percent of mixed trials that are pavlovian (decimal)
  PERCENT_CHR2_TRIALS,      // Percent of trials to stimulate ChR2 (0-100)
  CHR2_STIM_TIME,         // Time to begin stimulation
  P_STIM_GIVEN_TIME,        // Probability of stim conditioned on having reached a longer time
  _NUM_PARAMS                     // (Private) Used to count how many parameters there are so we can initialize the param array with the correct size. Insert additional parameters before this.
}; //**** BE SURE TO ADD NEW PARAMS TO THE NAMES LIST BELOW!*****//

// Store parameter names as strings, will be sent to host
// Names cannot contain spaces!!!
static const char *_paramNames[] = 
{
  "_DEBUG",
  "ANALOG_LICK",
  "A_LICK_THRESH",
  "HYBRID",
  "PAVLOVIAN",
  "OPERANT",
  "ENFORCE_NO_LICK",
  "INTERVAL_MIN",
  "INTERVAL_MAX",
  "TARGET",
  "TRIAL_DURATION",
  "ITI",
  "RANDOM_DELAY_MIN",
  "RANDOM_DELAY_MAX",
  "CUE_DURATION",
  "REWARD_DURATION",
  "QUININE_DURATION",
  "QUININE_TIMEOUT",
  "QUININE_MIN",
  "QUININE_MAX",
  "SHOCK_ON",
  "SHOCK_MIN",
  "SHOCK_MAX",
  "EARLY_LICK_ABORT",
  "ABORT_MIN",
  "ABORT_MAX",
  "PERCENT_PAVLOVIAN",
  "PERCENT_CHR2_TRIALS",
  "CHR2_STIM_TIME",
  "P_STIM_GIVEN_TIME"
}; //**** BE SURE TO INIT NEW PARAM VALUES BELOW!*****//

// Initialize parameters
long _params[_NUM_PARAMS] = 
{
  0,                              // _DEBUG
  0,                              // ANALOG LICK CKT MODE
  512,              // A_LICK_THRESH
  1,                              // HYBRID
  0,                              // PAVLOVIAN
  0,                              // OPERANT
  1,                              // ENFORCE_NO_LICK
  3333,                           // INTERVAL_MIN
  7000,                           // INTERVAL_MAX
  5000,                           // TARGET
  7000,                           // TRIAL_DURATION
  10000,                          // ITI
  400,                            // RANDOM_DELAY_MIN
  1500,                           // RANDOM_DELAY_MAX
  100,                            // CUE_DURATION
  100,                            // REWARD_DURATION
  0,                              // QUININE_DURATION
  0,                              // QUININE_TIMEOUT
  0,                              // QUININE_MIN
  0,                              // QUININE_MAX
  0,                              // SHOCK_ON
  0,                              // SHOCK_MIN
  0,                              // SHOCK_MAX
  1,                              // EARLY_LICK_ABORT
  500,                            // ABORT_MIN
  3333,                           // ABORT_MAX
  0,                              // PERCENT_PAVLOVIAN
  0,                              // PERCENT_CHR2_TRIALS
  0,                // CHR2_STIM_TIME
  50                // P_STIM_GIVEN_TIME
};

/*****************************************************
Other Global Variables 
*****************************************************/
// Variables declared here can be carried to the next loop, AND read/written in function scope as well as main scope
// (previously defined):
static long _eventMarkerTimer        = 0;
static long _trialTimer              = 0;
static long _resultCode              = -1;       // Result code number. -1 if there is no result.
static long _random_delay_timer      = 0;        // Random delay timer
static long _single_loop_timer       = 0;        // Timer
static State _state                  = _INIT;    // This variable (current _state) get passed into a _state function, which determines what the next _state should be, and updates it to the next _state.
static State _prevState              = _INIT;    // Remembers the previous _state from the last loop (actions should only be executed when you enter a _state for the first time, comparing currentState vs _prevState helps us keep track of that).
static char _command                 = ' ';      // Command char received from host, resets on each loop
static int _arguments[2]             = {0};      // Two integers received from host , resets on each loop
static bool _lick_state              = false;    // True when lick detected, False when no lick
static bool _pre_window_elapsed      = false;    // Track if pre_window time has elapsed
static bool _reached_target          = false;    // Track if target time reached
static bool _late_lick_detected      = false;    // Track if late lick detected
static long _exp_timer               = 0;        // Experiment timer, reset to signedMillis() at every soft reset
static long _lick_time               = 0;        // Tracks most recent lick time
static long _cue_on_time             = 0;        // Tracks time cue has been displayed for
static long _response_window_timer   = 0;        // Tracks time in response window state
static long _reward_timer            = 0;        // Tracks time in reward state
static long _quinine_timer           = 0;        // Tracks time since last quinine delivery
static long _abort_timer             = 0;        // Tracks time in abort state
static long _ITI_timer               = 0;        // Tracks time in ITI state
static long _preCueDelay             = 0;        // Initialize _preCueDelay var
static bool _reward_dispensed_complete = false;  // init tracker of reward dispensal
static bool _shock_trigger_on        = false;    // Shock trigger default is off
static long _dice_roll               = 0;        // Randomly select if trial will be pav or op
static bool _mixed_is_pavlovian      = true;     // Track if current mixed trial is pavlovian
static bool _first_lick_received     = false;    // Track if first lick received for a trial
static bool _ChR2_trigger_on         = false;    // Track if CHR2 trigger is on 
static bool _trial_is_stimulated     = false;    // Track if trial is stimulated  
static bool _stimulation_requested   = false;  // Track if stim requested
static bool _ChR2_receipt_received   = false;  // Clear receipt
static bool _need2check_non_zero_ChR2   = false;   // Track if user wants to stimulate at a time other than zero
static bool _analog_lick_mode    = false;  // Check if user wants to use analog lick mode
static unsigned int _filtered_read   = 0;    // Keep track of the analog read
static bool foundThresh = false; //A_LICK_THRESH manually adjusted

/*****************************************************
  INITIALIZATION LOOP
*****************************************************/
void setup()
{
  //--------------------I/O initialization------------------//
  // OUTPUTS
  pinMode(PIN_HOUSE_LAMP, OUTPUT);            // LED for illumination (trial cue)
  pinMode(PIN_LED_CUE, OUTPUT);               // LED for 'start' cue
  pinMode(PIN_SPEAKER, OUTPUT);               // Speaker for cue/correct/error tone
  pinMode(PIN_REWARD, OUTPUT);                // Reward OUT
  pinMode(PIN_QUININE, OUTPUT);               // Quinine OUT
  pinMode(PIN_SHOCK, OUTPUT);                 // Shock OUT
  pinMode(PIN_TRIGGER, OUTPUT);               // Trigger OUT
    pinMode(PIN_IR_LED_TRIGGER, OUTPUT);        // IR LED Trigger
    pinMode(PIN_3_3, OUTPUT);                   // A 3.3V src
    pinMode(PIN_IR_HOUSE, OUTPUT);        // An IR Houselamp - always on
    pinMode(PIN_CHR2, OUTPUT);            // Trigger for ChR2 Program
    pinMode(PIN_ALICK_OUT, OUTPUT);       // Send analog lick receipt as digital pulse to recording device
    pinMode(PIN_FIRST_LICK, OUTPUT);      // Send first lick pulse to optocontroller
  // INPUTS
  pinMode(PIN_LICK, INPUT);                   // Lick detector
  pinMode(PIN_RECEIPT, INPUT);        // Confirms Optogenetics Controller received command, used for event marker

  // ANALOGS
  pinMode(A0, INPUT);
  pinMode(PIN_LICK_ACC, INPUT);
  //--------------------------------------------------------//



  //------------------------Serial Comms--------------------//
  Serial.begin(115200);                       // Set up USB communication at 115200 baud 

}

void loop() {
  // To manually determine optimal A_LICK_THRESH
  // Initialization
  mySetup();

  // Main loop (R# resets it)
  foundThresh = false;
  while (!foundThresh)
  {
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      Step 1: Read USB MESSAGE from HOST (if available)
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    // 1) Check USB for MESSAGE from HOST, if available. String is read byte by byte. (Each character is a byte, so reads e/a character)
    static String usbMessage  = "";             // Initialize usbMessage to empty string, only happens once on first loop (thanks to static!)
    _command = ' ';                              // Initialize _command to a SPACE
    _arguments[0] = 0;                           // Initialize 1st integer argument
    _arguments[1] = 0;                           // Initialize 2nd integer argument

    if (Serial.available() > 0)  {              // If there's something in the SERIAL INPUT BUFFER (i.e., if another character from host is waiting in the queue to be read)
      char inByte = Serial.read();                  // Read next character
      
      // The pound sign ('#') indicates a complete message!------------------------
      if (inByte == '#')  {                         // If # received, terminate the message
        // Parse the string, and updates `_command`, and `_arguments`
        _command = getCommand(usbMessage);               // getCommand pulls out the character from the message for the _command         
        usbMessage = "";                                // Clear message buffer (resets to prepare for next message)
        if (_command == 'R') {
          break;
        }
        if (_command == ','){
          A_LICK_THRESH--;
        }
        if (_command == '.'){
          A_LICK_THRESH++;
        }
        if (_command == 'W'){
          foundThresh = true;
        }
      }
      else {
        // append character to message buffer
        usbMessage = usbMessage + inByte;       // Appends the next character from the queue to the usbMessage string
      }
    }
  }
}

void mySetup()
{

  //--------------Set ititial OUTPUTS----------------//
    digitalWrite(PIN_3_3, HIGH);         // IR Trigger Reset
    digitalWrite(PIN_IR_HOUSE, HIGH);      // Houselamp Always On
    digitalWrite(PIN_ALICK_OUT, LOW);      // Initialize A/D lick pulse tracker to low
    digitalWrite(PIN_FIRST_LICK, LOW);       // Initialize first lick tracker to low

  //---------------------------Reset a bunch of variables---------------------------//
  _eventMarkerTimer         = 0;
  _trialTimer               = 0;
  _resultCode               = -1; 
  _random_delay_timer       = 0;        // Random delay timer
  _single_loop_timer        = 0;        // Timer
  _state                    = _INIT;    // This variable (current _state) get passed into a _state function, which determines what the next _state should be, and updates it to the next _state.
  _prevState                = _INIT;    // Remembers the previous _state from the last loop (actions should only be executed when you enter a _state for the first time, comparing currentState vs _prevState helps us keep track of that).
  _command                  = ' ';      // Command char received from host, resets on each loop
  _arguments[0]             = 0;        // Two integers received from host , resets on each loop
  _arguments[1]             = 0;        // Two integers received from host , resets on each loop
  _lick_state               = false;    // True when lick detected, False when no lick
  _pre_window_elapsed       = false;    // Track if pre_window time has elapsed
  _reached_target           = false;    // Track if target time reached
  _late_lick_detected       = false;    // Track if late lick detected
  _lick_time                = 0;        // Tracks most recent lick time
  _cue_on_time              = 0;        // Tracks time cue has been displayed for
  _response_window_timer    = 0;        // Tracks time in response window state
  _reward_timer             = 0;        // Tracks time in reward state
  _abort_timer              = 0;        // Tracks time in abort state
  _ITI_timer                = 0;        // Tracks time in ITI state
  _preCueDelay              = 0;        // Initialize _preCueDelay var
  _reward_dispensed_complete  = false;    // init tracker of reward dispensal
  _shock_trigger_on         = false;    // Shock trigger default is off
  _dice_roll            = 0;        // Randomly select if trial will be pav or op
  _mixed_is_pavlovian       = true;     // Track if current mixed trial is pavlovian
    _first_lick_received        = false;    // Reset first lick detector
    _trial_is_stimulated        = false;    // Track if trial is stimulated 
  _stimulation_requested      = false;    // Track if stim command issued
  _ChR2_receipt_received      = false;  // Clear receipt
  _need2check_non_zero_ChR2   = false;  // Track if user wants to stimulate at a time other than zero
  _analog_lick_mode       = true; // Track if user wants use accelerometer-based lick ckt

  // Tell PC that we're running by sending '~' message:
  hostInit();                         // Sends all parameters, states and error codes to Matlab (LF Function)    
}

/*****************************************************
  SERIAL COMMUNICATION TO HOST
*****************************************************/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  SEND MESSAGE to HOST
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
void sendMessage(String message)   // Capital (String) because is defining message as an object of type String from arduino library
{
  Serial.println(message);
} // end Send Message---------------------------------------------------------------------------------------------------------------------

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  GET COMMAND FROM HOST (single character)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
char getCommand(String message)
{
  message.trim();                 // Remove leading and trailing white space
  return message[0];              // Parse message string for 1st character (the command)
} // end Get Command---------------------------------------------------------------------------------------------------------------------

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  GET ARGUMENTS (of the command) from HOST (2 int array)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
void getArguments(String message, int *_arguments)  // * to initialize array of strings(?)
{
  _arguments[0] = 0;              // Init Arg 0 to 0 (reset)
  _arguments[1] = 0;              // Init Arg 1 to 0 (reset)

  message.trim();                 // Remove leading and trailing white space from MESSAGE

  //----Remove command (first character) from string:-----//
  String parameters = message;    // The remaining part of message is now "parameters"
  parameters.remove(0,1);         // Remove the command character and # (e.g., "P#")
  parameters.trim();              // Remove any spaces before next char

  //----Parse first (optional) integer argument-----------//
  String intString = "";          // init intString as a String object. intString concatenates the arguments as a string
  while ((parameters.length() > 0) && (isDigit(parameters[0]))) 
  {                               // while the first argument in parameters has digits left in it unparced...
    intString += parameters[0];       // concatenate the next digit to intString
    parameters.remove(0,1);           // delete the added digit from "parameters"
  }
  _arguments[0] = intString.toInt();  // transform the intString into integer and assign to first argument (Arg 0)


  //----Parse second (optional) integer argument----------//
  parameters.trim();              // trim the space off of parameters
  intString = "";                 // reinitialize intString
  while ((parameters.length() > 0) && (isDigit(parameters[0]))) 
  {                               // while the second argument in parameters has digits left in it unparced...
    intString += parameters[0];       // concatenate the next digit to intString
    parameters.remove(0,1);           // delete the added digit from "parameters"
  }
  _arguments[1] = intString.toInt();  // transform the intString into integer and assign to second argument (Arg 1)
} // end Get Arguments---------------------------------------------------------------------------------------------------------------------


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  INIT HOST (send States, Names/Value of Parameters to HOST)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
void hostInit()
{
  //------Send state names and which states allow parameter update-------//
  for (int iState = 0; iState < _NUM_STATES; iState++)
  {// For each state, send "@ (number of state) (state name) (0/1 can update params)"
      sendMessage("@ " + String(iState) + " " + _stateNames[iState] + " " + String(_stateCanUpdateParams[iState]));
  }

  //-------Send event marker codes---------------------------------------//
  /* Note: "&" reserved for uploading new event marker and timestamp. "+" is reserved for initially sending event marker names */
  for (int iCode = 0; iCode < _NUM_OF_EVENT_MARKERS; iCode++)
  {// For each state, send "+ (number of event marker) (event marker name)"
      sendMessage("+ " + String(iCode) + " " + _eventMarkerNames[iCode]); // Matlab adds 1 to each code # to index from 1-n rather than 0-n
  }

  //-------Send param names and default values---------------------------//
  for (int iParam = 0; iParam < _NUM_PARAMS; iParam++)
  {// For each param, send "# (number of param) (param names) (param init value)"
      sendMessage("# " + String(iParam) + " " + _paramNames[iParam] + " " + String(_params[iParam]));
  }
  //--------Send result code interpretations.-----------------------------//
  for (int iCode = 0; iCode < _NUM_RESULT_CODES; iCode++)
  {// For each result code, send "* (number of result code) (result code name)"
      sendMessage("* " + String(iCode) + " " + _resultCodeNames[iCode]);
  }
  sendMessage("~");                           // Tells PC that Arduino is on (Send Message is a LF Function)
}

long signedMillis()
{
  long time = (long)(millis());
  return time;
}
