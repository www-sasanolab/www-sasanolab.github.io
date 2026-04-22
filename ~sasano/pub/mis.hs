----------------------------------------------------------------
-- A test of programs
----------------------------------------------------------------

test = mis [1..10]

---------------------------------------------------
-- Maximum Independent-Sublist Sum Problem (mis)
-- input : a list
-- output : an optimal marked list
---------------------------------------------------

mis :: [Elem] -> (Weight,[MElem])
mis xs = let opts = mis' xs
             in getmax [(w,cand)| (c,w,cand) <- opts, c==2 || c==3]

mis' :: [Elem] -> [(Class,Weight,[MElem])]
mis' [x] = [(2,x,[(x,True)]), (3,0,[(x,False)])]
mis' (x:xs) = let opts = mis' xs
              in  eachmax [(table (marked mx) c, 
                            (if marked mx then weight mx else 0) + w,
                            mx:cand)
                          | mx <- [mark x, unmark x], (c,w,cand) <- opts]

table :: Bool -> Class -> Class
table True 0 = 0
table True 1 = 0
table True 2 = 0
table True 3 = 2
table False 0 = 1
table False 1 = 1
table False 2 = 3
table False 3 = 3

getmax :: Ord w => [(w,a)] -> (w,a)
getmax [] = error "No solution."
getmax xs = foldr1 f xs
  where f (w1,cand1) (w2,cand2) = if w1>w2 then (w1,cand1)
                                  else (w2,cand2)

eachmax :: (Ord w, Eq c) => [(c,w,a)] -> [(c,w,a)]
eachmax xs = foldr f [] xs
  where f (c,w,cand) [] = [(c,w,cand)]
        f (c,w,cand) ((c',w',cand') : opts) =
            if c==c' then
               if w>w' then (c,w,cand) : opts
               else (c',w',cand') : opts
            else (c',w',cand') : f (c,w,cand) opts

------------------------------------------------
-- Type Definitions and Basic functions 
------------------------------------------------

type Weight = Int
type Elem = Weight
type MElem = (Elem,Bool)
type Class = Int

weight :: MElem -> Weight
weight (w,_) = w

marked :: MElem -> Bool
marked (_,m) = m

mark :: Elem -> MElem
mark x = (x,True)

unmark :: Elem -> MElem
unmark x = (x,False)
