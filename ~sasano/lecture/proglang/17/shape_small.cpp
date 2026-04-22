#include <stdio.h>
class Shape {
public:
  virtual void draw (void) {
    printf ("Shape\n");
  };
};
class Box : public Shape{
  int num;
public:
  Box(int n) {num=n;}
  void draw (void) {
    printf ("Box %d\n", num);
  }
};
int main (void) {
  Shape *s = new Box(1);
  s->draw();
  return 0;
}
