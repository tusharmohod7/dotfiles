------------------------------------------------------------------------
-- Xmonad configuration file.
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Imports
------------------------------------------------------------------------

import Graphics.X11.ExtraTypes.XF86 -- XF86 Keys or function keys
import XMonad hiding ( (|||) ) -- jump to layout
import XMonad.Layout.LayoutCombinators (JumpToLayout(..), (|||)) -- jump to layout
import XMonad.Config.Desktop
import System.Exit
import qualified XMonad.StackSet as W

-- data
import Data.Char (isSpace)
import Data.List
import Data.Monoid
import Data.Maybe (isJust)
import Data.Ratio ((%)) -- for video
import qualified Data.Map as M

-- system
import System.IO (hPutStrLn) -- for xmobar

-- util
import XMonad.Util.Run (safeSpawn, unsafeSpawn, runInTerm, spawnPipe)
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
import XMonad.Actions.CopyWindow -- for dwm window style tagging
import XMonad.Actions.UpdatePointer -- update mouse postion

-- layout 
import XMonad.Layout.Renamed (renamed, Rename(Replace))
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing
import XMonad.Layout.Gaps
import XMonad.Layout.GridVariants
import XMonad.Layout.ResizableTile
import XMonad.Layout.BinarySpacePartition

-- The preferred terminal
myTerminal :: String
myTerminal = "alacritty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
myBorderWidth :: Dimension
myBorderWidth = 2

-- modMask lets you specify which modkey you want to use. 
myModMask :: KeyMask
myModMask = mod4Mask

-- The workspaces
myWorkspaces :: [String]
myWorkspaces = ["1","2","3","4","5","6","7","8","9"]

-- Border colors for unfocused windows
myNormalBorderColor :: String
myNormalBorderColor  = "#dddddd"

-- Norder colors for focused windows
myFocusedBorderColor :: String
myFocusedBorderColor = "#ff0000"

-- PP config defaults
-- pointing the focused workspace
myppCurrent :: String 
myppCurrent = "#ff0000"
-- I have no idea what is this
myppVisible :: String
myppVisible = "#00ff00"
-- workspaces that have some application open but not focused
myppHidden :: String
myppHidden = "#02ff5f"
-- workspaces that have no application and not focused
myppHiddenNoWindows :: String
myppHiddenNoWindows = "#ffA1A1"
-- title of the application focused
myppTitle :: String
myppTitle = "#ADA6E3"
-- urgent indicator. This is used in case an application is assigned or already opened in a workspace.
myppUrgent :: String
myppUrgent = "#DCAaFA"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
------------------------------------------------------------------------

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm, xK_Return), spawn $ XMonad.terminal conf)

    -- volume keys
    -- , ((0, xF86XK_AudioMute),       spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
    -- , ((0, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ -5%")
    -- , ((0, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ +5%")
    , ((0, xF86XK_AudioMute),       spawn "pulsemixer --toggle-mute")
    , ((0, xF86XK_AudioLowerVolume), spawn "pulsemixer --change-volume -5 --max-volume 100")
    , ((0, xF86XK_AudioRaiseVolume), spawn "pulsemixer --change-volume +5 --max-volume 100")

    -- brightness keys
    , ((0, xF86XK_MonBrightnessUp), spawn "xbacklight -inc 5%")
    , ((0, xF86XK_MonBrightnessDown), spawn "xbacklight -dec 5%")

    -- launch firefox browser
    , ((modm .|. shiftMask, xK_b     ), spawn "firefox")

    -- launch pcmanfm file manager
    , ((modm .|. shiftMask, xK_p     ), spawn "pcmanfm") 

    -- launch mousepad editor
    , ((modm .|. shiftMask, xK_m     ), spawn "mousepad")

    -- launch ranger file manager
    , ((modm .|. shiftMask, xK_o     ), spawn ( myTerminal ++ " -e ranger" )) 

    -- launch dmenu
    , ((modm,               xK_p     ), spawn "dmenu_run")

    -- kill all dunst notfication instances
    , ((modm .|. shiftMask, xK_d     ), spawn "killall dunst")

    -- close focused window
    , ((modm .|. shiftMask, xK_q     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm .|. shiftMask, xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_c     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    --
    -- Move to workspace using Mod + Workspace Number
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- Moving an application to another workspace using Mod + Shift + Workspace Number 
    --
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
-- Layouts:
------------------------------------------------------------------------
myLayout = avoidStruts (full ||| tiled ||| grid ||| bsp)
  where
     -- full
     full = renamed [Replace "Full"] 
          $ noBorders (Full)

     -- tiled
     tiled = renamed [Replace "Tall"] 
           $ spacingRaw True (Border 3 3 3 3) True (Border 3 3 3 3) True 
           $ ResizableTall 1 (3/100) (1/2) []

     -- grid
     grid = renamed [Replace "Grid"] 
          $ spacingRaw True (Border 3 3 3 3) True (Border 3 3 3 3) True 
          $ Grid (16/10)

     -- bsp
     bsp = renamed [Replace "BSP"] 
         $ emptyBSP

     -- The default number of windows in the master pane
     nmaster = 1
     
     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

------------------------------------------------------------------------
-- Window rules:
------------------------------------------------------------------------
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

------------------------------------------------------------------------
-- Event handling
------------------------------------------------------------------------
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging
------------------------------------------------------------------------
myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook
------------------------------------------------------------------------
myStartupHook :: X ()
myStartupHook = do
    spawnOnce "nitrogen --restore &"
    spawnOnce "picom &"
    spawnOnce "nm-applet &"

------------------------------------------------------------------------
-- This part is from EF Tech Made Simple YouTube Channel
-- Kept for any further updates from him.
------------------------------------------------------------------------
-- Command to launch the bar
 -- myBar = "xmobar"
myBar = "/usr/bin/xmobar -x 0 /home/tushar/.config/xmobar/xmobarrc"

-- Custom PP, configure it as you like. It determines what is being written to the bar.
myPP = xmobarPP { ppCurrent = xmobarColor "#f02a00" "" . wrap "[" "]" }

--Key binding to toggle the gap between the bar.
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.
-- main = xmonad defaults
main = xmonad =<< statusBar myBar myPP toggleStrutsKey defaults

-- A structure containing your configuration settings.
defaults = def {
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,
        keys               = myKeys,
        mouseBindings      = myMouseBindings,
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }

-- main = do
--     xmproc0 <- spawnPipe "/usr/bin/xmobar -x 0 /home/tushar/.config/xmobar/xmobarrc"
    -- xmonad defaults

-- main = do
--     xmproc0 <- spawnPipe "/usr/bin/xmobar -x 0 /home/tushar/.config/xmobar/xmobarrc"
--     xmonad $ ewmh defaults
--         { manageHook = ( isFullscreen --> doFullFloat ) <+> manageDocks <+> manageHook desktopConfig
--         -- , startupHook        = myStartupHook
--         -- , layoutHook         = myLayout
--         , handleEventHook    = handleEventHook desktopConfig
--         -- , workspaces         = myWorkspaces
--         -- , borderWidth        = myBorderWidth
--         -- , terminal           = myTerminal
--         -- , keys               = myKeys
--         -- , mouseBindings      = myMouseBindings
--         -- , modMask            = myModMask
--         -- , normalBorderColor  = myNormalBorderColor
--         -- , focusedBorderColor = myFocusedBorderColor
--         -- , focusFollowsMouse  = myFocusFollowsMouse
--         -- , clickJustFocuses   = myClickJustFocuses
--         -- manageHook         = myManageHook,
--         -- handleEventHook    = myEventHook,
--         -- , logHook            = myLogHook
--         , logHook = dynamicLogWithPP xmobarPP  
--                         { ppOutput = \x -> hPutStrLn xmproc0 x
--                         , ppCurrent = xmobarColor myppCurrent "" . wrap "[" "]" -- Current workspace in xmobar
--                         , ppVisible = xmobarColor myppVisible ""                -- Visible but not current workspace
--                         , ppHidden = xmobarColor myppHidden "" . wrap "*" ""   -- Hidden workspaces in xmobar
--                         , ppHiddenNoWindows = xmobarColor  myppHiddenNoWindows ""        -- Hidden workspaces (no windows)
--                         , ppTitle = xmobarColor  myppTitle "" . shorten 100     -- Title of active window in xmobar
--                         , ppSep =  "<fc=#dd11aa> : </fc>"                     -- Separators in xmobar
--                         , ppUrgent = xmobarColor  myppUrgent "" . wrap "!" "!"  -- Urgent workspace
--                         -- , ppExtras  = [windowCount]                           -- # of windows current workspace
--                         , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
--                         } >> updatePointer (0.25, 0.25) (0.25, 0.25)
--           }

-- Removed the help part to minimize the config file.
-- No need to go further.
help :: String
help = unlines [""]
