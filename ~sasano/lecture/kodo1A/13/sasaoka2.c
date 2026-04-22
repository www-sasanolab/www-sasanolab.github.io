#include <windows.h>
#include <scrnsave.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include <stdio.h>
#include <stdlib.h>		// 追加
#include <math.h>

#define ID_TIMER 32767
#define N 9999			// 配列要素数。大きい数字

void EnableOpenGL(HWND, HDC *, HGLRC *);
void DisableOpenGL(HWND, HDC, HGLRC);

// 図形構築関数
void L1(double,double);
void L2(double,double);
void L3(double,double);
void L4(double,double);
void L5(double,double);
void L6(double,double);
void L7(double,double);
int counter(double);

void display(void)
{
	static int i,ret;
	static FILE *fp=NULL;		// ファイルポインタ
	static int flag=0;		// ファイル読込フラグ
	static int count=0;		// カウンタ
	static char num[N],x[N],y[N];
	static double num0,x0,y0;
	static int a;
	double plus=0.0;

	if (flag==0) {
		fp=fopen ("sasaoka2", "r");  //実行用ファイルの読み込み
		if (fp==NULL) {
			fprintf (stderr, "ファイルオープン失敗\n");
			exit(0);
		}
		ret=fscanf( fp, "%s %s %s", num, x, y);
//		printf("%s %s %s\n", num, x, y);
		//x,yの数値化処理
		num0 = atof(num);
		a=counter(num0);
		x0 = atof(x);
		y0 = atof(y);
//		printf("num0=%f x0=%f y0=%f\n",num0,x0,y0);
	}
	flag=1;

	count++;			// 次の文字列を読み込むまでの間隔指定
	if (count > 5) { 		// 指定回数displayを実行されたかの判定
		count=0;		// カウンタ初期化
		// データを1行読み込み。読み込むデータが無くなった場合、再度ファイルを読み込ませる
		if((ret=fscanf( fp, "%s %s %s", num, x, y))==EOF){
			fp=fopen ("sasaoka2", "r");
			if (fp==NULL) {
				fprintf (stderr, "ファイルオープン失敗\n");
				exit(0);
			}
			ret=fscanf( fp, "%s %s %s", num, x, y);
		}
//		printf("%s %s %s\n", num, x, y);
		//x,yの数値化処理
		num0 = atof(num);
		a=counter(num0);
		x0 = atof(x);
		y0 = atof(y);
//		printf("num0=%f x0=%f y0=%f\n",num0,x0,y0);
	}


	glClear(GL_COLOR_BUFFER_BIT);		// ウィンドウの背景をglClearColor()で指定された色で塗りつぶす
//	glClearColor(0.1f, 0.1f, 0.1f, 0.0f);	// 色設定
	glLoadIdentity();			// 座標読み込み
/*--------------------------------------------------
	 -	L5
	| |	L1 L3
	 -	L6
	| |	L2 L4
	 -	L7

L1(x,y);	// 左上
L2(x,y);	// 左下
L3(x,y);	// 右上
L4(x,y);	// 右下
L5(x,y);	// 上
L6(x,y);	// 中
L7(x,y);	// 下
＊同じ数字を出すときは同じ引数を与える
--------------------------------------------------*/

	for(i=0;i<a;i++){
		switch (num[i]) {
			case '0':
				L5(x0+plus,y0); L1(x0+plus,y0); L3(x0+plus,y0); L2(x0+plus,y0); L4(x0+plus,y0); L7(x0+plus,y0);
				plus+=11.0;
				break;
			case '1':
				L3(x0+plus,y0); L4(x0+plus,y0);
				plus+=11.0;
				break;
			case '2':
				L5(x0+plus,y0); L3(x0+plus,y0); L6(x0+plus,y0); L2(x0+plus,y0); L7(x0+plus,y0);
				plus+=11.0;
				break;
			case '3':
				L5(x0+plus,y0); L3(x0+plus,y0); L6(x0+plus,y0); L4(x0+plus,y0); L7(x0+plus,y0);
				plus+=11.0;
				break;
			case '4':
				L1(x0+plus,y0); L3(x0+plus,y0); L6(x0+plus,y0); L4(x0+plus,y0);
				plus+=11.0;
				break;
			case '5':
				L5(x0+plus,y0); L1(x0+plus,y0); L6(x0+plus,y0); L4(x0+plus,y0); L7(x0+plus,y0);
				plus+=11.0;
				break;
			case '6':
				L5(x0+plus,y0); L1(x0+plus,y0); L6(x0+plus,y0); L2(x0+plus,y0); L4(x0+plus,y0); L7(x0+plus,y0);
				plus+=11.0;
				break;
			case '7':
				L5(x0+plus,y0); L3(x0+plus,y0); L4(x0+plus,y0);
				plus+=11.0;
				break;
			case '8':
				L5(x0+plus,y0); L1(x0+plus,y0); L3(x0+plus,y0); L6(x0+plus,y0); L2(x0+plus,y0); L4(x0+plus,y0); L7(x0+plus,y0);
				plus+=11.0;
				break;
			case '9':
				L5(x0+plus,y0); L1(x0+plus,y0); L3(x0+plus,y0); L6(x0+plus,y0); L4(x0+plus,y0); L7(x0+plus,y0);
				plus+=11.0;
				break;
		}
	}
	glFlush();		//これまでの設定を実行する
}


void L1(double x,double y){
	glColor3f(1.0, 0.6, 0.2);
	glBegin(GL_POLYGON);		// 描画開始
	glVertex3f(x, y, 0.0);	// 頂点座標を指定
	glVertex3f(x, y-5, 0.0);	// 頂点座標を指定
	glVertex3f(x+1, y-6, 0.0);	// 頂点座標を指定
	glVertex3f(x+2, y-5, 0.0);	// 頂点座標を指定
	glVertex3f(x+2, y, 0.0);	// 頂点座標を指定
	glVertex3f(x+1, y+1, 0.0);	// 頂点座標を指定
	glEnd();
}

void L2(double x,double y){
	glColor3f(1.0, 0.6, 0.2);
	glBegin(GL_POLYGON);		// 描画開始
	glVertex3f(x, y-7.5, 0.0);	// 頂点座標を指定
	glVertex3f(x, y-12.5, 0.0);	// 頂点座標を指定
	glVertex3f(x+1, y-13.5, 0.0);	// 頂点座標を指定
	glVertex3f(x+2, y-12.5, 0.0);	// 頂点座標を指定
	glVertex3f(x+2, y-7.5, 0.0);	// 頂点座標を指定
	glVertex3f(x+1, y-6.5, 0.0);	// 頂点座標を指定
	glEnd();
}

void L3(double x,double y){
	glColor3f(1.0, 0.6, 0.2);
	glBegin(GL_POLYGON);		// 描画開始
	glVertex3f(x+8, y, 0.0);	// 頂点座標を指定
	glVertex3f(x+8, y-5, 0.0);	// 頂点座標を指定
	glVertex3f(x+9, y-6, 0.0);	// 頂点座標を指定
	glVertex3f(x+10, y-5, 0.0);	// 頂点座標を指定
	glVertex3f(x+10, y, 0.0);	// 頂点座標を指定
	glVertex3f(x+9, y+1, 0.0);	// 頂点座標を指定
	glEnd();
}

void L4(double x,double y){
	glColor3f(1.0, 0.6, 0.2);
	glBegin(GL_POLYGON);		// 描画開始
	glVertex3f(x+8, y-7.5, 0.0);	// 頂点座標を指定
	glVertex3f(x+8, y-12.5, 0.0);	// 頂点座標を指定
	glVertex3f(x+9, y-13.5, 0.0);	// 頂点座標を指定
	glVertex3f(x+10, y-12.5, 0.0);	// 頂点座標を指定
	glVertex3f(x+10, y-7.5, 0.0);	// 頂点座標を指定
	glVertex3f(x+9, y-6.5, 0.0);	// 頂点座標を指定
	glEnd();
}

void L5(double x,double y){
	glColor3f(1.0, 0.6, 0.2);
	glBegin(GL_POLYGON);		// 描画開始
	glVertex3f(x+2.5, y+2, 0.0);	// 頂点座標を指定
	glVertex3f(x+7.5, y+2, 0.0);	// 頂点座標を指定
	glVertex3f(x+8.5, y+1, 0.0);	// 頂点座標を指定
	glVertex3f(x+7.5, y, 0.0);	// 頂点座標を指定
	glVertex3f(x+2.5, y, 0.0);	// 頂点座標を指定
	glVertex3f(x+1.5, y+1, 0.0);	// 頂点座標を指定
	glEnd();
}

void L6(double x,double y){
	glColor3f(1.0, 0.6, 0.2);
	glBegin(GL_POLYGON);		// 描画開始
	glVertex3f(x+2.5, y-5.25, 0.0);	// 頂点座標を指定
	glVertex3f(x+7.5, y-5.25, 0.0);	// 頂点座標を指定
	glVertex3f(x+8.5, y-6.25, 0.0);	// 頂点座標を指定
	glVertex3f(x+7.5, y-7.25, 0.0);	// 頂点座標を指定
	glVertex3f(x+2.5, y-7.25, 0.0);	// 頂点座標を指定
	glVertex3f(x+1.5, y-6.25, 0.0);	// 頂点座標を指定
	glEnd();
}

void L7(double x,double y){
	glColor3f(1.0, 0.6, 0.2);
	glBegin(GL_POLYGON);		// 描画開始
	glVertex3f(x+2.5, y-12.5, 0.0);	// 頂点座標を指定
	glVertex3f(x+7.5, y-12.5, 0.0);	// 頂点座標を指定
	glVertex3f(x+8.5, y-13.5, 0.0);	// 頂点座標を指定
	glVertex3f(x+7.5, y-14.5, 0.0);	// 頂点座標を指定
	glVertex3f(x+2.5, y-14.5, 0.0);	// 頂点座標を指定
	glVertex3f(x+1.5, y-13.5, 0.0);	// 頂点座標を指定
	glEnd();
}

int counter(double x){
	if(x>-10 && x<10)
		return 1;
	else if(x>-100 && x<100)
		return 2;
	else if(x>-1000 && x<1000)
		return 3;
	printf("エラー：4桁以上の数値が入力されています\n");
	return -1;
}


LRESULT WINAPI ScreenSaverProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
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

		// ここにOpenGL関連の初期化部分を入れる(起動時，1度しか呼ばれない)
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		glOrtho(-50.0*wx/wy, 50.0*wx/wy, -50.0, 50.0, -5.0, 5.0);
		glMatrixMode(GL_MODELVIEW);
		glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
		glViewport(0,0,wx,wy);
		// ここまで
		SetTimer(hWnd, ID_TIMER, 30, NULL);	//タイマー設定(元：15
		break;
	case WM_TIMER:
		display();
		glFlush();
		SwapBuffers( hDC );
		break;
	case WM_ERASEBKGND:
		return TRUE;
	case WM_DESTROY:
		KillTimer(hWnd, ID_TIMER);
		DisableOpenGL( hWnd, hDC, hRC );
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
		sizeof(PIXELFORMATDESCRIPTOR),  // size of this pfd
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
