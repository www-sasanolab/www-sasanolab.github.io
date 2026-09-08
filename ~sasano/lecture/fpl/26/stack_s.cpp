/*
How to execute this program on linux in Gakujo center:
% g++ stack_s.cpp
% ./a.out
*/

#include <stdio.h>

class Stack {
  int top;
  int size;
  char *elements;
public: 
  Stack (int n) {
    size=n;  
    elements = new char[size]; top=0;
  }
  ~Stack() { 
    delete elements; 
  }
  void push (char a) {
    top++; 
    elements[top] = a;
  }
  char pop() {
    top--; 
    return elements[top+1];
  }
}; 

int main (void) {
  Stack s(10);
  s.push('a');
  s.push('b');
  s.push('c');
  printf("%c\n", s.pop());
  printf("%c\n", s.pop());
  printf("%c\n", s.pop());
  return 0;
}
