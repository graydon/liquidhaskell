{-@ LIQUID "--no-termination" @-}

module DropWhile where

import Language.Haskell.Liquid.Prelude
import Prelude hiding (head, dropWhile, (.), filter)


main :: IO ()
main =
  if head (dropWhile ((/=) 3) (1:::2:::3:::Emp)) == 3
    then return ()
    else error "Not going to happen"

{-@ head ::  List <p> a -> a<p> @-}
head (x ::: _) = x

-------------------------------------------------------------------------------
-- | A List 
-------------------------------------------------------------------------------

data List a = Emp | (:::) { hd :: a
                          , tl :: List a }
infixr 5 :::

-------------------------------------------------------------------------------
-- | A list whose head satisfies an abstract refinement `p`
-------------------------------------------------------------------------------

-- in the below, `hd :: a<p>` means the "head" is a value of type `a` that
-- additionally, satisfies `p hd`.

{-@ data List a <p :: a -> Prop> = Emp
                                 | (:::) { hd :: a<p>
                                         , tl :: List a }
  @-}

-- | e.g. a list whose head equals `3`

{-@ type OneList = List <{\v -> v == 3}> Int @-}

{-@ one :: OneList @-}
one :: List Int
one = 3 ::: 2 ::: 1 ::: Emp

-------------------------------------------------------------------------------
-- | dropWhile some predicate `f` is not satisfied
-------------------------------------------------------------------------------

{-@ dropWhile :: forall <p :: a -> Prop, w :: a -> Bool -> Prop>.
                   (Witness a p w) => 
                   (x:a -> Bool<w x>) -> List a -> List <p> a
  @-}
dropWhile :: (a -> Bool) -> List a -> List a
dropWhile f (x:::xs)
  | not (f x)    = x ::: xs
  | otherwise    = dropWhile f xs
dropWhile f Emp  = Emp

-- | This `witness` bound relates the predicate used in dropWhile

{-@ bound witness @-}
witness :: Eq a => (a -> Bool) -> (a -> Bool -> Bool) -> a -> Bool -> a -> Bool
witness p w = \ y b v -> (not b) ==> w y b ==> (v == y) ==> p v


-------------------------------------------------------------------------------
-- | Drop elements until you hit a `3`
-------------------------------------------------------------------------------

{-@ dropUntilOne' :: List Int -> OneList @-}
dropUntilOne' :: List Int -> List Int
dropUntilOne' = dropWhile (/= 3)

-- | Currently needed for the qual; should be made redundant by `--eliminate`

{-@ eqOne :: x:Int -> {v:Bool | Prop v <=> x /= 3} @-}
eqOne :: Int -> Bool
eqOne x = x /= 3
