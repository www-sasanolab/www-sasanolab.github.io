#include <windows.h>
#include <scrnsave.h>
#include <gl/gl.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/types.h>
#include <process.h>
#include <cmath>
#include <iostream>
#include <fstream>
#include <string>
#include <sstream>

void EnableOpenGL(void); // prototype宣言
void DisableOpenGL(HWND); // prototype宣言
HDC hDC;
HGLRC hRC;
int wx, wy; // displayの横と縦のpixel数格納用変数
int finish = 0; /* 生成したスレッドを終了させるかどうかを最初のスレッド
		   から通知するための変数。0なら終了しない、1なら終了 */

struct PNT{
	double x;
	double y;
};


class point{
	private:
		double r,g,b;
		int rad=0;
		int movecount=0;
		PNT startpoint; 
		PNT destination[100];
		int destinationcount = 1;
		int numofdestination ;
		int numofmove=0;
		
		bool flag = true;
		double l = 0;
		
		bool fin = false;
		
		double locx=0.0,locy=0.0;
		double displacementx,displacementy;
		PNT points[10000];
		int count=0;
		
		struct CL{
			double dx=0;
			double dy=0;
		}cl[10000];
	public:
		point(double r,double g,double b,PNT *destination,int numofdestination);
		bool draw();
		void lum();
		void setdirection();
		void setpoint();
		void drawstar();
		void drawcrush(int v);
		int getcount();
};

bool point::draw(){
	lum();
	if(numofmove == movecount){
		if(destinationcount == numofdestination){
			fin = true;
		}
		setdirection();
		movecount = 0;
	}

	
	glColor3f(r+l, g+l, b+l); // glRectf等で描画するときの色設定
	glPointSize(2.0);
	glBegin(GL_POINTS);
	
	//過去の点を全て描画
	for(int j=0;j<count;j++){
		glVertex2f(points[j].x,points[j].y);
	}
	glEnd();
	//ここまで
	
	if(fin == false){	
		drawstar();
		setpoint();
		points[count].x = locx;
		points[count].y = locy;
		cl[count].dx = 0.001*(rand() % 500) + 0.02;
		if(rand()%2){
			cl[count].dx *= -1;
		}
		cl[count].dy = 0.001*(rand() % 500) + 0.02;
		if(rand()%2){
			cl[count].dy *= -1;
		}
		count++;
	}
	return fin;
}

point::point(double r2,double g2,double b2,PNT *destination2,int numofdestination2){
	r = r2;
	g = g2;
	b = b2;
	for(int i=0;i<numofdestination2;i++){
		destination[i] = destination2[i];
	}
	startpoint.x = destination[0].x;
	startpoint.y = destination[0].y;
	numofdestination = numofdestination2;
	
}

void point::lum(){
	if(flag == true){
		l += 0.007;
		if(l >= 0.6){
			flag = false;
		}
	}else{
		l -= 0.007;
		if(l <= 0){
			flag = true;
		}
	}
}

void point::setdirection(){
	double distance;
	
	distance = std::sqrt((destination[destinationcount].x - startpoint.x)*(destination[destinationcount].x - startpoint.x) + 
						 (destination[destinationcount].y - startpoint.y)*(destination[destinationcount].y - startpoint.y));
	
	numofmove = (int)(distance / 0.1);
	displacementx = (destination[destinationcount].x - startpoint.x) / numofmove;
	displacementy = (destination[destinationcount].y - startpoint.y) / numofmove;
	
	locx = startpoint.x;
	locy = startpoint.y;
	
	startpoint.x =destination[destinationcount].x;
	startpoint.y =destination[destinationcount].y;
	destinationcount++;
	
}

void point::setpoint(){
	locx += displacementx;
	locy += displacementy;
	movecount++;
}

void point::drawstar(){
	glPushMatrix();
	glTranslatef(locx, locy, 0.0);
	glRotatef((double)rad, 0.0, 0.0, 1.0);
	glBegin(GL_POLYGON);
	glColor4f(0.3+l, 0.3+l, 0.3+l, 0.0);
	glVertex2f(0,2);
	glVertex2f(0.2,0);
	glVertex2f(0,-2);
	glVertex2f(-0.2,0);
	glEnd();
	glBegin(GL_POLYGON);
	glColor4f(0.3+l, 0.3+l, 0.3+l, 0.0);
	glVertex2f(2,0);
	glVertex2f(0,-0.2);
	glVertex2f(-2,0);
	glVertex2f(0,0.2);
	glEnd();
	glPopMatrix();
	rad+=2;
	if(rad == 360){
		rad = 0;
	}
}

void point::drawcrush(int v){
	lum();
	for(int i=0;i<count;i+=v){
		points[i].x += cl[i].dx;
		points[i].y += cl[i].dy;
		glPushMatrix();
		glTranslatef(points[i].x,points[i].y, 0.0);
		glRotatef((double)rad, 0.0, 0.0, 1.0);
		glBegin(GL_POLYGON);
		glColor4f(r+l, g+l, b+l, 0.0);
		glVertex2f(0,1);
		glVertex2f(0.1,0);
		glVertex2f(0,-1);
		glVertex2f(-0.1,0);
		glEnd();
		glBegin(GL_POLYGON);
		glColor4f(r+l, g+l, b+l, 0.0);
		glVertex2f(1,0);
		glVertex2f(0,-0.1);
		glVertex2f(-1,0);
		glVertex2f(0,0.1);
		glEnd();
		glPopMatrix();
	}
	rad+=8;
	if(rad == 360){
		rad = 0;
	}
}

int point::getcount(){
	return count;
}


bool display (point **poi,int num) 
{
	static int k=0;
	static bool cru;
	static int allcount = 0;
	bool fin[num];
	static int u;
	glClear(GL_COLOR_BUFFER_BIT);
	if(cru == false){
		for(int i=0;i<num;i++){
			fin[i] = poi[i]->draw();
		}
		for(int i=0;i<num;i++){
			if(fin[i] == false){
				k=0;
				allcount = 0;
				return false;
			}
		}
	}
	if(k==0){
		for(int i=0;i<num;i++){
			allcount += poi[i]->getcount();
		}
		u = allcount / 2500;
		if(u == 0){
			u = 1;
		}
		//std::cout << allcount << std::endl;
		//std::cout << u << std::endl;
	}

	k++;
	if(k >= 300){
		cru = true;
		for(int i=0;i<num;i++){
			poi[i]->drawcrush(u);
		}
	}
	if(k >= 1000){
		cru = false;
		return true;
	}
	return false;
}

unsigned __stdcall disp (void *arg) {
  char ssd[100];
  FILE *fp=NULL;
  srand((unsigned)time(NULL));
  EnableOpenGL(); // OpenGL設定

  /* OpenGL初期設定 */
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrtho(-50.0*wx/wy, 50.0*wx/wy, -50.0, 50.0, -50.0, 50.0); // 座標系設定

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glClearColor(0.0f, 0.0f, 0.0f, 0.0f); // glClearするときの色設定
  glViewport(0,0,wx,wy);
  /* ここまで */

  /* スクリーンセーバ記述プログラム読み込み */
	std::ifstream ifs("TA.txt");
	if (ifs.fail()){
		std::cout << "error" << std::endl;
		return -1;
	}
	point *poi[100];
	
	PNT dst[100];
	std::string str;
	double r,g,b;
	int num=0,k;
	bool bo;
	std::string token;
	
	while(1){
	num=0;
	str = "test";
	while(getline(ifs,str)){
		if(str == "||"){
			break;
		}
		std::istringstream stream(str);
		getline(stream,token,',');
		r=stod(token);
		getline(stream,token,',');
		g=stod(token);
		getline(stream,token,',');
		b=stod(token);
		bo = true;
		k=0;
		while(getline(stream,token,',')){
			if(bo){
				dst[k].x = stod(token);
				bo = false;
			}else{
				dst[k].y = stod(token);
				bo = true;
				k++;
			}
		}
		poi[num] = new point(r,g,b,dst,k);
		num++;
	}
  /* ここまで */



  /* 表示関数呼び出しの無限ループ */  
  while(1) {
    Sleep(5); // 0.005秒待つ
    bool test = display(poi,num); // 描画関数呼び出し
    glFlush(); // 画面描画強制
    SwapBuffers(hDC); // front bufferとback bufferの入れ替え
    if (finish == 1) // finishが1なら描画スレッドを終了させる
      return 0;
	if(test == true){
		break;
	}
  }
	for(int i=0;i<num;i++){
		delete poi[i];
	}
	if(ifs.eof()){
		ifs.clear();
		ifs.seekg(0);
	}
	
  }
  
}

LRESULT WINAPI ScreenSaverProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
  static HANDLE thread_id1;
  static unsigned dummy;
  RECT rc;

  switch(msg) {
  case WM_CREATE:
    hDC = GetDC(hWnd); // ウィンドウハンドルhWndからデバイスコンテクストを取得
    GetClientRect(hWnd, &rc); /* hWndのウィンドウの左上と右下の座標を
				 構造体rcに格納する。*/
    wx = rc.right - rc.left; /* GetClientRectで取得した左上、右下の座標を使って
				displayの横のpixel数を計算 */
    wy = rc.bottom - rc.top; /* GetClientRectで取得した左上、右下の座標を使って
				displayの縦のpixel数を計算 */

    thread_id1=(HANDLE)_beginthreadex(NULL, 0, disp, &dummy, 0, &dummy); // 描画用スレッド生成
    if(thread_id1==0){ // スレッド生成に失敗したらスクリーンセーバを終了
      fprintf(stderr,"pthread_create : %s", strerror(errno));
      exit(0);
    }
    break;
  case WM_ERASEBKGND:
    return TRUE;
  case WM_DESTROY: // マウスやキーボードの入力があるとここに来る
    finish=1; // 描画スレッドを終了させるために1を代入
    WaitForSingleObject(thread_id1, INFINITE); // 描画スレッドの終了を待つ
    CloseHandle(thread_id1); // 生成したスレッドを閉じる
    DisableOpenGL(hWnd);
    PostQuitMessage(0); /* 自分のスレッド（メインスレッド）を終了していいことを
			   自分のメッセージキューに入れる。 */
    return 0;
  default: // 上記以外のメッセージの場合はswitch文を終了。（これは書かなくても同じだが。）
    break;
  }
  return DefScreenSaverProc(hWnd, msg, wParam, lParam); /* 上のswitch文で処理していない
							   メッセージを処理してからreturn。*/
}

/* https://msdn.microsoft.com/ja-jp/library/cc422062.aspx 参照 */
BOOL WINAPI ScreenSaverConfigureDialog(HWND hDlg, UINT msg, WPARAM wParam, LPARAM lParam)
{
  return TRUE;
}

/* https://msdn.microsoft.com/ja-jp/library/cc422061.aspx 参照 */
BOOL WINAPI RegisterDialogClasses(HANDLE hInst)
{
  return TRUE;
}

void EnableOpenGL(void) {
  int format;
  /* https://msdn.microsoft.com/en-us/library/windows/desktop/dd368826(v=vs.85).aspx
     を参照 */
  PIXELFORMATDESCRIPTOR pfd = {
    sizeof(PIXELFORMATDESCRIPTOR), // size of this pfd
    1,                     // version number
    0
    | PFD_DRAW_TO_WINDOW   // support window
    | PFD_SUPPORT_OPENGL   // support OpenGL
    | PFD_DOUBLEBUFFER     /* double buffered 
			      (front bufferとback bufferの2枚使う) */
    ,      
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

  /* OpenGL設定 */  
  /* https://msdn.microsoft.com/en-us/library/windows/desktop/dd318284(v=vs.85).aspx 参照 */
  format = ChoosePixelFormat(hDC, &pfd);
  /* https://msdn.microsoft.com/en-us/library/windows/desktop/dd369049(v=vs.85).aspx 参照 */
  SetPixelFormat(hDC, format, &pfd);
  /* https://msdn.microsoft.com/en-us/library/windows/desktop/dd374379(v=vs.85).aspx 参照 */
  hRC = wglCreateContext(hDC);
  /* https://msdn.microsoft.com/en-us/library/windows/desktop/dd374387(v=vs.85).aspx 参照 */
  wglMakeCurrent(hDC, hRC);
  /* ここまで */
}

void DisableOpenGL(HWND hWnd)
{
  /* https://msdn.microsoft.com/en-us/library/windows/desktop/dd374387(v=vs.85).aspx 参照 */
  wglMakeCurrent(NULL, NULL);
  /* https://msdn.microsoft.com/en-us/library/windows/desktop/dd374381(v=vs.85).aspx 参照 */
  wglDeleteContext(hRC);
  /* https://msdn.microsoft.com/en-us/library/windows/desktop/dd162920(v=vs.85).aspx 参照 */
  ReleaseDC(hWnd, hDC);
}
