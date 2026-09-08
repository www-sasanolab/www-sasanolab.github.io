#include <stdio.h>
#define NUM 117

int main (void) {
  int i;
  int seiseki[NUM];

  /* ここからファイル処理です。第11回で学習します。*/
  for (i=0; i<NUM; i=i+1)
    scanf ("%d", &seiseki[i]);
  /* ここまでファイル処理です。 */

  for (i=0; i<NUM; i=i+1)
    printf ("%d ", seiseki[i]);
  printf ("\n");
  return 0;
}
