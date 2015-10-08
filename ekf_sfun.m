function ekf_sfun(block)

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
% 2: Model covariance matrix (Q)
% 3: Measurement covariance matrix (R)
% 4: Rate gyro scale
block.NumDialogPrms = 4;

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
ekf = KalmanFilter([1; 0; 0; 0], zeros(4));
set_param(block.BlockHandle, 'UserData', ekf);

% Initialize previous time variable
block.Dwork(1).Data = 0;

% Set filter parameters
ekf.Q = block.DialogPrm(2).Data;
ekf.R = block.DialogPrm(3).Data;


function Outputs(block)

% Output current filter orientation
ekf = get_param(block.BlockHandle, 'UserData');
block.OutputPort(1).Data = ekf.x;


function Update(block)

% Get timestep
t = block.CurrentTime;
dt = t - block.Dwork(1).Data;
block.Dwork(1).Data = t;

% Get input data
gyro = block.InputPort(1).Data;
accel = block.InputPort(2).Data;
mag = block.InputPort(3).Data;

% Update filter
ekf = get_param(block.BlockHandle, 'UserData');
ekf.F = update_model(gyro*block.DialogPrm(4).Data, dt);
ekf.Predict();
ekf.H = measurement_model(ekf.x);
ekf.Update([accel/norm(accel); mag/norm(mag)]);
ekf.x = ekf.x/norm(ekf.x);


function Terminate(block)



function F = update_model(wb, dt)

if ~all(size(wb) == [3, 1])
    error('Body angular acceleration wb must be a 3x1 vector');
end

w = norm(wb);
if w ~= 0
    n = wb/w;
else
    n = [1; 0; 0];
end
    
theta = w*dt/2;
c = cos(theta);
s = sin(theta);

F = [c      -s*n(1) -s*n(2) -s*n(3);
     s*n(1)  c       s*n(3) -s*n(2);
     s*n(2) -s*n(3)  c       s*n(1);
     s*n(3)  s*n(2) -s*n(1)  c     ];


function H = measurement_model(x)
        
H = [2*[-x(3)  x(4) -x(1)  x(2);
         x(2)  x(1)  x(4)  x(3);
         x(1) -x(2) -x(2)  x(4)];
     2*[ x(1)  x(2) -x(3) -x(4);
        -x(4)  x(3)  x(2) -x(1);
         x(3)  x(4)  x(1)  x(2)]];

