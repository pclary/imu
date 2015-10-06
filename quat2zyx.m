function r = quat2zyx(q)

rz = atan2(2*(q(2)*q(3) + q(1)*q(4)), 1 - 2*(q(3)^2 + q(4)^2));
ry = asin(2*(q(3)*q(1) - q(2)*q(4)));
rx = atan2(2*(q(2)*q(1) + q(3)*q(4)), 1 - 2*(q(2)^2 + q(3)^2));
r = [rz; ry; rx];
