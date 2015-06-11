{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# OPTIONS_GHC -fno-warn-type-defaults #-}
import Shelly
import Data.Text as T
import Control.Monad
import Data.Monoid
import qualified Text.Regex.Posix as R
import Filesystem.Path hiding ((</>))
default (T.Text)

(=~) :: T.Text -> T.Text -> [[T.Text]]
(=~) a b = Prelude.map (Prelude.map T.pack) (T.unpack a R.=~ T.unpack b)

base :: Text
base = "root"

copy' :: Text -> Text -> Sh ()
copy' opt fileT = do
  let file  = fromText fileT
  let file' = fromText $ base <> fileT
  fe <- test_e file
  de <- test_d file
  case (fe,de) of
    (True,False) -> do
      mkdir_p $ directory file'
      run "cp" [opt ,toTextIgnore file,toTextIgnore file']
      return ()
    (False,False) ->
      echo $ toTextIgnore file <> " does not exist."
    (_,True) -> mkdir_p file'

pkgCopy :: Text -> Sh ()
pkgCopy pkg = do
  files' <- silently $ run "dpkg" ["-L",pkg]
  let files = Prelude.filter ("/." /=) $ T.lines files'
  forM_ files $ copy' "-a"

binCopy :: Text -> Sh ()
binCopy binT = do
  output <- silently $ run "ldd" [binT]
  let bin = fromText binT
      bin' = fromText $ base <> binT
  copy' "-L" binT
  forM_ (T.lines output) $ \fileT ->
    case fileT =~ " (/.*) \\(" of
      [_,path']:_ -> copy' "-L" path'
      _ -> return ()
  
main :: IO ()
main = shelly $ silently $ do
  rm_rf (fromText base)
  pkgCopy "libc6"
  pkgCopy "libstdc++6"
  pkgCopy "libgcc1"
  pkgCopy "libglib2.0-0"
  pkgCopy "libffi6"
  pkgCopy "openjdk-7-jre-headless"
  pkgCopy "libzookeeper-java"
  pkgCopy "libslf4j-java"
  pkgCopy "liblog4j1.2-java"
  pkgCopy "zookeeper"
  pkgCopy "zookeeperd"
  binCopy "/usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java"
  binCopy "/bin/sh"
  binCopy "/usr/bin/dirname"
  binCopy "/bin/mkdir"
  binCopy "/bin/sed"
  binCopy "/bin/grep"
  binCopy "/usr/bin/env"
  binCopy "/bin/bash"
  binCopy "/bin/nc"
  binCopy "/bin/ls"
  binCopy "/bin/cat"
  binCopy "/bin/less"
  binCopy "/bin/sleep"
  binCopy "/bin/echo"
  binCopy "/bin/ps"
  binCopy "/bin/ln"
  binCopy "/usr/bin/nohup"
  run_ "ln" ["-s", "/usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java", base <> "/usr/bin"]
  run_ "ln" ["-s", "/etc/zookeeper/conf_example", base <> "/etc/zookeeper/conf"]
  escaping False $
    command "tar" ["cC", "root", ".", "|"] ["docker", "import", "-c", "'CMD /usr/share/zookeeper/bin/zkServer.sh start-foreground'", "-","zookeeper-box:latest"]
  return ()
