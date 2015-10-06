function imufilter_sfun(block)

setup(block);


function setup(block)

% Register number of ports
block.NumInputPorts  = 3;
block.NumOutputPorts = 1;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
% Rate gyroscope measurements
block.InputPort(1).Dimensions = 3;
block.InputPort(1).DatatypeID = 0; % double
block.InputPort(1).Complexity = 'Real';
block.InputPort(1).DirectFeedthrough = true;

% Accelerometer measurements
block.InputPort(2).Dimensions = 3;
block.InputPort(2).DatatypeID = 0; % double
block.InputPort(2).Complexity = 'Real';
block.InputPort(2).DirectFeedthrough = true;

% Magnetometer measurements
block.InputPort(3).Dimensions = 3;
block.InputPort(3).DatatypeID = 0; % double
block.InputPort(3).Complexity = 'Real';
block.InputPort(3).DirectFeedthrough = true;

% Override output port properties
% Orientation quaternion
block.OutputPort(1).Dimensions = 4;
block.OutputPort(1).DatatypeID = 0; % double
block.OutputPort(1).Complexity = 'Real';

% Register parameters
% 1: Sample time
% 2: Rate gyro variance
% 3: Accelerometer variance
% 4: Magnetometer variance
% 5: Rate gyro scale
block.NumDialogPrms = 5;

% Register sample times
block.SampleTimes = [block.DialogPrm(1).Data 0];

% Specify the block simStateCompliance
block.SimStateCompliance = 'DefaultSimState';

% Register methods
block.RegBlockMethod('PostPropagationSetup', @PostPropagationSetup);
block.RegBlockMethod('Start',     @Start);
block.RegBlockMethod('Outputs',   @Outputs);
block.RegBlockMethod('Update',    @Update);
block.RegBlockMethod('Terminate', @Terminate);


function PostPropagationSetup(block)

block.NumDworks = 1;
block.Dwork(1).Name       = 'PrevTime';
block.Dwork(1).Dimensions = 1;
block.Dwork(1).DatatypeID = 0; % double
block.Dwork(1).Complexity = 'Real';


function Start(block)

% Initialize filter object and store in UserData
imufilter = IMUFilter();
set_param(block.BlockHandle, 'UserData', imufilter);

% Initialize previous time variable
block.Dwork(1).Data = 0;

% Set filter parameters
imufilter.GyroVariance =  block.DialogPrm(2).Data;
imufilter.AccelVariance = block.DialogPrm(3).Data;
imufilter.MagVariance =   block.DialogPrm(4).Data;
imufilter.GyroScale =     block.DialogPrm(5).Data;


function Outputs(block)

% Output current filter orientation
imufilter = get_param(block.BlockHandle, 'UserData');
block.OutputPort(1).Data = imufilter.q;


function Update(block)

% Get timestep
t = block.CurrentTime;
dt = t - block.Dwork(1).Data;
block.Dwork(1).Data = t;

% Update filter
imufilter = get_param(block.BlockHandle, 'UserData');
imufilter.GyroUpdate(block.InputPort(1).Data, dt);
imufilter.AccelUpdate(block.InputPort(2).Data);
imufilter.MagUpdate(block.InputPort(3).Data);


function Terminate(block)


