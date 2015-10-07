%% 
syms q1 q2 q3 q4 g h real;

h = [quatrotate([0; 0; g], quatconj([q1; q2; q3; q4])); quatrotate([h; 0; 0], quatconj([q1; q2; q3; q4]))];
x = [q1; q2; q3; q4];

H = jacobian(h, x)

