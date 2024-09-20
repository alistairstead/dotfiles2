--
-- ██╗    ██╗███████╗███████╗████████╗███████╗██████╗ ███╗   ███╗
-- ██║    ██║██╔════╝╚══███╔╝╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
-- ██║ █╗ ██║█████╗    ███╔╝    ██║   █████╗  ██████╔╝██╔████╔██║
-- ██║███╗██║██╔══╝   ███╔╝     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║
-- ╚███╔███╔╝███████╗███████╗   ██║   ███████╗██║  ██║██║ ╚═╝ ██║
--  ╚══╝╚══╝ ╚══════╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
-- A GPU-accelerated cross-platform terminal emulator

local wezterm = require("wezterm")
local act = wezterm.action

local multiple_actions = function(keys)
  local actions = {}
  for key in keys:gmatch(".") do
    table.insert(actions, act.SendKey({ key = key }))
  end
  table.insert(actions, act.SendKey({ key = "\n" }))
  return act.Multiple(actions)
end

local key_table = function(mods, key, action)
  return {
    mods = mods,
    key = key,
    action = action,
  }
end

local cmd_key = function(key, action)
  return key_table("CMD", key, action)
end

local cmd_to_tmux_prefix = function(key, tmux_key)
  return cmd_key(
    key,
    act.Multiple({
      act.SendKey({ mods = "CTRL", key = "b" }),
      act.SendKey({ key = tmux_key }),
    })
  )
end

return {

  -- Set default shell to Fish
  -- default_prog = {
  --   "${pkgs.tmux}/bin/tmux",
  -- },
  macos_window_background_blur = 15,
  color_scheme = "Catppuccin Mocha",
  font_size = 18,
  line_height = 1.3,
  cell_width = 1.04,
  warn_about_missing_glyphs = true,
  freetype_load_target = "Light",
  use_cap_height_to_scale_fallback_fonts = true,

  -- "Monaspace Argon",
  -- "Monaspace Krypton",
  -- "Monaspace Neon",
  -- "Monaspace Radon",
  -- "Monaspace Xenon",

  font = wezterm.font_with_fallback({
    {
      family = "Monaspace Neon",
      weight = "ExtraLight",
      harfbuzz_features = { "calt", "ss01", "ss02", "ss03", "ss04", "ss05", "ss06", "ss07", "ss08", "liga" },
    },
    { family = "Symbols Nerd Font Mono", scale = 0.75 },
  }),

  font_rules = {
    {
      intensity = "Bold",
      italic = true,
      font = wezterm.font({
        family = "Monaspace Radon",
        weight = "Regular",
        style = "Italic",
      }),
    },
    {
      italic = true,
      intensity = "Half",
      font = wezterm.font({
        family = "Monaspace Radon",
        weight = "ExtraLight",
        style = "Italic",
      }),
    },
    {
      italic = true,
      intensity = "Normal",
      font = wezterm.font({
        family = "Monaspace Radon",
        weight = "ExtraLight",
        style = "Italic",
      }),
    },
  },

  window_padding = {
    left = 20,
    right = 20,
    top = 65,
    bottom = 5,
  },

  -- general options
  adjust_window_size_when_changing_font_size = false,
  debug_key_events = false,
  enable_tab_bar = false,
  native_macos_fullscreen_mode = true,
  window_close_confirmation = "NeverPrompt",
  window_decorations = "INTEGRATED_BUTTONS|RESIZE",
  -- fix left alt key to type special characters such as #
  send_composed_key_when_left_alt_is_pressed = true,
  -- keys
  keys = {
    cmd_key(".", multiple_actions(":ZenMode")),
    cmd_key("[", act.SendKey({ mods = "CTRL", key = "o" })),
    cmd_key("]", act.SendKey({ mods = "CTRL", key = "i" })),
    cmd_key("H", act.SendKey({ mods = "CTRL", key = "h" })),
    cmd_key("J", act.SendKey({ mods = "CTRL", key = "j" })),
    cmd_key("K", act.SendKey({ mods = "CTRL", key = "k" })),
    cmd_key("L", act.SendKey({ mods = "CTRL", key = "l" })),
    cmd_key("P", multiple_actions(":GoToCommand")),
    cmd_key("p", multiple_actions(":GoToFile")),
    cmd_key("j", multiple_actions(":GoToFile")),
    cmd_key("q", multiple_actions(":qa!")),
    cmd_to_tmux_prefix("1", "1"),
    cmd_to_tmux_prefix("2", "2"),
    cmd_to_tmux_prefix("3", "3"),
    cmd_to_tmux_prefix("4", "4"),
    cmd_to_tmux_prefix("5", "5"),
    cmd_to_tmux_prefix("6", "6"),
    cmd_to_tmux_prefix("7", "7"),
    cmd_to_tmux_prefix("8", "8"),
    cmd_to_tmux_prefix("9", "9"),
    cmd_to_tmux_prefix("`", "n"),
    cmd_to_tmux_prefix("b", "B"),
    cmd_to_tmux_prefix("C", "C"),
    cmd_to_tmux_prefix("d", "D"),
    cmd_to_tmux_prefix("G", "G"),
    cmd_to_tmux_prefix("g", "g"),
    cmd_to_tmux_prefix("k", "T"),
    cmd_to_tmux_prefix("l", "L"),
    cmd_to_tmux_prefix("N", '"'),
    cmd_to_tmux_prefix("n", "%"),
    cmd_to_tmux_prefix("o", "u"),
    cmd_to_tmux_prefix("r", "$"),
    cmd_to_tmux_prefix("T", "!"),
    cmd_to_tmux_prefix("t", "c"),
    cmd_to_tmux_prefix("w", "x"),
    cmd_to_tmux_prefix("f", "z"),

    cmd_key(
      "R",
      act.Multiple({
        act.SendKey({ key = "\x1b" }), -- escape
        multiple_actions(":source %"),
      })
    ),

    cmd_key(
      "s",
      act.Multiple({
        act.SendKey({ key = "\x1b" }), -- escape
        multiple_actions(":w"),
      })
    ),

    {
      mods = "CMD|SHIFT",
      key = "}",
      action = act.Multiple({
        act.SendKey({ mods = "CTRL", key = "b" }),
        act.SendKey({ key = "n" }),
      }),
    },
    {
      mods = "CMD|SHIFT",
      key = "{",
      action = act.Multiple({
        act.SendKey({ mods = "CTRL", key = "b" }),
        act.SendKey({ key = "p" }),
      }),
    },

    {
      mods = "CTRL",
      key = "Tab",
      action = act.Multiple({
        act.SendKey({ mods = "CTRL", key = "b" }),
        act.SendKey({ key = "n" }),
      }),
    },

    {
      mods = "CTRL|SHIFT",
      key = "Tab",
      action = act.Multiple({
        act.SendKey({ mods = "CTRL", key = "b" }),
        act.SendKey({ key = "n" }),
      }),
    },
    {
      mods = "CTRL",
      key = "[",
      action = act.Multiple({
        act.SendKey({ mods = "CTRL", key = "b" }),
        act.SendKey({ key = "[" }),
      }),
    },

    -- FIX: disable binding
    -- {
    -- 	mods = "CMD",
    -- 	key = "`",
    -- 	action = act.Multiple({
    -- 		act.SendKey({ mods = "CTRL", key = "b" }),
    -- 		act.SendKey({ key = "n" }),
    -- 	}),
    -- },

    {
      mods = "CMD",
      key = "~",
      action = act.Multiple({
        act.SendKey({ mods = "CTRL", key = "b" }),
        act.SendKey({ key = "p" }),
      }),
    },
  },
  mouse_bindings = {
    -- CMD-click will open the link under the mouse cursor
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "CMD",
      action = wezterm.action.OpenLinkAtMouseCursor,
    },
  },
}
