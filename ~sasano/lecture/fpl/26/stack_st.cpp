/*
How to execute this program on linux in Gakujo center:
% g++ stack_st.cpp
% ./a.out
*/

#include <stdio.h>

template <class T> class Stack {
  int top;
  int size;
  T *elements;
public: 
  Stack (int n) {
    size=n;  
    elements = new T[size]; top=0;
  }
  ~Stack() { 
    delete elements; 
  }
  void push (T a) {
    top++; 
    elements[top] = a;
  }
  T pop() {
    top--; 
    return elements[top+1];
  }
}; 

int main (void) {
  Stack<char> s(10);
  s.push('a');
  s.push('b');
  s.push('c');
  printf("%c\n", s.pop());
  printf("%c\n", s.pop());
  printf("%c\n", s.pop());
  return 0;
}
