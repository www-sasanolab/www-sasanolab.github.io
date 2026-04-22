Lambda-mode: Emacs mode for variable name completion

------Requirement------
Emacs (version 22 or higher is required since it is required by auto-complete mode.) 
and
auto-complete.el 0.3.0 alpha (available at http://www.cx4a.org/pub/auto-complete.el),
which is included in lambda-mode.tar.gz. (Do not use the other versions of auto-complete.)

------Get started------
(1) Download lambda-mode-0.21.tar.gz as follows.
    $ wget http://www.cs.ise.shibaura-it.ac.jp/lambda-mode/lambda-mode-0.21.tar.gz
(2) Unzip and untar the file as follows.
    $ tar zxvf lambda-mode-0.21.tar.gz
    (Directory "lambda-mode-0.21" is created)
(3) Change directory to lambda-mode-0.21 as follows.
    $ cd lambda-mode-0.21
(4) Launch the Emacs as follows.
    $ emacs
(5) Load the file "load.el", which automatically loads .el files.
    M-x load-file <RET> load.el <RET>
(6) Enable lambda-mode as follows.
    M-x lambda-mode
(7) Enable auto-complete-mode as follows.
    M-x auto-complete-mode

------User's manual------
The candidates for completion are automatically displayed while typing
identifiers without pressing keys such TAB key.

------Sample program------ 
We put the sample programs in the directory "sample".  The file
"constant_xx.lambda" includes a partial program  where all declarations have
different names in the left hand side and constant 1 in the right hand
side and the number of declarations is "xx". 
The file "various_xx.lambda" includes a partial program where all
declarations have different names in the left hand side and various
expressions in the right hand side and the number of declarations is "xx".

Variable name completion can be tried for the sample programs as follows.
1. Open the sample program file as follows.
    C-x C-f "sample/various_10.lambda" <RET>
2. Load and enable lambda-mode and auto-complete-mode as in the above.
3. Move the cursor to the right of the keyword "in" of the let expression.
4. Type space and type "x".

------Author-------
Takumi Goto 
Department of Information Science and Engineering,
Shibaura Institute of Technology

------Copyright-------
This program is free.
It is free to redistribute this software.

------Warning------
The author provides no guarantee of any kind. 

------Contact------
Takumi GotoÅFm110057 AT shibaura-it DOT ac DOT jp
or
Isao SasanoÅFsasano AT sic DOT shibaura-it DOT ac DOT jp
