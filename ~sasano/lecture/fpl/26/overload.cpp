/* 
How to execute this program on linux in Gakujo center:
% g++ overload.cpp
% ./a.out
This program shows overloading.
The function "plus" is overloaded.
*/

#include<iostream>
#include<sstream>

std::string plus (int x, std::string y) {
  std::ostringstream s;
  s << x << y;
  return s.str();
}

int plus (int x, int y, int z){
  return x+y+z;
}

int plus (int x, int y) {
  return x + y;
}

int main (void) {
  int x,y;
  std::string z;
  x = plus (2,3);
  y = plus (2,3,4);
  z = plus (20, "abc");
  std::cout << "x=" << x << "\n"
            << "y=" << y << "\n"
            << "z=" << z << "\n";
  return 0;
}
