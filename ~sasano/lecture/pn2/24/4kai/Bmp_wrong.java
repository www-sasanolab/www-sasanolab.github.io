// javac Bmp_wrong.java
// java Bmp_wrong < joho.bmp > joho2.bmp
// のように実行。
// java.lang.ArrayIndexOutOfBoundsExceptionが発生する。

import java.io.*;
public class Bmp_wrong {
    public static final int LEN = 256;
    public static void main (String [] args) throws IOException{
        int x,y,color,i;
        byte[][][] colorIN = new byte[LEN][LEN][3]; /* 色（BGR）の配列（入力用）*/
        byte[][][] colorOUT = new byte[LEN][LEN][3]; /* 色（BGR）の配列（出力用）*/

        /* ファイル（標準入力）の処理 */
        DataInputStream d = new DataInputStream(System.in);
        DataOutputStream o = new DataOutputStream(System.out);
        for (i=0; i<54; i=i+1) /* 標準入力の先頭54バイトを標準出力へコピー */
            o.writeByte(d.readByte());
        for (y=0; y<LEN; y=y+1) /* 各pixelの色をcolorIN配列に格納 */
            for (x=0; x<LEN; x=x+1)
                for (color=0; color<3; color=color+1)
                    colorIN[y][x][color] = d.readByte(); 
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
                    o.writeByte(colorOUT[y][x][color]);
        /* ここまで */
        o.close();
    }
}
