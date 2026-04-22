----------------------------------------------------------------
-- Tests of programs
----------------------------------------------------------------

testpp = pp t3
testgo = go t3
testsc = sc t3
t1 = Leader 1 []
t2 = Leader 2 []
t3 = Leader 3 [t1,t2]

----------------------------------------------------------------
-- Party Planning Problem (pp)
-- input : a tree
-- output : an optimal marked tree
----------------------------------------------------------------

type PpClass = (Bool,Bool)

pp :: Org Elem -> Org MElem
pp = r2o . snd . opt accept_pp phi1_pp phi2_pp . o2r

accept_pp :: PpClass -> Bool
accept_pp (i,r) = i

phi1_pp :: MElem -> PpClass
phi1_pp mv = (True, marked mv)

phi2_pp :: PpClass -> PpClass -> PpClass
phi2_pp (a1,b1) (a2,b2) = 
          ((not (b1 && b2)) && a1 && a2, b2)

---------------------------------------------------
-- Group Organizing Problem on Rooted Trees (go)
-- input : a tree
-- output : an optimal marked tree
---------------------------------------------------
type GoClass = (Bool,Bool,Bool)

go :: Org Elem -> Org MElem
go = r2o . snd . opt accept_go phi1_go phi2_go . o2r

accept_go :: GoClass -> Bool
accept_go (g,_,_) = g

phi1_go :: MElem -> GoClass
phi1_go mv = (True, marked mv, not (marked mv))

phi2_go :: GoClass -> GoClass -> GoClass
phi2_go (g1,r1,n1) (g2,r2,n2) = 
       (if r2 then True
        else if n1 then g2
             else g1 && n2,
        r2,
        n1 && n2)

---------------------------------------------------
-- Supervisor Chaining Problem (sc)
-- input : a tree
-- output : an optimal marked tree
---------------------------------------------------

type ScClass = (Bool,Bool,Bool,Bool)

sc :: Org Elem -> Org MElem
sc = r2o . snd . opt accept_sc phi1_sc phi2_sc . o2r

accept_sc :: ScClass -> Bool
accept_sc (s,_,_,_) = s

phi1_sc :: MElem -> ScClass
phi1_sc mv = (True, marked mv, not (marked mv), marked mv)

phi2_sc :: ScClass -> ScClass -> ScClass
phi2_sc (s1,r1,n1,o1) (s2,r2,n2,o2) = 
       (if r2 then
          if n1 then s2
          else r1 && s1 && o2 
        else if n1 then s2
             else s1 && n2,
        r2,
        n1 && n2,
        n1 && o2)

------------------------------------------------
-- Implementation of optimization function 
-- on Rooted Trees
------------------------------------------------

opt accept phi1 phi2 t = 
    let opts = candidates phi1 phi2 t
    in  getmax [(w,t) | (c,w,t) <- opts,
                         accept c]

candidates phi1 phi2 (Root v) = 
    eachmax [(phi1 mv,
              if marked mv then weight mv else 0,
              Root mv)
            | mv <- [mark v, unmark v]]
candidates phi1 phi2 (Join t1 t2) = 
     let opts1 = candidates phi1 phi2 t1
         opts2 = candidates phi1 phi2 t2
     in  eachmax [(c1 `phi2` c2, w1+w2, Join t1 t2)
                     | (c1,w1,t1) <- opts1, (c2,w2,t2) <- opts2]

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
-- Rooted Trees and Organization Trees
-- and Conversion function 
-- between these two data types
------------------------------------------------
data Tree a = Root a
            | Join (Tree a) (Tree a)
      deriving (Eq,Show)

data Org a = Leader a [Org a]
      deriving (Eq,Show)

r2o :: Tree a -> Org a
r2o (Root v) = Leader v []
r2o (Join t1 t2) = let Leader v ts = r2o t2
                   in Leader v ((r2o t1) : ts)

o2r :: Org a -> Tree a
o2r (Leader v []) = Root v
o2r (Leader v (t:ts)) = 
    Join (o2r t) (o2r (Leader v ts))

------------------------------------------------
-- Type Definitions and Basic functions 
------------------------------------------------

type Weight = Integer
type Elem = Weight
type MElem = (Elem,Bool)

weight :: MElem -> Weight
weight (w,_) = w

mark :: Elem -> MElem
mark x = (x,True)

unmark :: Elem -> MElem
unmark x = (x,False)

marked :: MElem -> Bool
marked (_,m) = m
