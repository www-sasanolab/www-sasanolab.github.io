#include <windows.h>
#include <scrnsave.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include <stdio.h>

#define ID_TIMER 32767

void EnableOpenGL(HWND, HDC *, HGLRC *);
void DisableOpenGL(HWND, HDC, HGLRC);

void display (char * ssd) 
{
  /* ここに描画部分本体を入れる(画面更新のたびに呼ばれる) */
  static int flag =0;
  static int i=0;
  static char direction;
  static double locx = 0.0;
  static double locy = 0.0;

  i=i % 100;
  direction = ssd[i];
  i++;
  switch (direction) {
  case 'U': 
    locy++;
    break;
  case 'D': 
    locy--;
    break;
  case 'R':
    locx++;
    break;
  case 'L':
    locx--;
    break;
  }
  glClear(GL_COLOR_BUFFER_BIT);
  glClearColor(0.1f, 0.2f, 0.3f, 0.0f);

  glLoadIdentity();
  glColor3f(0.9, 0.8, 0.7);
  glRectf(locx-20.0, locy-20.0, locx, locy);
}

LRESULT WINAPI ScreenSaverProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
  static char ssd[100];
  static FILE *fp=NULL;

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
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glViewport(0,0,wx,wy);
    /* ここまで */

    /* スクリーンセーバ記述プログラム読み込み */
    fp=fopen ("sample1", "r");
    if (fp==NULL) {
      fprintf (stderr, "ファイルオープン失敗\n");
      exit(0);
    }
    for (int i=0; i<100; i++)
      if (fscanf (fp, "%c", &ssd[i]) ==0){
	fprintf (stderr, "failed\n");
	exit(0);
      }
    /* ここまで */

    SetTimer(hWnd, ID_TIMER, 15, NULL);//タイマー設定
    break;
  case WM_TIMER:
    display(ssd);
    glFlush();
    SwapBuffers(hDC);
    break;
  case WM_ERASEBKGND:
    return TRUE;
  case WM_DESTROY:
    KillTimer(hWnd, ID_TIMER);
    DisableOpenGL(hWnd, hDC, hRC);
    PostQuitMessage(0);
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

