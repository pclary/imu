function vrot = quatrotate(v, q)
%#codegen

temp = quatmul(quatmul(q, [0; v]), [q(1); -q(2:4)]);
vrot = temp(2:4);


function q = quatmul(a, b)

q = [a(1)*b(1) - a(2)*b(2) - a(3)*b(3) - a(4)*b(4); ...
    a(1)*b(2) + a(2)*b(1) + a(3)*b(4) - a(4)*b(3); ...
    a(1)*b(3) - a(2)*b(4) + a(3)*b(1) + a(4)*b(2); ...
    a(1)*b(4) + a(2)*b(3) - a(3)*b(2) + a(4)*b(1)];
