type Callback a = a -> IO()
type Action a = Callback a -> IO()

mkFetch :: a -> String -> Action a
mkFetch result _address callback = do r <- remote
                                      callback r
                                      return ()
    where remote = return result

fetch :: String -> Action [Int]
fetch = mkFetch [1, 3]

fetch' :: String -> Action String
fetch' = mkFetch "prefix"

converter :: (a -> b) -> Action a -> Action b
converter conversion action callback =  action (callback . conversion)

aggregator :: [Action a] -> Action [a]
aggregator actions callback = f actions callback []
 where f [] callback as = do callback as
                             return ()
       f (action:actions) callback as = action (\a -> f actions callback (a:as))

concatenator :: Action [[a]] -> Action [a]
concatenator = converter concat

sequencer :: Action a -> (a -> Action b) -> Action b
sequencer = undefined

application = fetchAll operate

operate :: String -> IO()
operate = print

fetchData = (converter show) . (converter sum) . concatenator . aggregator $ [fetch "first", fetch "second"]

fetchData' = fetch' "other"

fetchAll = (converter join) . aggregator $ [fetchData, fetchData']

join xs = xs!!0 ++ xs!!1
