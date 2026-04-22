#include <windows.h>
#include <scrnsave.h>
#include <gl/gl.h>
#include <stdio.h>

#define ID_TIMER 32767
#define WIDTH 256 //画像の横のピクセル数 
#define HEIGHT 256 //画像の縦のピクセル数 

void EnableOpenGL(HWND, HDC *, HGLRC *);
void DisableOpenGL(HWND, HDC, HGLRC);

void display (char * ssd, GLuint textureID) 
{
  /* ここに描画部分本体を入れる(画面更新のたびに呼ばれる) */

  static int i=0;
  static char direction;
  static double locx = 0.0;
  static double locy = 0.0;

  i=i % 100;
  direction = ssd[i];
  i++;
  switch (direction) {
  case 'U': 
    locy+=0.5;
    break;
  case 'D': 
    locy-=0.5;
    break;
  case 'R':
    locx+=0.5;
    break;
  case 'L':
    locx-=0.5;
    break;
  default: // UDRL以外の文字が含まれていたら終了
    fprintf(stderr, "Invalid character.\n");
    exit(0);
  }

  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, textureID);
  glBegin(GL_POLYGON);
  glTexCoord2f(0, 0); glVertex2f(locx-30.0, locy-20.0);
  glTexCoord2f(0, 1); glVertex2f(locx-30.0, locy);
  glTexCoord2f(1, 1); glVertex2f(locx-10.0, locy);
  glTexCoord2f(1, 0); glVertex2f(locx-10.0, locy-20.0);
  glEnd();
  glBegin(GL_POLYGON);
  glTexCoord2f(0, 0); glVertex2f(locx-5.0, locy-10.0);
  glTexCoord2f(0, 1); glVertex2f(locx-5.0, locy+10.0);
  glTexCoord2f(1, 1); glVertex2f(locx+15.0, locy+10.0);
  glTexCoord2f(1, 0); glVertex2f(locx+15.0, locy-10.0);
  glEnd();
  glDisable(GL_TEXTURE_2D);
}

void readBits (GLubyte * bits, char * fileName) {
  FILE *fp;
  unsigned char header[54];

  if ((fp=fopen(fileName,"rb"))==NULL) { /* 画像データ読み込み */
    fprintf (stderr, "file not found.\n");
    exit(0);
  }
  fread(header, 1, 54, fp); /* ヘッダ54バイトを読み飛ばす */
  for (int i=0; i<WIDTH*HEIGHT; i++){ /* データをBGRをRGBの順に変えて読み込み */
    fread(&bits[2], 1, 1, fp); 
    fread(&bits[1], 1, 1, fp);
    fread(&bits[0], 1, 1, fp);
    bits=bits+3;
  }
  fclose(fp);
}

LRESULT WINAPI ScreenSaverProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
  static char ssd[100];
  static FILE *fp=NULL;

  GLubyte * bits;
  static GLuint textureID;

  RECT rc;
  static int wx, wy;
  static HDC hDC;
  static HGLRC hRC;

  switch(msg) {

  case WM_CREATE:
    EnableOpenGL(hWnd, &hDC, &hRC );
    GetClientRect(hWnd, &rc);
    wx = rc.right - rc.left;
    wy = rc.bottom - rc.top;

    /* ここにOpenGL関連の初期化部分を入れる(起動時，1度しか呼ばれない) */
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-50.0*wx/wy, 50.0*wx/wy, -50.0, 50.0, -5.0, 5.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glClearColor(0.1f, 0.2f, 0.3f, 0.0f);
    glViewport(0,0,wx,wy);
    /* ここまで */

    /* スクリーンセーバ記述プログラム読み込み */
    fp=fopen ("sample1", "r");
    if (fp==NULL) {
      fprintf (stderr, "ファイルオープン失敗\n");
      exit(0);
    }
    for (int i=0; i<100; i++)
      if (fscanf (fp, "%c", &ssd[i]) == EOF){ // 100文字なかったら終了
	fprintf (stderr, "The length of the input is less than 100.\n");
	exit(0);
      }
    /* ここまで */

    /* bitmap画像を読み込み、textureに割り当てる */
    if ((bits = malloc (WIDTH*HEIGHT*3))==NULL) { /*  画像読み込み用領域確保 */
      fprintf (stderr, "allocation failed.\n");
      exit(0);
    }
    glGenTextures (1, &textureID); /* texture idを1つ作成し、textureIDに格納する */

    /* 1つ目のtexture */    
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    readBits(bits, "sit.bmp"); /* 画像読み込み */
    glTexImage2D(GL_TEXTURE_2D, 0, 3, WIDTH, HEIGHT, 0, GL_RGB, GL_UNSIGNED_BYTE, bits);

    SetTimer(hWnd, ID_TIMER, 15, NULL); //タイマー設定
    break;
  case WM_TIMER:
    display(ssd, textureID);
    glFlush();
    SwapBuffers(hDC);
    break;
  case WM_ERASEBKGND:
    return TRUE;
  case WM_DESTROY:
    KillTimer(hWnd, ID_TIMER);
    DisableOpenGL(hWnd, hDC, hRC);
    PostQuitMessage(0);
    free(bits);
    return 0;
  default:
    break;
  }
  return DefScreenSaverProc(hWnd, msg, wParam, lParam);
}

BOOL WINAPI ScreenSaverConfigureDialog(HWND hDlg, UINT msg, WPARAM wParam, LPARAM lParam)
{
  return TRUE;
}

BOOL WINAPI RegisterDialogClasses(HANDLE hInst)
{
  return TRUE;
}

void EnableOpenGL(HWND hWnd, HDC *hDC, HGLRC *hRC)
{
  int format;
  PIXELFORMATDESCRIPTOR pfd = {
    sizeof(PIXELFORMATDESCRIPTOR),   // size of this pfd
    1,                     // version number
    PFD_DRAW_TO_WINDOW |   // support window
      PFD_SUPPORT_OPENGL |   // support OpenGL
        PFD_DOUBLEBUFFER,      // double buffered
    PFD_TYPE_RGBA,         // RGBA type
    24,                    // 24-bit color depth
    0, 0, 0, 0, 0, 0,      // color bits ignored
    0,                     // no alpha buffer
    0,                     // shift bit ignored
    0,                     // no accumulation buffer
    0, 0, 0, 0,            // accum bits ignored
    32,                    // 32-bit z-buffer
    0,                     // no stencil buffer
    0,                     // no auxiliary buffer
    PFD_MAIN_PLANE,        // main layer
    0,                     // reserved
    0, 0, 0                // layer masks ignored
    };

  *hDC = GetDC(hWnd);
  format = ChoosePixelFormat(*hDC, &pfd);
  SetPixelFormat(*hDC, format, &pfd);

  *hRC = wglCreateContext(*hDC);
  wglMakeCurrent(*hDC, *hRC);
}

void DisableOpenGL(HWND hWnd, HDC hDC, HGLRC hRC)
{
  wglMakeCurrent(NULL, NULL);
  wglDeleteContext(hRC);
  ReleaseDC(hWnd, hDC);
}
