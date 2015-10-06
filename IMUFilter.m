classdef IMUFilter < handle
    
    properties
        GyroScale = 1;
        AccelScale = 1; % not really used
        MagScale = 1; % not really used
        GyroVariance = 1;
        AccelVariance = 1;
        MagVariance = 1;
    end
    
    properties (SetAccess=private)
        q = [1; 0; 0; 0];
        variance = 0;
    end
    
    methods
        function obj = IMUFilter()
            
        end
        function GyroUpdate(obj, gyro, dt)
            % Rotate state estimate by integrated angular velocity
            obj.q = quatmul(obj.q, velquat(gyro*obj.GyroScale, dt));
            
            % Variance increases by model variance
            obj.variance = obj.variance + obj.GyroVariance;
        end
        function AccelUpdate(obj, accel)
            % Measured and predicted gravity vector resolved in body frame
            gmeas = accel/norm(accel);
            gpred = quatrotate([0; 0; 1], quatconj(obj.q));
            
            % Get axis/angle that corrects for difference
            [n, th] = vec2aa(gmeas, gpred);
            
            % Kalman gain (always between 0 and 1)
            K = obj.variance/(obj.variance + obj.AccelVariance);
            
            % Rotate orientation estimate to partly correct for difference
            qadj = aa2quat(n, K*th);
            obj.q = quatmul(obj.q, qadj);
            
            % Variance decreases with higher measurement trust
            obj.variance = obj.variance*(1 - K);
        end
        function MagUpdate(obj, mag)
            % Remove vertical (pitch) component of magnetometer reading
            zworld = quatrotate([0; 0; 1], quatconj(obj.q));
            mag = mag - zworld*dot(mag, zworld);
            
            % Measured and predicted compass vector resolved in body frame
            mmeas = mag/norm(mag);
            mpred = quatrotate([1; 0; 0], quatconj(obj.q));
            
            % Get axis/angle that corrects for difference
            [n, th] = vec2aa(mmeas, mpred);
            
            % Kalman gain (always between 0 and 1)
            K = obj.variance/(obj.variance + obj.MagVariance);
            
            % Rotate orientation estimate to partly correct for difference
            qadj = aa2quat(n, K*th);
            obj.q = quatmul(obj.q, qadj);
            
            % Variance decreases with higher measurement trust
            obj.variance = obj.variance*(1 - K);
        end
    end
    
end


function q = quatmul(a, b)
% Add rotation a onto rotation b (quaternion multiplication)
q = [a(1)*b(1) - a(2)*b(2) - a(3)*b(3) - a(4)*b(4); ...
    a(1)*b(2) + a(2)*b(1) + a(3)*b(4) - a(4)*b(3); ...
    a(1)*b(3) - a(2)*b(4) + a(3)*b(1) + a(4)*b(2); ...
    a(1)*b(4) + a(2)*b(3) - a(3)*b(2) + a(4)*b(1)];
end


function qc = quatconj(q)
% Quaternion conjugate (also =inverse for unit quaternions)
qc = [q(1); -q(2:4)];

end


function vrot = quatrotate(v, q)
% Rotate vector v by quaternion q
temp = quatmul(quatmul(q, [0; v]), quatconj(q));
vrot = temp(2:4);
end


function q = velquat(wb, dt)
% Integrate angular velocity over dt to get quaternion rotation
w = norm(wb);
if w ~= 0
    n = wb/w;
else
    n = [1; 0; 0];
end
th = w*dt/2;
q = aa2quat(n, th);
end


function q = aa2quat(n, th)
% Convert axis/angle rotation to quaternion
q = [cos(th); n(:)*sin(th)];
end


function [n, th] = vec2aa(v1, v2)
% Get rotation axis and angle from vectors v1 to v2
v3 = cross(v1, v2);
nv3 = norm(v3);
if norm(v3) ~= 0;
    n = v3/nv3;
else
    n = [1; 0; 0];
end
den = norm(v1)*norm(v2);
th = atan2(nv3/den, dot(v1, v2)/den);
end
