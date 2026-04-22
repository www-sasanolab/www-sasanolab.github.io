/*
How to execute this program on linux in Gakujo center:
% g++ dequeue.cpp
% ./a.out
This program implements Stack as a derived class of Dequeue.
This program is just for showing that inheritance and subtyping
are different notion.
*/

#include <stdio.h>

class Dequeue {
  int *d;
  int front;
  int rear;
  int size;
  bool full (void) {
    if(front==rear)
      return true;
    else
      return false;
  }
  bool empty (void) {
    if(front==((rear+1)%7))
      return true;
    else
      return false;
  }
    
public:
  Dequeue(int s) {
    size=s;
    d=new int [size];
    front=1;
    rear=0;
  }
  void push_front (int x) {
    if (x<0){
      printf("Negative value is pushed.\n");
      return ;
    }
    if (this->full()) {
      printf("The dequeue is full.\n");
      return;
    } else {
      d[front]=x;
      if (front==size-1) {
	front=0;
      } else {
	front++;
      }
    }
  }
  int pop_front (void) {
    if (this->empty()){
      printf("The dequeue is empty.\n");
      return -1;
    } else {
      if(front==0)
	front=size-1;
      else
	front--;
      printf("pop_front: %d\n", d[front]);
      return d[front];
    }
  }
  void push_rear (int x) {
    if (x<0) {
      printf ("Negative value is pushed.\n");
      return;
    }
    if (this->full()) {
      printf("The dequeue is full.\n");
    } else {
      d[rear]=x;
      if(rear==0)
	rear=size-1;
      else
	rear--;
    }
  }
  int pop_rear (void) {
    if (this->empty()){
      printf("The dequeue is empty.\n");
      return -1;
    } else {
      if(rear==size-1)
	rear=0;
      else
	rear++;
      printf("pop_rear: %d\n", d[rear]);
      return d[rear];
    }
  }
};

class Stack : private Dequeue {
public:
  Stack (int s) : Dequeue(s){}
  void push_front(int x) {Dequeue::push_front(x);}
  int pop_front() {return Dequeue::pop_front();}
};

int main (void) {
  Stack *s;
  s=new Stack(7);
  s->push_front(3);
  s->pop_front();
  // s->push_rear(4); // type error
  return 0;
}
