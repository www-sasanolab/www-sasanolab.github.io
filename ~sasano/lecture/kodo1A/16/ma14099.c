#include <windows.h>
#include <scrnsave.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <math.h>
#include <ctype.h>

#define ID_TIMER 32767
#define Pai 3.1415926

static int LEFT;
static int RIGHT;
static int TOP;
static int BOTTOM;

static int RSIZE;
static int NUM;
static int SMAX;
static int COLL;

void EnableOpenGL(HWND, HDC *, HGLRC *);
void DisableOpenGL(HWND, HDC, HGLRC);
void Circle2DFill(float radius,int x,int y);

void display (char * ssd, double sx, double sy) 
{
  /* ここに描画部分本体を入れる(画面更新のたびに呼ばれる) */

  static int flag =0;
  static int count=0;
  static int nth=0;
  static char direction;
  static double locx = 0.0;
  static double locy = 0.0;
  
  static int xx[100];
  static int yy[100];
  static int num=0;
  static int vx[100];
  static int vy[100];
  static float r[100], g[100], b[100];
  
  
  /* 最初の呼び出し 初期位置の設定 */
  if(num==0) {
		for(int i=0; i<NUM; i++) {
  			xx[i] = rand()%(RIGHT-RSIZE)+RSIZE;
			yy[i] = rand()%(BOTTOM-RSIZE)+RSIZE;
			vx[i] = rand()%SMAX+1;
			vy[i] = rand()%SMAX+1;
			r[i] = (float)rand()/ 32767.0;
			g[i] = (float)rand()/ 32767.0;
			b[i] = (float)rand()/ 32767.0;
		}
		num=NUM;
  }
  
  glClearColor(0.1f, 0.1f, 0.1f, 0.0f);
  glClear(GL_COLOR_BUFFER_BIT);

  glLoadIdentity();
  //glColor3f(0.9, 0.8, 0.7);
  
  /* 各円の移動 */
	for(int i=0; i<num; i++) {
		xx[i]+=vx[i];
		yy[i]+=vy[i];
		if(xx[i]<LEFT+RSIZE || xx[i]>RIGHT-RSIZE) {
			vx[i] = -vx[i];
			xx[i] += vx[i];
		}
		if(yy[i]<TOP+RSIZE || yy[i]>BOTTOM-RSIZE) {
			vy[i] = -vy[i];
			yy[i] += vy[i];
		}
	}
		
	/* 各円ごとの衝突の判定 */
	if(COLL) {
	for(int i=0; i<num; i++) {
		for(int j=i+1; j<num; j++) {
			if(sqrt(pow(xx[i]-xx[j], 2)+pow(yy[i]-yy[j], 2)) < RSIZE*2) {			    
			    int temp=vx[i];
			    vx[i] = vx[j];
			    vx[j] = vy[i];
			    vy[i] = vy[j];
			    vy[j] = temp;
			}
		}
	}
	}
	
	/* 円の描写 */
	for(int i=0; i<num; i++) {
		glColor3f(r[i], g[i], b[i]);
		Circle2DFill((float)RSIZE,xx[i],yy[i]);
	}
	
}

LRESULT WINAPI ScreenSaverProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
  static char ssd[10];
  static FILE *fp=NULL;

  RECT rc;
  static int wx, wy;
  static double sx, sy;
  static HDC hDC;
  static HGLRC hRC;
  
  static char command[256][30];
  
  switch(msg) {

  case WM_CREATE:
    EnableOpenGL(hWnd, &hDC, &hRC );
    GetClientRect(hWnd, &rc);
    wx = rc.right - rc.left;
    wy = rc.bottom - rc.top;
    LEFT = rc.left;
    RIGHT = rc.right;
    TOP = rc.top;
    BOTTOM = rc.bottom;
    
    srand((unsigned) time(NULL));

    /* ここにOpenGL関連の初期化部分を入れる(起動時，1度しか呼ばれない) */
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(rc.left, rc.right, rc.bottom, rc.top, -5.0, 5.0);
    glMatrixMode(GL_MODELVIEW);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glViewport(0,0,wx,wy);
    
    /* スクリーンセーバ記述プログラム読み込み */

    // 初期設定
		SMAX = 30;
		NUM = 10;
		RSIZE = 20;
		COLL=0;
    
    fp=fopen ("ma14099", "r");
    if (fp==NULL) {
      fprintf (stderr, "ファイルオープン失敗\n");
      exit(0);
    }
    
    char c;
    int i, j;
    int rn;
    int cnum=0;
	for(i=0; i<256; i++) {
		command[i][0] = '\0';
	}

	/* 読み込んだ文字列を字句に切り分ける */
    for(i=0; i<256; i++) {
		j=0;
		while(1){
			rn = fscanf(fp, "%c", &c);
			//printf("%c", c);
			if(rn>0) {
				if(c==' '||c=='\n') {
					if(j==0) {
						i--;
					} else {
					command[i][j] = '\0';
					cnum++;
					}
					break;
				}
				command[i][j] = c;
				j++;
			} else {
					if(j==0) {
						i--;
					} else {
					command[i][j] = '\0';
					cnum++;
					}
				//printf("%d", rn);
				break;
			}
		}
		if(rn==-1) {
			break;
		}
	}
	
	/*
	for(int i=0; i<cnum; i++) {
		printf("%d: %s\n", i, command[i]);
	}
	*/
	
	
	/* 記述ファイルに応じて、値の設定 */
	for(i=0; i<cnum; i++) {
		if(strcmp(command[i], "num")==0) {
			//printf("num\n");
			i++;
			if(isdigit(command[i][0])) {
				NUM = atoi(command[i]);
			} else {
				i--;
				NUM++;
			}
		}
		else if(strcmp(command[i], "speed")==0) {
			//printf("speed\n");
			i++;
			if(isdigit(command[i][0])) {
				SMAX = atoi(command[i]);
			} else {
				i--;
			}
		}
		else if(strcmp(command[i], "size")==0) {
			//printf("size\n");
			i++;
			if(isdigit(command[i][0])) {
				RSIZE = atoi(command[i]);
			} else {
				i--;
			}
		}
		else if(strcmp(command[i], "coll")==0) {
			//printf("coll\n");
			COLL=1;
		}
	}
	
	
	//printf("%d,%d,%d,%d", NUM, RSIZE, SMAX, COLL);

    SetTimer(hWnd, ID_TIMER, 30, NULL);//タイマー設定
    break;
  case WM_TIMER:
    display(ssd, sx, sy);
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


void Circle2DFill(float radius,int x,int y)
{
 for (float th1 = 0.0;  th1 <= 360.0;  th1 = th1 + 1.0)
 {             
  float th2 = th1 + 10.0;
  float th1_rad = th1 / 180.0 * Pai; 
  float th2_rad = th2 / 180.0 * Pai;

  float x1 = radius * cos(th1_rad);
  float y1 = radius * sin(th1_rad);
  float x2 = radius * cos(th2_rad);
  float y2 = radius * sin(th2_rad);

  glBegin(GL_TRIANGLES); 
   glVertex2f( x, y );
   glVertex2f( x1+x, y1+y );     
   glVertex2f( x2+x, y2+y );
  glEnd();
 } 
}
