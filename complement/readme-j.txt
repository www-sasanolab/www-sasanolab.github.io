型情報を考慮した変数名補完のためのEmacsモード 「Lambdaモード」

------動作環境------
Emacsのバージョンが22以上であること
  (auto-complete.elの動作環境がバージョン22以上であるため)。

------利用方法------
1. Emacsの設定を変更せずに試す方法
(1) lambda-で始まる7個のファイルと, auto-complete.elを同じディレクトリに置く。
(2) Emacsを起動する。
(3) load-pathの設定
    EmacsでM-x eval-expressionと入力しリターンキーを入力すると
      Eval:
     と表示されるのでそこに以下のpathの部分をファイルを置いた
     ディレクトリのパスに書き換えて入力しリターンキーを入力すると
     ロードパスが設定される。
      (add-to-list 'load-path "path")
      
(4) ファイルの読み込み
    M-x load-fileと入力しリターンキーを押すと
      Load file: ~/bin/
    のように表示されるのでそこにlambda-mode.elのパスを入力し
    リターンキーを入力するとlambda-mode.elや関連するファイルが読み込まれる。
(5) lambda-modeの実行
    M-x lambda-modeと入力してリターンキーを入力すると
    lambda-modeが起動する。

2. 一般的なインストール方法
lambda-で始まるファイルをlaod-pathの通ったディレクトリに置き、
.emacs等に以下のコードを書く。

(require 'lambda-mode)
(add-to-list 'ac-modes 'lambda-mode)	

またauto-complete.elも必要です。
auto-complete.elは以下で取得できます。
    http://www.emacswiki.org/emacs/AutoComplete

以上の通りlambda-modeとauto-completeを
インストール後にEmacsで
    M-x lambda-mode
と入力しリターンキーを押すと簡易言語用の変数名補完機能付きモードになります。

------作者-------
芝浦工業大学 工学部 情報工学科
プログラミング言語研究室 後藤 拓実

------著作権-------
本プログラムはフリーソフトです．
プログラムの配布・転載等は、自由に行っていただいて結構です．

------注意事項------
このプログラムの実行により問題や損害が発生しても作者は一切責任をとりません。

------バグ報告等の連絡先------
後藤　拓実：l06050 AT shibaura-it DOT ac DOT jp
あるいは
篠埜　功：sasano AT sic DOT shibaura-it DOT ac DOT jp


