#include <stdio.h>
#define LEN 256

int main (void) {
  int x,y,color,i;
  unsigned char colorIN[LEN][LEN][3]; /* 色（BGR）の配列（入力用）*/
  unsigned char colorOUT[LEN][LEN][3];  /* 色（BGR）の配列（出力用）*/

  /* ファイル（標準入力）の処理 */
  unsigned char a;
  for (i=0; i<54; i=i+1) {/* 標準入力の先頭54バイトを標準出力へコピー */
    fread(&a, 1, 1, stdin);
    fwrite(&a, 1, 1, stdout);
  }
  for (y=0; y<LEN; y=y+1) /* 各pixelの色をcolorIN配列に格納 */
    for (x=0; x<LEN; x=x+1)
      for (color=0; color<3; color=color+1)
        fread(&colorIN[y][x][color], 1, 1, stdin); 
  /* ここまで */

  /* 右90度回転処理 */
  for (y=0; y<LEN; y=y+1) 
    for (x=0; x<LEN; x=x+1)
      for (color=0; color<3; color=color+1)
        colorOUT[LEN-x][y][color]=colorIN[y][x][color];
  /* ここまで */
  
  /* 各pixelの色を標準出力へ出力 */
  for (y=0; y<LEN; y=y+1)
    for (x=0; x<LEN; x=x+1)
      for (color=0; color<3; color=color+1)
        fwrite(&colorOUT[y][x][color], 1, 1, stdout);
  /* ここまで */
  return 0;
}
