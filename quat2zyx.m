function r = quat2zyx(q)

ry = asin(-2*(q(2)*q(4) - q(1)*q(3)));
rx = atan2(q(3)*q(4) + q(1)*q(2), 1/2 - (q(2)^2 + q(3)^2));
rz = atan2(q(2)*q(3) + q(1)*q(4), 1/2 - (q(3)^2 + q(4)^2));
r = [rz; ry; rx];
