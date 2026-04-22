----------------------------------------------------------------
-- Tests of programs
----------------------------------------------------------------

test = tdp graph
graph = (g0 `Series` (((g1 `Series` g2) `Parallel` g3) `Series` g4)) `Parallel` g5
test2 = tdp graph2 -- This has no solution.
graph2 = (g0 `Series` (((g1 `Series` g2) `Parallel` g3) `Series` g4))
g0 = Base s "u" ("e0",1)
g1 = Base "u" "w" ("e1",3)
g2 = Base "w" "v" ("e2",5)
g3 = Base "u" "v" ("e3",4)
g4 = Base "v" t ("e4",1)
g5 = Base s t ("e5",1)
s = "Source"
t = "Target"

------------------------------------------------
-- Definition of Series Parallel Graphs
------------------------------------------------

data SPG v e = Base v v e
             | Series (SPG v e) (SPG v e)
             | Parallel (SPG v e) (SPG v e)
      deriving (Eq, Show)

----------------------------------------------------------------
-- Maximum Two Disjoint Paths Problem (tdp)
-- input : a series-parallel graph
-- output : an optimal marked series-parallel graph
----------------------------------------------------------------
type Class = (Bool,Bool,Bool,Bool,Bool)

tdp :: SPG Vertex Edge -> (Weight, SPG Vertex MEdge)
tdp = opt accept phi1 phi2 phi3 

accept :: Class -> Bool
accept (c,s,n,ts,tt) = c && ts && tt

phi1 :: Vertex -> Vertex -> MEdge -> Class
phi1 v1 v2 e = 
        (not (marked e),
         marked e,
         not (marked e),
         if s==v1 || s==v2
           then marked e
           else False,
         if t==v1 || t==v2
           then marked e
           else False)

phi2 :: Class -> Class -> Class
phi2 (c1,s1,n1,ts1,tt1) (c2,s2,n2,ts2,tt2) =
        ((c1 && n2) || (n1 && c2),
         s1 && s2,
         n1 && n2,
         ts1 || ts2,
         tt1 || tt2)

phi3 :: Class -> Class -> Class
phi3 (c1,s1,n1,ts1,tt1) (c2,s2,n2,ts2,tt2) =
        ((c1 && n2) || (n1 && c2) || (s1 && s2),
         (s1 && n2) || (n1 && s2),
         n1 && n2,
         ts1 || ts2,
         tt1 || tt2)

------------------------------------------------
-- Implementation of optimization function 
-- on Series Parallel Graphs
------------------------------------------------

opt accept phi1 phi2 phi3 x = 
    let opts = candidates phi1 phi2 phi3 x
    in  getmax [(w,mx) | (c,w,mx) <- opts,
                         accept c]

candidates phi1 phi2 phi3 (Base v1 v2 e) = 
    eachmax [(phi1 v1 v2 me,
              if marked me then weight me else 0,
              Base v1 v2 me)
            | me <- [mark e, unmark e]]

candidates phi1 phi2 phi3 (Series g1 g2) =
    let cand1 = candidates phi1 phi2 phi3 g1
        cand2 = candidates phi1 phi2 phi3 g2
    in  eachmax [(c1 `phi2` c2,
                  w1+w2,
                  Series mr1 mr2)
                | (c1,w1,mr1) <- cand1, (c2,w2,mr2) <- cand2]

candidates phi1 phi2 phi3 (Parallel g1 g2) =
    let cand1 = candidates phi1 phi2 phi3 g1
        cand2 = candidates phi1 phi2 phi3 g2
    in  eachmax [(c1 `phi3` c2,
                  w1+w2,
                  Parallel mr1 mr2)
                | (c1,w1,mr1) <- cand1, (c2,w2,mr2) <- cand2]

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

type Weight = Integer
type Vertex = Id
type Id = [Char]
type Edge = (Id,Weight)
type MVertex = (Vertex,Bool)
type MEdge = (Edge,Bool)

weight :: MEdge -> Weight
weight ((_,w),_) = w

mark :: Edge -> MEdge
mark e = (e,True)

unmark :: Edge -> MEdge
unmark e = (e,False)

marked :: MEdge -> Bool
marked (_,m) = m

