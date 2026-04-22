(*
A Standard ML program defining an abstract data type
How to execute
Invoke an interpreter of Standard ML like SML/NJ as follows
% sml a.sml
Then type an expression like "showx c" and "showy c"
as follows.
- showx c;
You need to install an interpreter by yourself.
*)

abstype complex = C of int * int with
  fun complex (x,y: int) = C (x,y)
  fun x_coord (C(x,y)) = x
  fun y_coord (C(x,y)) = y
  fun add (C(x1,y1), C(x2,y2)) = C(x1+x2, y1+y2)
end
  
val a = complex(1,2)
val b = complex(3,4)
val c = add(a,b)

fun showx c = print (Int.toString (x_coord c) ^ "\n")
fun showy c = print (Int.toString (y_coord c) ^ "\n")
