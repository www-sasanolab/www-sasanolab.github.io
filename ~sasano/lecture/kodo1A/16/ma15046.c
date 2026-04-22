#include <windows.h>
#include <scrnsave.h>
#include <gl/gl.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define ID_TIMER 32767
#define Pai 3.1415926
#define BulletNum 6

void EnableOpenGL(HWND, HDC *, HGLRC *);
void DisableOpenGL(HWND, HDC, HGLRC);

/* 弾 */
typedef struct{
	int exist;	//存在判定
	double locX;	//X座標
	double locY;	//Y座標
	double speed;	//弾速
}Bullet;

enum STATE{
	NEUTRAL,
	L,LE,LEF,LEFT,
	R,RI,RIG,RIGH,RIGHT,
	S,SH,SHO,SHOT,
	W,WA,WAI,WAIT,
	TOVALUE,VALUE,TOEND
};

/* コマンドリスト */
typedef struct command{
	enum STATE com;
	int value;
	struct command *next;
}Command;

void setBullet(Bullet *b,double X,double Y,int val);
void printBullet(Bullet *b);
void Circle2DFill(float radius,int x,int y);

void display (Command *list) 
{
  /* ここに描画部分本体を入れる(画面更新のたびに呼ばれる) */
  static int i=0;
  static double locX = 0;
  static double locY = -20.0;
  static int value;
  static Command *currentCommand;
  static enum STATE currentState;
  static int flag = 0;	//0:command読込,1:command実行中
  static int init = 0;
  static Bullet bullet[BulletNum];
  
  if(init == 0){
	currentCommand = list;
	for(i=0;i<BulletNum;i++) bullet[i].exist = 0;
	init = 1;
  }
  if(flag == 0){
  	value = currentCommand->value;
  	currentState = currentCommand->com;
  	//printf("VALUE:%d\n",value);
  	i = 0;
  	flag = 1;
  }else{
	if(i == value){
		 flag = 0;
		 currentCommand = currentCommand->next;
	}
	else{
		i++;
		switch(currentState){
			case LEFT:
				printf("LEFT:%d\n",i);
				locX -= 0.5;
				break;
			case RIGHT:
				printf("RIGHT:%d\n",i);
				locX += 0.5;
				break;
			case SHOT:
				setBullet(bullet,locX,locY,value);
				printf("BULLET SET OK\n");
				i = value;
				break;
			case WAIT:
				break;
			default:
				fprintf(stderr, "undefined command.\n");
				exit(0);
		}
	}
  }
  
  glClear(GL_COLOR_BUFFER_BIT);
  //glRectf(locX-20.0, locY-20.0, locX, locY);
  glColor3f(1.0, 1.0, 1.0);
  glBegin(GL_POLYGON);
   glVertex3f(locX-5.0,locY-5.0,0.0);	/* 左下 */
   glVertex3f(locX+5.0,locY-5.0,0.0);	/* 右下 */
   glVertex3f(locX,locY,0.0);	/* 上   */
   glEnd();
  
  printBullet(bullet);
}

void setBullet(Bullet *b,double X,double Y,int val){
	int i;
	for(i=0;i<BulletNum;i++){
		if(b[i].exist == 0){
			printf("BULLET(%d):set\n",i);
			b[i].exist = 1;
			b[i].locX = X;
			b[i].locY = Y;
			b[i].speed = val;
			return;
		}
	}
}

void printBullet(Bullet *b){
	int i;
	for(i=0;i<BulletNum;i++){
		if(b[i].exist == 1){
			glColor3f(0.3, 0.3, 0.3);
			Circle2DFill(1.0,b[i].locX,b[i].locY);
			b[i].locY += b[i].speed/10.0;
			//glRectf(b[i].locX-15.0, b[i].locY-10.0, b[i].locX-5.0, b[i].locY);
			glColor3f(1.0, 1.0, 1.0);
			Circle2DFill(1.0,b[i].locX,b[i].locY);
			if(b[i].locY-1.0 > 50.0) b[i].exist = 0;
		}
	}
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

LRESULT WINAPI ScreenSaverProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
  static char ssd[100];
  static FILE *fp=NULL;
  
  static char token;
  static enum STATE state = NEUTRAL;
  static Command *top;
  static Command *current;
  static Command *prev;
  static int value = 0;

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
    glColor3f(0.9, 0.8, 0.7);
    glViewport(0,0,wx,wy);
    /* ここまで */

    /* スクリーンセーバ記述プログラム読み込み */
    fp=fopen ("ma15046", "r");
    if (fp==NULL) {
      fprintf (stderr, "ファイルオープン失敗\n");
      exit(0);
    }else{
    	top = (Command*)malloc(sizeof(Command));
    	current = top;
    }
    while(fscanf (fp, "%c", &token) != EOF){
		switch(token){
			case 'l':
				if(state == NEUTRAL){
					state = L;
					break;
				}else{
					printf("syntax error:%d\n",state);
					exit(0);
				}
			case 'e':
				if(state == L){
					state = LE;
					break;
				}else{
					printf("syntax error:%d\n",state);
					exit(0);
				}
			case 'f':
				if(state == LE){
					state = LEF;
					break;
				}else{
					printf("syntax error:%d\n",state);
					exit(0);
				}
			case 't':
				switch(state){
					case LEF:
						current->com = LEFT;
						state = TOVALUE;
						break;
					case RIGH:
						current->com = RIGHT;
						state = TOVALUE;
						break;
					case SHO:
						current->com = SHOT;
						state = TOVALUE;
						break;
					case WAI:
						current->com = WAIT;
						state = TOVALUE;
						break;
					default:
						printf("syntax error:%d\n",state);
						exit(0);
				}
				break;
			case 'r':
				if(state == NEUTRAL){
					state = R;
					break;
				}else{
					printf("syntax error:%d\n",state);
					exit(0);
				}
			case 'i':
				switch(state){
					case R:
						state = RI;
						break;
					case WA:
						state = WAI;
						break;
					default:
						printf("syntax error:%d\n",state);
						exit(0);
				}
				break;
			case 'g':
				if(state == RI){
					state = RIG;
					break;
				}else{
					printf("syntax error:%d\n",state);
					exit(0);
				}
			case 'h':
				switch(state){
					case RIG:
						state = RIGH;
						break;
					case S:
						state = SH;
						break;
					default:
						printf("syntax error:%d\n",state);
						exit(0);
				}
				break;
			case 's':
				if(state == NEUTRAL){
					state = S;
					break;
				}else{
					printf("syntax error:%d\n",state);
					exit(0);
				}
			case 'o':
				if(state == SH){
					state = SHO;
					break;
				}else{
					printf("syntax error:%d\n",state);
					exit(0);
				}
			case 'w':
				if(state == NEUTRAL){
					state = W;
					break;
				}else{
					printf("syntax error:%d\n",state);
					exit(0);
				}
			case 'a':
				if(state == W){
					state = WA;
					break;
				}else{
					printf("syntax error:%d\n",state);
					exit(0);
				}
			case ' ':
			case '\t':
			case '\n':
				switch(state){
					case NEUTRAL:
					case TOVALUE:
					case TOEND:
						break;
					case VALUE:
						state = TOEND;
						break;
					default:
						printf("syntax error:%d\n",state);
						exit(0);
				}
				break;
			case '0':
				switch(state){
					case TOVALUE:
						state = TOEND;
						break;
					case VALUE:
						value *= 10;
						break;
					default:
						printf("syntax error:%d\n",state);
						exit(0);
				}
				break;
			case '1':
			case '2':
			case '3':
			case '4':
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				switch(state){
					case TOVALUE:
					case VALUE:
						state = VALUE;
						value *= 10;
						value += token - '0';
						break;
					default:
						printf("syntax error:%d\n",state);
						exit(0);
				}
				break;
			case ';':
				switch(state){
					case NEUTRAL:
					case VALUE:
					case TOEND:
						state = NEUTRAL;
						prev = current;
						current->value = value;
						current->next = (Command*)malloc(sizeof(Command));
						current = current->next;
						value = 0;
						break;
					default:
						printf("syntax error:%d\n",state);
						exit(0);
				}
				break;
			default:
				printf("syntax error:%d\n",state);
				exit(0);
		}
	}
  	if(state != NEUTRAL){
  		printf("syntax error:%d\n",state);
		exit(0);
  	}else{
  		prev->next = top;
  	}
    /* ここまで */

    SetTimer(hWnd, ID_TIMER, 15, NULL);//タイマー設定
    break;
  case WM_TIMER:
    display(top);
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

