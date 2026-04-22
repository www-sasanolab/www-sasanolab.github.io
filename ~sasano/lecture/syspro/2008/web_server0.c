/* web_server0.c 簡易web server(の準備) */
#include    <stdio.h>
/* INETソケット通信に必要なヘッダーファイル */
#include    <sys/types.h>
#include    <sys/socket.h>
#include    <sys/stat.h>
#include    <netinet/in.h>
#include    <signal.h>

#define     BUFSIZE     1024	    /* バッファサイズ */
#define     ERR         -1	    /* システムコールのエラー */
#define     SERVER_PORT 50000	    /* サーバのソケットの名前（ポート番号） */

main(int argc, char *argv[])
{
    int                 sockfd;	    /* socket()の返すファイル記述子 */
    int                 ns;	    /* accept()の返すファイル記述子 */
    int i;
    struct  sockaddr_in server;	    /* サーバプロセスのソケットアドレス情報 */
    struct  sockaddr_in client;	    /* クライアントプロセスのソケットアドレス情報 */
    int                 fromlen;    /* クライアントプロセスのソケットアドレス情報の長さ */
    char                buf[BUFSIZE];	/* メッセージを格納するバッファ */
    char                readbuf [BUFSIZE];  /* ファイル読み込み用バッファ */
    int                 msglen;	    /* メッセージ長 */
    const int one = 1;
    int readbyte;
    FILE *file;

    if(argc != 2){		
    	fprintf(stderr,"Usage: %s filename\n", argv[0] );
    	exit(1);
    }

    if( (sockfd = socket(PF_INET, SOCK_STREAM, 0)) == ERR) {/* ソケットの作成 */
        perror("server: socket");
        exit(1);
    }
    /* サーバプロセスのソケットアドレス情報の設定 */
    bzero((char *)&server, sizeof(server));	  /* アドレス情報構造体の初期化 */
    server.sin_family      = PF_INET;		  /* プロトコルファミリの設定 */
    server.sin_port        = htons(SERVER_PORT);  /* ソケットの名前（ポート番号）の設定 */
    server.sin_addr.s_addr = htonl(INADDR_ANY);	  /* IPアドレスの設定 */

    setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(int));

    if( bind(sockfd, (struct sockaddr *)&server, sizeof(server)) == ERR) {
    /* ソケットへの名前づけ */
        perror("server: bind");
        exit(1);
    }

    if( listen(sockfd, 5) == ERR) {		/* 接続要求の受け入れ準備 */
        perror("server: listen");
        exit(1);
    }

    for (i=1;;i++) {
      printf ("Waiting request from client (%d)\n",i);
      fromlen = sizeof(client);
      if( (ns = accept(sockfd, (struct sockaddr *)&client, &fromlen)) == ERR ){
	/* 接続要求の許可 */
	perror("server: accept");
	exit(1);
      }
      /* クライアントプロセスのソケットアドレス情報の確認 */
      printf("\nconnect request from: %s   port: %d\n",
	     inet_ntoa(client.sin_addr), ntohs(client.sin_port));
      
      if( read(ns, buf, BUFSIZE) == ERR ) { /* クライアントプロセスからのメッセージ受信 */
	perror("server: read");
	exit(1);
      }
      printf("\n<SERVER> message from client  :  %s\n",buf);

      write (ns,"HTTP/1.0 200\r\n", strlen("HTTP/1.0 200\r\n"));
      write (ns,"Content-type: text/html\r\n", strlen("Content-type: text/html\r\n"));
      write (ns,"\r\n", strlen("\r\n")); 
      file = fopen (argv[1], "r");
      if (file) {
	while ((readbyte = read (fileno(file), readbuf, BUFSIZE))>0) {
	  if (write (ns, readbuf, readbyte) == ERR) {
	    perror ("failed to write to socket");
	    exit(1);
	  }
	}
	fclose (file);
      }
      close(ns);	 /* accept()で返されたファイル記述子のクローズ */
    }
}
