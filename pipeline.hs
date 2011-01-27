type Callback a = a -> IO()
type Action a = Callback a -> IO()

fetch :: String -> Action [Int]
fetch _ callback = do callback [1, 3]
                      return ()

fetch' :: String -> Action String
fetch' _ callback = do callback "prefix"
                       return ()

converter :: (a -> b) -> Action a -> Action b
converter conversion action callback =  action (callback . conversion)

sequencer :: [Action a] -> Action [a]
sequencer actions callback = f actions callback []
 where f [] callback as = do callback as
                             return ()
       f (action:actions) callback as = action (\a -> f actions callback (a:as))

concatenator :: Action [[a]] -> Action [a]
concatenator = converter concat

application = fetchAll operate

operate :: String -> IO()
operate = print

fetchData = (converter show) . (converter sum) . concatenator . sequencer $ [fetch "first", fetch "second"]

fetchData' = fetch' "other"

fetchAll = (converter join) . sequencer $ [fetchData, fetchData']

join xs = xs!!0 ++ xs!!1
