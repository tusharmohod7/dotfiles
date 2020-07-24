------------------------------------------------------------------------
-- Tushar Mohod's Xmonad configuration file.
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Imports
------------------------------------------------------------------------

-- base
import Graphics.X11.ExtraTypes.XF86
import XMonad hiding ( (|||) )
import XMonad.Layout.LayoutCombinators (JumpToLayout(..), (|||))
import XMonad.Config.Desktop
import System.Exit
import qualified XMonad.StackSet as W

-- data
import Data.Char (isSpace)
import Data.List
import Data.Monoid
import Data.Maybe (isJust)
import Data.Ratio ((%))
import qualified Data.Map as M

-- system
import System.IO (hPutStrLn)

-- util
import XMonad.Util.Run (runProcessWithInput, safeSpawn, unsafeSpawn, runInTerm, spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Util.EZConfig (additionalKeysP, additionalMouseBindings)  
import XMonad.Util.NamedScratchpad
import XMonad.Util.NamedWindows
import XMonad.Util.WorkspaceCompare
import XMonad.Layout.PerWorkspace

-- hooks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks (avoidStruts, docksStartupHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.EwmhDesktops -- to show workspaces in application switchers
import XMonad.Hooks.ManageHelpers (isFullscreen, isDialog,  doFullFloat, doCenterFloat, doRectFloat) 
import XMonad.Hooks.Place (placeHook, withGaps, smart)
import XMonad.Hooks.UrgencyHook

-- actions
import XMonad.Actions.CopyWindow (kill1, killAllOtherCopies)
import XMonad.Actions.UpdatePointer
import XMonad.Actions.MouseResize

-- layout 
import XMonad.Layout.Renamed (renamed, Rename(Replace))
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing
import XMonad.Layout.Gaps
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.ResizableTile
import XMonad.Layout.BinarySpacePartition
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.ShowWName
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

-- Prompt
-- import XMonad.Prompt
-- import XMonad.Prompt.Input
-- import XMonad.Prompt.FuzzyMatch
-- import XMonad.Prompt.Man
-- import XMonad.Prompt.Pass
-- import XMonad.Prompt.Shell (shellPrompt)
-- import XMonad.Prompt.Ssh
-- import XMonad.Prompt.XMonad
-- import Control.Arrow (first)

-- The preferred fonts
myFont :: String
myFont = "xft:Mononoki Nerd Font:bold:size=10"

-- The preferred terminal
myTerminal :: String
myTerminal = "alacritty"

-- The preferred editor
myEditor :: String
myEditor = "mousepad"
-- myEditor = "emacsclient -ca emacs " -- followed by filename

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
myBorderWidth :: Dimension
myBorderWidth = 1

-- modMask lets you specify which modkey you want to use. 
myModMask :: KeyMask
myModMask = mod4Mask

-- Border colors for unfocused windows
myNormalBorderColor :: String
myNormalBorderColor  = "#dddddd"

-- Norder colors for focused windows
myFocusedBorderColor :: String
myFocusedBorderColor = "#ff0000"

-- PP config defaults
myppCurrent :: String 
myppCurrent = "#767676"

myppVisible :: String
myppVisible = "#00FF00"

myppHidden :: String
myppHidden = "#02FF5F"

myppHiddenNoWindows :: String
myppHiddenNoWindows = "#FFA1A1"

myppTitle :: String
myppTitle = "#ADA6E3"

myppUrgent :: String
myppUrgent = "#DCAAFA"

windowCount :: X (Maybe String) -- count number of windows on the current workspace
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
------------------------------------------------------------------------

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    [ ((modm, xK_Return), spawn $ XMonad.terminal conf) -- default terminal emulator
    -- , ((0, xF86XK_AudioMute),       spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
    -- , ((0, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ -5%")
    -- , ((0, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ +5%")
    , ((0, xF86XK_AudioMute          ), spawn "pulsemixer --toggle-mute") -- volume mute toggle
    , ((0, xF86XK_AudioLowerVolume   ), spawn "pulsemixer --change-volume -5 --max-volume 100") -- volume down
    , ((0, xF86XK_AudioRaiseVolume   ), spawn "pulsemixer --change-volume +5 --max-volume 100") -- volume up
    , ((0, xF86XK_MonBrightnessUp    ), spawn "xbacklight -inc 5%") -- brightness up
    , ((0, xF86XK_MonBrightnessDown  ), spawn "xbacklight -dec 5%") -- brightness down
    , ((modm .|. shiftMask, xK_b     ), spawn "firefox") -- launch firefox browser
    , ((modm .|. shiftMask, xK_p     ), spawn "pcmanfm") -- launch pcmanfm file manager
    , ((modm .|. shiftMask, xK_m     ), spawn myEditor) -- launch editor
    , ((modm .|. shiftMask, xK_o     ), spawn ( myTerminal ++ " -e ranger" )) -- launch ranger file manager
    , ((modm,               xK_p     ), spawn "dmenu_run") -- launch dmenu
    , ((modm .|. shiftMask, xK_d     ), spawn "killall dunst") -- kill all dunst notfication instances
    , ((modm .|. shiftMask, xK_q     ), kill) -- close focused window
    , ((modm,               xK_space ), sendMessage NextLayout) -- Rotate through the available layout algorithms
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf) --  Reset the layouts on the current workspace to default
    , ((modm,               xK_n     ), refresh) -- Resize viewed windows to the correct size
    , ((modm,               xK_Tab   ), windows W.focusDown) -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown) -- Move focus to the next window
    , ((modm,               xK_k     ), windows W.focusUp  ) -- Move focus to the previous window
    , ((modm,               xK_m     ), windows W.focusMaster  ) -- Move focus to the master window
    , ((modm .|. shiftMask, xK_Return), windows W.swapMaster) -- Swap the focused window and the master window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  ) -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    ) -- Swap the focused window with the previous window
    , ((modm,               xK_h     ), sendMessage Shrink) -- Shrink the master area
    , ((modm,               xK_l     ), sendMessage Expand) -- Expand the master area
    , ((modm,               xK_t     ), withFocused $ windows . W.sink) -- Push window back into tiling
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1)) -- Increment the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1))) -- Deincrement the number of windows in the master area
    , ((modm              , xK_b     ), sendMessage ToggleStruts) -- Toggle the status bar gap
    , ((modm .|. shiftMask, xK_c     ), io (exitWith ExitSuccess)) -- Quit xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart") -- Restart xmonad
    ]
    ++

    -- Move to workspace using Mod + Workspace Number
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    -- Moving an application to another workspace using Mod + Shift + Workspace Number 
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
------------------------------------------------------------------------
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- WORKSPACES
------------------------------------------------------------------------
-- Use UnsafeStdinReader instead of StdinReader for clickable workspaces in xmobarrc file

xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]

myWorkspaces :: [String]
myWorkspaces = clickable . map xmobarEscape
               $ ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
  where
        clickable l = [ "<action=xdotool key super+" ++ show n ++ ">" ++ ws ++ "</action>" |
                      (i,ws) <- zip [1..9] l,
                      let n = i ]

------------------------------------------------------------------------
-- Layouts:
------------------------------------------------------------------------

mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

tall     = renamed [Replace "tall"]
           $ limitWindows 12
           $ mySpacing 3
           $ ResizableTall 1 (3/100) (1/2) []
magnify  = renamed [Replace "magnify"]
           $ magnifier
           $ limitWindows 12
           $ mySpacing 3
           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ limitWindows 20 Full
full     = renamed [Replace "Full"] 
           $ noBorders (Full)
floats   = renamed [Replace "floats"]
           $ limitWindows 20 simplestFloat
-- grid     = renamed [Replace "grid"]
--            $ limitWindows 12
--            $ mySpacing 8
--            $ mkToggle (single MIRROR)
--            $ Grid (16/10)
-- spirals  = renamed [Replace "spirals"]
--            $ mySpacing' 8
--            $ spiral (6/7)
-- threeCol = renamed [Replace "threeCol"]
--            $ limitWindows 7
--            $ mySpacing' 4
--            $ ThreeCol 1 (3/100) (1/2)
-- threeRow = renamed [Replace "threeRow"]
--            $ limitWindows 7
--            $ mySpacing' 4
           -- Mirror takes a layout and rotates it by 90 degrees.
           -- So we are applying Mirror to the ThreeCol layout.
           -- $ Mirror
           -- $ ThreeCol 1 (3/100) (1/2)
-- tabs     = renamed [Replace "tabs"]
           -- I cannot add spacing to this layout because it will
           -- add spacing between window and tabs which looks bad.
           -- $ tabbed shrinkText myTabConfig
  -- where
  --   myTabConfig = def { fontName            = "xft:Mononoki Nerd Font:regular:pixelsize=11:style=bold"
  --                     , activeColor         = "#292d3e"
  --                     , inactiveColor       = "#3e445e"
  --                     , activeBorderColor   = "#292d3e"
  --                     , inactiveBorderColor = "#292d3e"
  --                     , activeTextColor     = "#ffffff"
  --                     , inactiveTextColor   = "#d0d0d0"
  --                     }

-- The layout hook
myLayoutHook = avoidStruts $ mouseResize $ windowArrange $
               mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where
               -- I've commented out the layouts I don't use.
               myDefaultLayout = tall
                                 ||| full
                                 ||| magnify
                                 ||| noBorders monocle
                                 ||| floats
                                 -- ||| grid
                                 -- ||| noBorders tabs
                                 -- ||| spirals
                                 -- ||| threeCol
                                 -- ||| threeRow

------------------------------------------------------------------------
-- Window rules:
------------------------------------------------------------------------
myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
    [ title =? "Oracle VM VirtualBox Manager"  --> doFloat
    , className =? "mpv"            --> doShift ( myWorkspaces !! 4 ) -- 0 means 1, 1 means 2 and so on .. mpv launch in ws 5
    , className =? "mpv"            --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

------------------------------------------------------------------------
-- Startup hook or AutoStart script
------------------------------------------------------------------------
myStartupHook :: X ()
myStartupHook = do
    spawnOnce "nitrogen --restore &"
    spawnOnce "picom &"
    spawnOnce "nm-applet &"
    spawnOnce "volumeicon &"

------------------------------------------------------------------------
-- Main
------------------------------------------------------------------------
main :: IO ()
main = do
    xmproc0 <- spawnPipe "/usr/bin/xmobar -x 0 /home/tushar/.config/xmobar/xmobarrc"
    xmonad $ ewmh desktopConfig
        { manageHook = ( isFullscreen --> doFullFloat ) <+> myManageHook <+> manageDocks 
        , startupHook        = myStartupHook
        , layoutHook         = myLayoutHook
        , handleEventHook    = handleEventHook desktopConfig
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , terminal           = myTerminal
        , keys               = myKeys
        , mouseBindings      = myMouseBindings
        , modMask            = myModMask
        , normalBorderColor  = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        , focusFollowsMouse  = myFocusFollowsMouse
        , clickJustFocuses   = myClickJustFocuses
        , logHook = dynamicLogWithPP xmobarPP  
                        { ppOutput = \x -> hPutStrLn xmproc0 x
                        , ppCurrent = xmobarColor myppCurrent "" . wrap "[" "]"
                        , ppVisible = xmobarColor myppVisible ""
                        , ppHidden = xmobarColor myppHidden "" . wrap "*" ""
                        , ppHiddenNoWindows = xmobarColor myppHiddenNoWindows ""
                        , ppTitle = xmobarColor  myppTitle "" . shorten 60
                        , ppSep =  "<fc=#dd11aa> | </fc>"
                        , ppUrgent = xmobarColor  myppUrgent "" . wrap "!" "!"
                        , ppExtras = [windowCount]
                        , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                        } >> updatePointer (0.25, 0.25) (0.25, 0.25)
          }

------------------------------------------------------------------------
-- End of XMonad configuration file
------------------------------------------------------------------------