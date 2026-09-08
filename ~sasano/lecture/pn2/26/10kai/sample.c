#include <stdio.h>
#include <stdlib.h>

typedef struct {
  char name[32];
  int math;
  int eng;
  int sum;
} score;

void input(score *p, int n){
  int i;
  for (i=0; i<n; i++) {
    scanf("%31s", p[i].name);
    scanf("%d", &p[i].math);
    scanf("%d", &p[i].eng);
  }
}

void output (score *p, int n){
  int i;
  printf("氏名     数学 英語\n");
  for(i=0; i<n; i++)
    printf("%-8s%5d%5d\n", 
	   p[i].name, p[i].math, p[i].eng);
}

int main (void){
  int n;
  score *p;
  scanf("%d", &n);
  p = calloc (n, sizeof(score));
  if (p==NULL)
    printf ("記憶域の確保に失敗しました。\n");
  else {
    input (p, n);
    output (p, n);
    free (p);
  }
  return 0;
}
