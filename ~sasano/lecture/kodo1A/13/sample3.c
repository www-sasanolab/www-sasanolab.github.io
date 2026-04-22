#include <windows.h>
#include <scrnsave.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include <stdio.h>

#define ID_TIMER 32767

void EnableOpenGL(HWND, HDC *, HGLRC *);
void DisableOpenGL(HWND, HDC, HGLRC);

typedef enum {LOOP, UP, DOWN, LEFT, RIGHT, ROTATE,
	      LBR, RBR, NUM, ENDOFFILE} token;
int num;

token lex (FILE * fp) {
  char c;
  c=fgetc(fp);
  if (c==' ' || c =='\n' || c=='\t') return lex (fp);
  if (c==EOF) return ENDOFFILE;
  if (c=='{') return LBR;
  if (c=='}') return RBR;
  if (c=='L') goto L;
  if (c=='D') goto D;
  if (c=='U') goto U;
  if (c=='R') goto R;
  if ('0'<=c && c<='9') {
    num=c-'0'; 
    goto Num;
  }
  goto Error;
 L:
  c=fgetc(fp);
  if (c=='o') goto Lo;
  if (c=='e') goto Le;
  goto Error;
 Lo:
  c=fgetc(fp);
  if (c=='o') goto Loo;
  goto Error;
 Loo:
  c=fgetc(fp);
  if (c=='p') return LOOP;
  goto Error;  
 Le:
  c=fgetc(fp);
  if (c=='f') goto Lef;
  goto Error;
 Lef:
  c=fgetc(fp);
  if (c=='t') return LEFT;
  goto Error;
 U:
  c=fgetc(fp);
  if (c=='p') return UP;
  goto Error;
 D:
  c=fgetc(fp);
  if (c=='o') goto Do;
  goto Error;
 Do:
  c=fgetc(fp);
  if (c=='w') goto Dow;
  goto Error;
 Dow:
  c=fgetc(fp);
  if (c=='n') return DOWN;
  goto Error;
 R:
  c=fgetc(fp);
  if (c=='i') goto Ri;
  if (c=='o') goto Ro;
  goto Error;
 Ri:
  c=fgetc(fp);
  if (c=='g') goto Rig;
  goto Error;
 Rig:
  c=fgetc(fp);
  if (c=='h') goto Righ;
  goto Error;
 Righ:
  c=fgetc(fp);
  if (c=='t') return RIGHT;
  goto Error;
 Ro:
  c=fgetc(fp);
  if (c=='t') goto Rot;
  goto Error;
 Rot:
  c=fgetc(fp);
  if (c=='a') goto Rota;
  goto Error;
 Rota:
  c=fgetc(fp);
  if (c=='t') goto Rotat;
  goto Error;
 Rotat:
  c=fgetc(fp);
  if (c=='e') return ROTATE;
  goto Error;
 Num:
  c=fgetc(fp);
  if ('0'<=c && c<='9') {
    num=num*10+c-'0';
    goto Num;
  } else {
    ungetc(c,fp);
    return NUM;
  }	      
 Error:
  fprintf(stderr, "lexical error in Loop or Left\n"); fflush(stderr);
  exit(0); 
}      

typedef enum {
  Up, Down, Left, Right, Rotate
} step;

typedef enum {Step, Loop, Block} SLB;

struct statement{
  SLB slb;
  step step;
  int num;
  struct statement * statement;
  struct statementList * statementList;
};

struct statementList {
  struct statement * statement;
  struct statementList * next;
}; 

step parseStep (FILE * fp, token token) {
  switch (token) {
  case UP:
    return Up;
  case DOWN:
    return Down;
  case LEFT:
    return Left;
  case RIGHT:
    return Right;
  case ROTATE:
    return Rotate;
  }
  fprintf(stderr, "parse error in parseStep with token %d\n", token); 
  fflush(stderr);
  exit(0);
}

void parseStatement (struct statement *, FILE *, token);
void parseStatementList (struct statementList ** statementList, FILE * fp) {
  token token;
  token=lex(fp);
  if (token==RBR) {
    *statementList = NULL;
  } else {
    if(((*statementList)->statement = malloc (sizeof (struct statement)))==NULL){
      fprintf (stderr, "malloc failed 1\n");
      exit(0);
    }
    parseStatement ((*statementList)->statement, fp, token);
    if (((*statementList)->next = malloc (sizeof (struct statementList)))==NULL){
      fprintf (stderr, "malloc failed 2\n");
      exit(0);
    }
    parseStatementList (&((*statementList)->next), fp);
  }  
}

void parseStatement (struct statement * statement, FILE * fp, token token) {
  if (token==LBR){
    statement->slb=Block;
    if ((statement->statementList = malloc (sizeof (struct statementList)))==NULL){
      fprintf (stderr, "malloc failed 3\n");
      exit(0);
    }
    parseStatementList (&(statement->statementList), fp);
  } else if (token==LOOP) {
    statement->slb=Loop;
    token=lex(fp);
    if (token==NUM) {
      statement->num=num;
    } else {
      fprintf (stderr, "parse error in statement\n"); fflush(stderr);
    }
    token = lex (fp);
    if((statement->statement=malloc(sizeof(struct statement)))==NULL){
      fprintf (stderr, "malloc failed 4\n");
      exit(0);
    }
    parseStatement (statement->statement, fp, token);
  } else {
    statement->slb=Step;
    statement->step=parseStep(fp, token);  
  }
}

void parseProgram (struct statement * statement, FILE * fp) {
  token token;
  token = lex (fp);
  parseStatement(statement, fp, token);
  token = lex (fp);
  if (token==ENDOFFILE) return;
  else {
    fprintf (stderr, "parse error in parseProgram\n");
    fflush (stderr);
    exit(0);
  }
}

void rectDisplay (double *r, double *locx, double *locy) {
  glClear(GL_COLOR_BUFFER_BIT);
  glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
  glLoadIdentity();
  glColor3f(0.0, 0.0, 1.0);
  glRotated((double)*r, 0.0, 0.0, 1.0);
  glRectf(*locx-20.0, *locy-20.0, *locx, *locy);
  glFlush();
}

void dispStep (step step, double * locx, double * locy, double * r) {
  switch(step) {
  case Up: 
    (*locy)+=0.01;
    break;
  case Down: 
    (*locy)+=0.01;
    break;
  case Right:
    (*locx)+=0.01;
    break;
  case Left:
    (*locx)+=0.01;
    break;
  case Rotate:
    (*r)+=0.01;
    if (*r>=360) *r=0;
    break;
  }
  rectDisplay(r, locx, locy);
}

void dispStatement (struct statement *, double *, double *, double *);
void dispStatementList (struct statementList * statementList, 
		double * locx, double * locy, double * r) {
  if (statementList==NULL) return;
  dispStatement(statementList->statement, locx, locy, r);
  dispStatementList(statementList->next, locx, locy, r);
}

void dispLoop (int, struct statement *, double *, double *, double *);
void dispStatement (struct statement * statement, double * locx, double * locy, double * r) {
  switch (statement->slb) {
  case Step:
    dispStep(statement->step, locx, locy, r);
    break;
  case Loop:
    dispLoop (statement->num, statement->statement, locx, locy, r);
    break;
  case Block:
    dispStatementList(statement->statementList, locx, locy, r);
    break;
  }
}

void dispLoop (int num, struct statement * statement, double * locx, double * locy, double * r) {
  if (num==0) return;
  else {
    dispStatement (statement, locx, locy, r);
    dispLoop (num-1, statement, locx, locy, r);
  }
}

void display (void) 
{
  /* ここに描画部分本体を入れる(画面更新のたびに呼ばれる) */
  static double locx = 0.0;
  static double locy = 0.0;
  static double r = 0.0; /* 回転角 */
  static FILE *fp=NULL;
  static char c[10];
  static int flag =0;
  token token;
  static struct statement * root;
  step step;
  if (flag==0) { /* first time this function display is called */
    fp=fopen ("sample3", "r");
    if (fp==NULL) {
      fprintf (stderr, "file \"sample3\" open failed\n"); fflush(stderr);
      exit(0);
    }
    if ((root = malloc (sizeof (struct statement)))==NULL) {
      fprintf (stderr, "malloc failed 5\n");
      exit(0);
    }
    parseProgram (root, fp);
  }
  flag=1;
  dispStatement(root, &locx, &locy, &r);
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

    /* ここにOpenGL関連の初期化部分を入れる(起動時，1度しか呼ばれない) */
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-50.0*wx/wy, 50.0*wx/wy, -50.0, 50.0, -5.0, 5.0);
    glMatrixMode(GL_MODELVIEW);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glViewport(0,0,wx,wy);
    /* ここまで */

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

