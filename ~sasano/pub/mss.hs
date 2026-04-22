----------------------------------------------------------------
-- A test of programs
----------------------------------------------------------------

testmss = mss [5,-3,4]
testmenss = menss [5,-3,4]
testmelss = melss [5,-3,4]

---------------------------------------------------
-- Maximum Segment Sum Problem (mss)
-- input : a list
-- output : an optimal marked list
---------------------------------------------------
type MssClass = (Bool,Bool,Bool)

mss :: [Elem] -> (Weight,[MElem])
mss = opt accept_mss phi1_mss phi2_mss

accept_mss :: MssClass -> Bool
accept_mss (c,n,m) = c

phi1_mss :: MElem -> MssClass
phi1_mss mx = (True, not (marked mx), marked mx)

phi2_mss :: MElem -> MssClass -> MssClass
phi2_mss mx (c,n,m) = 
    (if marked mx then (n || (m && c)) else c,
     not (marked mx) && n,
     marked mx)

---------------------------------------------------
-- Maximum Even Number Segment Sum Problem (menss)
-- input : a list
-- output : an optimal marked list
---------------------------------------------------

type MenssClass = (Bool,Bool,Bool,Bool)

menss :: [Elem] -> (Weight,[MElem])
menss = opt accept_menss phi1_menss phi2_menss

accept_menss :: MenssClass -> Bool
accept_menss (c,n,m,e) = c && e

phi1_menss :: MElem -> MenssClass
phi1_menss mx = (True, not (marked mx), marked mx,
               if marked mx then even (weight mx) else True)

phi2_menss :: MElem -> MenssClass -> MenssClass
phi2_menss mx (c,n,m,e) = 
    (if marked mx then (n || (m && c)) else c,
     not (marked mx) && n,
     marked mx,
     if marked mx then (even (weight mx) && e) else e)

---------------------------------------------------
-- Maximum Even Length Segment Sum Problem (melss)
-- input : a list
-- output : an optimal marked list
---------------------------------------------------

type MelssClass = (Bool,Bool,Bool,Bool)

melss :: [Elem] -> (Weight,[MElem])
melss = opt accept_melss phi1_melss phi2_melss

accept_melss :: MelssClass -> Bool
accept_melss (c,n,m,e) = c && e

phi1_melss :: MElem -> MelssClass
phi1_melss mx = (True, not (marked mx), marked mx,
               if marked mx then False else True)

phi2_melss :: MElem -> MelssClass -> MelssClass
phi2_melss mx (c,n,m,e) = 
    (if marked mx then (n || (m && c)) else c,
     not (marked mx) && n,
     marked mx,
     if marked mx then (not e) else e)

------------------------------------------------
-- Implementation of optimization function 
-- on Lists
------------------------------------------------

opt accept phi1 phi2 xs = 
    let opts = candidates phi1 phi2 xs
    in  getmax [(w,t) | (c,w,t) <- opts,
                         accept c]

candidates phi1 phi2 [x] = 
    eachmax [(phi1 mx,
              if marked mx then weight mx else 0,
              [mx])
            | mx <- [mark x, unmark x]]
candidates phi1 phi2 (x:xs) = 
     let opts = candidates phi1 phi2 xs
     in  eachmax [(phi2 mx c, 
                   (if marked mx then weight mx else 0) + w,
                   mx:cand)
                 | mx <- [mark x, unmark x],
                   (c,w,cand) <- opts]

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
