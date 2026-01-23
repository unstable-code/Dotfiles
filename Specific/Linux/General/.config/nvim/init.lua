-- 1. 리더 키 설정 (가장 먼저 설정해야 매핑이 꼬이지 않습니다)
vim.g.mapleader = ","

-- 2. 일반 옵션 (vim.opt 사용)
local opt = vim.opt

opt.cursorline = true      -- 현재 행 강조
opt.number = true          -- 줄 번호 표시
opt.title = true           -- 터미널 제목 표시
opt.ruler = true           -- 상태표시줄에 커서 위치 표시
opt.splitbelow = true      -- 창 분할 시 아래에 생성

opt.expandtab = true       -- 탭을 공백으로 변환
opt.tabstop = 4            -- 탭 너비 4
opt.softtabstop = 4        -- 입력 시 탭 너비 4
opt.shiftwidth = 4         -- 자동 들여쓰기 너비 4
opt.smartindent = true     -- 스마트 들여쓰기

opt.smartcase = true       -- 대문자 포함 시 대소문자 구분 검색
opt.mouse = "a"            -- 마우스 모든 모드 사용
opt.autoread = true        -- 외부에서 변경된 파일 자동 읽기
opt.complete = ".,w,b,u,t,i" -- 자동 완성 범위 설정

-- 3. 키 매핑 (vim.keymap.set 사용)
local keymap = vim.keymap

-- Normal 모드 매핑
keymap.set('n', '<F7>', ':%!xxd<CR>', { desc = "Hex 덤프 보기" })
keymap.set('n', '<F3>', ':set hlsearch!<CR>', { desc = "검색 강조 토글" })
keymap.set('n', '<F5>', ':checktime<CR>', { desc = "파일 변경사항 체크" })

-- Insert 모드 매핑
keymap.set('i', 'jj', '<ESC>:w<CR>', { desc = "ESC 후 저장" })
keymap.set('i', '<F1>', '<ESC>', { desc = "F1으로 ESC" })
