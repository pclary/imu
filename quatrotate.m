function vrot = quatrotate(v, q)

temp = quatmul(quatmul(q, [0; v]), quatconj(q));
vrot = temp(2:4);
