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
ekf = ExtendedKalmanFilter([1; 0; 0; 0], zeros(4));
set_param(block.BlockHandle, 'UserData', ekf);

% Initialize previous time variable
block.Dwork(1).Data = 0;

% Set filter parameters
ekf.Q = block.DialogPrm(2).Data;
ekf.R = block.DialogPrm(3).Data;
ekf.f = @f;
ekf.h = @h;
ekf.Ffun = @F;
ekf.Hfun = @H;


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
ekf.Predict([gyro*block.DialogPrm(4).Data; dt]);
ekf.Update([accel/norm(accel); mag/norm(mag)]);
ekf.x = ekf.x/norm(ekf.x);


function Terminate(block)



function xnew = f(x, u)
% Model update function
xnew = quatmul(x, velquat(u(1:3), u(4)));


function zpred = h(x)
% Measurement prediction function
gpred = quatrotate([0; 0; 1], quatconj(x));
mpred = quatrotate([1; 0; 0], quatconj(x));
zpred = [gpred; mpred];


function out = F(u)
% Jacobian of model update function
w = norm(u(1:3));
if w ~= 0
    n = u(1:3)/w;
else
    n = [1; 0; 0];
end
    
th = w*u(4)/2;
c = cos(th);
s = sin(th);

out = [c      -s*n(1) -s*n(2) -s*n(3);
       s*n(1)  c       s*n(3) -s*n(2);
       s*n(2) -s*n(3)  c       s*n(1);
       s*n(3)  s*n(2) -s*n(1)  c     ];


function out = H(x)
% Jacobian of measurement prediction function
out = [2*[-x(3)  x(4) -x(1)  x(2);
           x(2)  x(1)  x(4)  x(3);
           x(1) -x(2) -x(2)  x(4)];
       2*[ x(1)  x(2) -x(3) -x(4);
          -x(4)  x(3)  x(2) -x(1);
           x(3)  x(4)  x(1)  x(2)]];


function q = quatmul(a, b)
% Add rotation a onto rotation b (quaternion multiplication)
q = [a(1)*b(1) - a(2)*b(2) - a(3)*b(3) - a(4)*b(4); ...
    a(1)*b(2) + a(2)*b(1) + a(3)*b(4) - a(4)*b(3); ...
    a(1)*b(3) - a(2)*b(4) + a(3)*b(1) + a(4)*b(2); ...
    a(1)*b(4) + a(2)*b(3) - a(3)*b(2) + a(4)*b(1)];


function qc = quatconj(q)
% Quaternion conjugate (also =inverse for unit quaternions)
qc = [q(1); -q(2:4)];


function vrot = quatrotate(v, q)
% Rotate vector v by quaternion q
temp = quatmul(quatmul(q, [0; v]), quatconj(q));
vrot = temp(2:4);


function q = velquat(wb, dt)
% Integrate angular velocity over dt to get quaternion rotation
w = norm(wb);
if w ~= 0
    n = wb/w;
else
    n = [1; 0; 0];
end
th = w*dt;
q = aa2quat(n, th);


function q = aa2quat(n, th)
% Convert axis/angle rotation to quaternion
q = [cos(th/2); n(:)*sin(th/2)];

