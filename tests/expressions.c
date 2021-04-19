int num = 6*2/(2+1*2/3+6)+8*(8/4);
print("6*2/( 2+1 * 2/3 +6) +8 * (8/4) = ", num, "\n");

int x = 5;
if(( x > 4 )&&( x < 6 )){
    print("x=5 hence ( x > 4 ) && ( x < 6 ) is true\n");
}

int y=10;
if(( y > 4 )||( y < 6 )){
    print("y=", y, "hence ( y > 4 )||( y < 6 ) is true\n");
}
else{
    print("y=", y, "hence ( y > 4 )||( y < 6 ) is false\n");
}

int a, b, c;
a = 5;
b = 8;
c = ++x + y--;

print("a=", a, "b=", b, "++x + y++ = ", c, "\n");