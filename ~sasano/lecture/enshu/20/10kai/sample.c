#include <stdio.h>
#include <stdlib.h>

typedef struct {
  char name[32];
  int math;
  int eng;
  int sum;
} point;

void input(point *p, int n){
  int i;
  for (i=0; i<n; i++) {
    scanf("%s", p[i].name);
    scanf("%d", &p[i].math);
    scanf("%d", &p[i].eng);
  }
}

void output (point *p, int n){
  int i;
  printf("氏名     数学 英語\n");
  for(i=0; i<n; i++)
    printf("%-8s%5d%5d\n", 
	   p[i].name, p[i].math, p[i].eng);
}

int main (void){
  int n, i;
  point *p;
  scanf("%d", &n);
  p = calloc (n, sizeof(point));
  if (p==NULL)
    printf ("記憶域の確保に失敗しました。\n");
  else {
    input (p, n);
    output (p, n);
    free (p);
  }
  return 0;
}
