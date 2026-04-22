Lambda-mode: Emacs mode for variable name completion

------Requirement------
 Emacs (version 22 or higher is required since it is required by auto-complete mode.) 
 and
 auto-complete.el 0.3.0 alpha (available at http://www.cx4a.org/pub/auto-complete.el)
 (Do not use the other versions of auto-complete.)

------Installation------
1. Installation without changing the initialization file such as .emacs.
(1) Download the eight .el files (seven lambda-*.el files and auto-complete.el) into some directory.
(2) Execute the Emacs.
(3) Set the load-path as follows.
    Type "M-x eval-expression" and press the return key on Emacs, then Emacs displays in the mini buffer as follows.
       Eval:
    Then enter the expression like (add-to-list 'load-path "/mypath/"), where the part "/mypath" should be
    replaced by the path of the directory you actually put the files.
    The minibuffer then becomes as follows.
       Eval: (add-to-list 'load-path "/mypath/")
    Then press the return key, then load-path is updated.
(4) Load the eight files as follows.
    Type "M-x load-file" and press the return key. Then the minibuffer displays as follows.
       Load file: 
    Then input the path to "lambda-mode.el" like the following way.
       Load file: /mypath/lambda-mode.el
    Then press the return key, then the file as well as the other seven files are loaded. 
    
(5) Enable lambda-mode as follows.
    Type the following:
      M-x lambda-mode

(6) Enable auto-complete-mode as follows.
    Type the following:
      M-x auto-complete-mode

2. Installation with changing the initialization file such as .emacs.
(1) Put the eight .el files (seven lambda-*.el files and auto-complete.el) into some directory that is included in the load-path.
(2) Write the followings in initialization file such as .emacs.

    (require 'auto-complete)
    (global-auto-complete-mode t)
    (require 'lambda-mode)
    (add-to-list 'ac-modes 'lambda-mode)	

(3) Enable the lambda-mode.
    M-x lambda-mode

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
