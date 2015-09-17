function out = mat2quat(A)

q1 = 1/2*sqrt(1 + A(1,1) + A(2,2) + A(3,3));
if abs(q1) < 1e-6
    warning('Denominator is close to zero');
end
q2 = 1/4/q1*(A(3,2) - A(2,3));
q3 = 1/4/q1*(A(1,3) - A(3,1));
q4 = 1/4/q1*(A(2,1) - A(1,2));

out = [q1; q2; q3; q4];
