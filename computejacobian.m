%% 
syms q1 q2 q3 q4 wx wy wz ax ay az mx my mz g h real;

h = [quatrotate([0; 0; g], [q1; q2; q3; q4]) + [ax; ay; az]; 
    quatrotate([h; 0; 0], [q1; q2; q3; q4]) + [mx; my; mz]; 
    wx; wy; wz];
x = [q1; q2; q3; q4; wx; wy; wz; ax; ay; az; mx; my; mz];

H = jacobian(h, x)

