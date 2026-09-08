#include <stdio.h>

int tarai (int x, int y, int z)
{
  if (x <= y) return y;
  return tarai (tarai (x-1, y, z), 
		tarai (y-1, z, x),
		tarai (z-1, x, y));
}

int ack (int m, int n) {
  if (m==0) return n+1;
  if (n==0) return ack (m-1,1);
  return ack (m-1, ack (m,n-1));
}

int main(void)
{
  printf ("%d\n", tarai (10,5,5));
  printf ("%d\n", ack (3,4));
}
