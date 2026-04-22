/*
How to execute this program on linux in Gakujo center:
% g++ shape.cpp
% ./a.out
*/

#include <stdio.h>

// draw is a virtual function.
// draw displays some string instead of drawing some figure.  
class Shape {
public:
  Shape (void) {};
  virtual void draw (void) {
    printf ("Shape\n");
  }
};

class Box : public Shape {
  int num;
public:
  Box (int n) {num=n;};
  void draw (void) {
    printf ("Box %d\n", num);
  }
};

class Ellipse : public Shape {
public:
  Ellipse (void) {};
  void draw (void) {
    printf ("Ellipse\n");
  }
};

class Circle : public Ellipse {
public:
  Circle (void) {};
  void draw (void) {
    printf ("Circle\n");
  }
};
  
class Line : public Shape {
public:
  Line (void) {};
  void draw (void) {
    printf ("Line\n");
  }
};

int main (void) {
  Shape * a[4];
  int i;
  a[0] = new Box (1);
  a[1] = new Ellipse();
  a[2] = new Circle ();
  a[3] = new Line ();
  for (i=0; i<4; i++)
    a[i]->draw();
  return 0;
}
