%% 
syms q1 q2 q3 q4 wx wy wz g h real;

h = [quatrotate([0; 0; g], [q1; q2; q3; q4]); quatrotate([h; 0; 0], [q1; q2; q3; q4]); wx; wy; wz];
x = [q1; q2; q3; q4; wx; wy; wz];

H = jacobian(h, x)

