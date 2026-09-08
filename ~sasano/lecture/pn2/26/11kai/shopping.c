#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef struct{
  int id;
  char name[100];
  int price;
} goods;

int readGoods (goods *g){
  FILE *fp;
  int num=0;
  char name[100];
  int id, price;
  if ((fp=fopen ("goods", "r")) == NULL) {
    printf ("ファイルのオープンに失敗しました\n");
    return 0;
  }
  while (fscanf (fp, "%d%s%d", &id, name, &price) == 3) {
    strcpy (g[num].name, name);
    g[num].price = price;
    g[num].id = id;
    num++;
  }
  fclose (fp);
  return num;
}

void printGoods (goods *g, int n){
  int i;
  for(i=0; i<n; i++){
    printf("%d %s %d\n",
	   g[i].id, g[i].name, g[i].price);
  }
}

int main(void){
  goods g[50];
  int len;
  len = readGoods (g);
  printGoods (g, len);
  return 0;
}
