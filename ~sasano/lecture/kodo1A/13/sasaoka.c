#include <windows.h>
#include <scrnsave.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include <stdio.h>
#include <math.h>

#define ID_TIMER 32767

#define M_PI 3.14159265358979	// 円周率	追加
#define PART 100		// 分割数	追加

void EnableOpenGL(HWND, HDC *, HGLRC *);
void DisableOpenGL(HWND, HDC, HGLRC);

static float x, y, r = 10.5;		// 円１用変数
static double R=0.0,G=0.0,B=0.0;	// 色変更用変数
static double rr=0.0;			// 回転角
static int white=0,r_flag=0;

void display(void)
{
	int i, n = PART;
	float x2, y2, r2 = 5.5;		// 円２用変数
	double rate,rate2;		// 円１、２用変数
	float xx;			// 格子四角形描画用

	static FILE *fp=NULL;		// ファイル読み込み
	static char c[10];		// 文字列格納
	static int flag =0;		
	static int count=0;
	static int nth=0;
	static char direction;
	static double locx = 0.0,locy = 0.0;	// 移動図形用

	if (flag==0) {
		fp=fopen ("sample1", "r");		//実行用ファイルの読み込み
		if (fp==NULL) {
			fprintf (stderr, "ファイルオープン失敗\n");
			exit(0);
		}
		for (int i=0; i<10; i++)		//実行用ファイルの読み込み（現在は10文字限定）
			if (fscanf (fp, "%c", &c[i]) ==0){
				fprintf (stderr, "failed\n");
				exit(0);
			}
		direction = c[nth];
	}
	flag=1;
	count++;
	if (count > 10) { 
		count=0;
		nth++;
		if (nth>=10) {
			nth = 0;
			locx=0.0; 
			locy=0.0;
		}
		direction = c[nth];
	}
	switch (direction) {
		case 'U': 
			locy++;
	glColor3f(0.1, 0.8, 0.7);			//色設定
			break;
		case 'D': 
			locy--;
	glColor3f(0.9, 0.1, 0.7);			//色設定
			break;
		case 'R':
			locx++;
	glColor3f(0.9, 0.8, 0.1);			//色設定
			break;
		case 'L':
			locx--;
	glColor3f(0.5, 0.5, 0.5);			//色設定
			break;
	}

	glClear(GL_COLOR_BUFFER_BIT);		// ウィンドウの背景をglClearColor()で指定された色で塗りつぶす
	glClearColor(0.1f, 0.1f, 0.1f, 0.0f);	// 色設定
	glLoadIdentity();			// 座標読み込み

	glRectf(-40.0, -35.0, -30, -25);	//図形
	glRectf(40.0, 35.0, 30, 25);	//図形


//	円の描画
	// 色設定（黒→白）
	glColor3f(R, G, B);	// 描画物体に白色を設定
	if(R<=1 && white==0){
		R+=0.02;
	} else {
		if(G<=1 && white==0){
			G+=0.02;
		} else {
			if(B<=1 && white==0)
				B+=0.02;
			else
				white=1;
		}
	}
	// 色設定（白→黒）
	if(R>=0 && white==1){
		R-=0.02;
	} else {
		if(G>=0 && white==1){
			G-=0.02;
		} else {
			if(B>=0 && white==1)
				B-=0.02;
			else
				white=0;
		}
	}
	// 半径設定
	if(r_flag==0)
		r-=0.1;
	else
		r+=0.1;
	if(r<=2.0)
		r_flag=1;
	if(r>=10.5)
		r_flag=0;
	glBegin(GL_POLYGON);		// 描画開始
	for (i = 0; i < n; i++) {
		// 座標を計算
		rate = (double)i / n;
		x = r * cos(2.0 * M_PI * rate) +locx -40;
		y = r * sin(2.0 * M_PI * rate) +locy +10;
		glVertex3f(x, y, 0.0);	// 頂点座標を指定
	}
	glEnd();			// 描画終了

//	円の描画2
	glBegin(GL_POLYGON);		// 描画開始
	for (i = 0; i < n; i++) {
		// 座標を計算
		rate = (double)i / n;
		x = r * cos(2.0 * M_PI * rate) -locx +40;	// 移動用
		y = r * sin(2.0 * M_PI * rate) -locy -10;
		glVertex3f(x, y, 0.0); // 頂点座標を指定
	}
	glEnd();

	// 図形の回転
	rr+=2.0;	// 回転速度
	// 一周回ったら回転角を 0 に戻す
	if (rr >= 360)
		rr = 0.0;
	glRotated(rr, 0.0, 1.0, 0.0);
	// 四角形の描画
	glBegin(GL_POLYGON);
	glColor3d(1.0, 0.0, 0.0); // 赤
	glVertex2d(-7.4, -7.4);
	glColor3d(0.0, 1.0, 0.0); // 緑
	glVertex2d(7.4, -7.4);
	glColor3d(0.0, 0.0, 1.0); // 青
	glVertex2d(7.4, 7.4);
	glColor3d(1.0, 1.0, 0.0); // 黄
	glVertex2d(-7.4, 7.4);
	glEnd();
	glFlush();		//これまでの設定を実行する
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

		SetTimer(hWnd, ID_TIMER, 15, NULL);//タイマー設定
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
