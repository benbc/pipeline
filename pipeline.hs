data Callback a = Callback { success :: a -> IO(), failure :: IO() }
callback :: (a -> IO()) -> IO() -> Callback a
callback success failure = Callback { success = success, failure = failure }

type Action a = Callback a -> IO()

fetch :: String -> Action [Int]
fetch _ callback = do (success callback) [1, 3]
                      return ()

fetch' :: String -> Action String
fetch' _ callback = do (success callback) "prefix"
                       return ()

converter :: (a -> b) -> Action a -> Action b
converter conversion action c =  action (callback s f)
    where s = (success c) . conversion
          f = failure c

sequencer :: [Action a] -> Action [a]
sequencer actions = undefined

concatenator :: Action [[a]] -> Action [a]
concatenator = converter concat

application = fetchAll (callback print (print "argh!"))

operate :: String -> IO()
operate = undefined

fetchData = (converter show) . (converter sum) . concatenator . sequencer $ [fetch "first", fetch "second"]

fetchData' = fetch' "other"

fetchAll = (converter join) . sequencer $ [fetchData, fetchData']

join xs = xs!!0 ++ xs!!1
