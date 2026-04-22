#include<stdio.h>
#define LEN 29903

/* https://www.ncbi.nlm.nih.gov/nuccore/MN908947  */
/* にあるRNA情報をc.txtに置いています。 */

int main (void) {
  char rna[LEN];
  int i;
  int count_a;

  /* ここからファイル処理です。第11回で学習します。*/
  for (i=0; i<LEN; i=i+1)
    fscanf (stdin, "%c", &rna[i]);
  /* ここまでファイル処理です。 */

  count_a = 0;
  for (i=0; i<LEN; i=i+1)
    if(rna[i]=='a')
      count_a = count_a+1;
  printf ("\'a\'は%d回出現しました。\n", count_a);
  return 0;
}
