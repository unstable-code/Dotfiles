local wezterm = require 'wezterm'
local config = {}

--minimum: 80x25
config.initial_rows = 24
config.initial_cols = 80

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local title = tab.active_pane.title

  -- WSL 프로세스 판별 (bash/zsh)
  local icon = " "   -- Linux Tux 아이콘

  return {
    { Text = " " .. icon .. title .. " " },
  }
end)


-- ------------------------------------
-- 글꼴 설정
-- ------------------------------------
config.font = wezterm.font("D2Coding")
config.font_size = 12.5

-- ------------------------------------
-- 아크릴 느낌 반투명 효과
-- ------------------------------------
config.color_scheme = "OneHalfDark"

config.window_background_opacity = 0.9
config.window_background_gradient = {
  orientation = "Vertical",
  colors = {
    "#1e1e1e",
    "#1e1e1ecc",
  },
  blend = "Oklab",
}
config.window_background_image_hsb = {
  saturation = 0.9,
  brightness = 0.9,
}

-- ------------------------------------
-- 탭바
-- ------------------------------------
config.use_fancy_tab_bar = true

-- 탭 색상 매핑 테이블
local tab_colors = {
  ["WSL"] = { bg = "#1e4620", fg = "#d0ffd0" },       -- 진녹색 계열
  ["PowerShell"] = { bg = "#1b3c64", fg = "#d0e6ff" }, -- 파란 계열
  ["cmd"] = { bg = "#444444", fg = "#ffffff" },        -- 회색
}

-- 탭 제목 및 색상 설정 이벤트
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  local process = pane.foreground_process_name or ""
  local title = pane.title

  -- 프로필 구분 규칙
  local profile = "default"
  if process:match("bash") or process:match("zsh") then
    profile = "WSL"
  elseif process:match("powershell") or process:match("pwsh") then
    profile = "PowerShell"
  elseif process:match("cmd.exe") then
    profile = "cmd"
  end

  -- 색상 선택
  local color = tab_colors[profile] or { bg = "#333333", fg = "#ffffff" }

  return {
    { Background = { Color = color.bg } },
    { Foreground = { Color = color.fg } },
    { Text = " " .. title .. " " },
  }
end)

-- ------------------------------------
-- 기본 셸: WSL 홈(~)에서 시작
-- ------------------------------------
config.default_prog = { "wsl.exe", "~" }

-- ------------------------------------
-- 창 제목에 현재 창 크기 표시
-- ------------------------------------
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.enable_wayland = false

wezterm.on("update-right-status", function(window, pane)
  local dim = pane:get_dimensions()
  local msg = string.format("[%d, %d]", dim.cols, dim.viewport_rows)

  window:set_right_status(msg)
end)

-- -------------------------------------
-- 링크 열기 동작 변경
-- --------------------------------------
config.disable_default_mouse_bindings = false

config.mouse_bindings = {
  -- Ctrl + LeftClick 때만 링크 열기 (Up 시점)
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
  -- 일반 LeftClick-Up에서 링크 열리는 기본 동작을 막음
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.Nop,
  },
}

return config
