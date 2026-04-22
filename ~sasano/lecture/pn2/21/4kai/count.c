#include<stdio.h>
#define LEN 200000
/* LENはマクロというもので、stdio.hのインクルードと同様、 */
/* Cのプリプロセッサーで処理されます。プロ入2の範囲外とします。 */
/* LENは大きめに設定しています。 */

/* https://gutenberg.org/files/1513/1513-0.txt */
/* からダウンロートしたファイルをromeo.txtとして */
/* 講義用web pageに置いています。 */

int main (void) {
  char romeo[LEN]; /* ファイル全体の文字列格納 */
  int i; /* 配列の添字用 */
  int num; /* ファイル全体の文字数カウント */
  int count_a; /* aのカウント */

  num=0; 
  /* この部分はファイル処理です。第11回で学習します。*/
  for (i=0; i<LEN; i=i+1){
    num=num+1;
    if(fscanf(stdin, "%c", &romeo[i])==EOF) break;
  }
  /* ここまで */

  count_a=0;
  for (i=0; i<num; i=i+1)
    if(romeo[i]=='a')
      count_a=count_a+1;
  printf ("'a'は%d回出現しました。\n", count_a);
  return 0;
}
