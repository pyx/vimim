﻿" ======================================================
"               " VimIM —— Vim 中文輸入法 "
" ------------------------------------------------------
"   VimIM -- Input Method by Vim, of Vim, for Vimmers
" ======================================================

let $VimIM = "easter egg for env: ""     vimim<C-6><C-6>
let $VimIM = "easter egg for help:"" vimimhelp<C-6><C-6>
let $VimIM = "$Date$"
let $VimIM = "$Revision$"
let s:url  = ["http://vim.sf.net/scripts/script.php?script_id=2506"]
let s:url += ["http://vimim.googlecode.com/svn/trunk/plugin/vimim.cjk.txt"]
let s:url += ["http://vimim-data.googlecode.com"]
let s:url += ["http://groups.google.com/group/vimim"]
let s:url += ["http://vimim.googlecode.com/svn/vimim/vimim.html"]
let s:url += ["http://vimim.googlecode.com/svn/vimim/vimim.vim.html"]
let s:url += ["http://code.google.com/p/vimim/issues/list"]

let s:VimIM  = [" ====  introduction     ==== {{{"]
" =================================================
"    File: vimim.vim
"  Author: vimim <vimim@googlegroups.com>
" License: GNU Lesser General Public License
"  Readme: VimIM is a Vim plugin designed as an independent IM
"          (Input Method) to support CJK search and CJK input.
" ----------------
" "VimIM Features"
" ----------------
"  (1) Plug & Play: as a client to VimIM embedded backends
"  (2) Plug & Play: as a client to myCloud and Cloud
"  (3) input  Chinese without changing Vim mode
"  (4) search Chinese without popping up any window
" -------------------
" "VimIM Design Goal"
" -------------------
"  (1) Chinese can be searched using Vim without menu
"  (2) Chinese can be input using Vim regardless of encoding and OS
"  (3) No negative impact to Vim when VimIM is not used
"  (4) No compromise for high speed and low memory usage
" -------------------
" "VimIM Frontend UI"
" -------------------
"  (1) VimIM OneKey: Chinese input without mode change.
"  (2) VimIM Chinese Input Mode: ['dynamic','static']
"  (3) VimIM auto Chinese input with zero configuration
" ----------------------
" "VimIM Backend Engine"
" ----------------------
"  (1) [external] myCloud: http://pim-cloud.appspot.com
"  (2) [external]   Cloud: http://web.pinyin.sogou.com
"  (3) [embedded]   VimIM: http://vimim.googlecode.com
" --------------------
" "VimIM Installation"
" --------------------
"  (1) drop this vim script to plugin/:    plugin/vimim.vim
"  (2) [option] drop a standard cjk file:  plugin/vimim.cjk.txt
"  (3) [option] drop a standard directory: plugin/vimim/pinyin/
"  (4) [option] drop a English  datafile:  plugin/vimim.txt
" -------------
" "VimIM Usage"
" -------------
"  (1) play with sogou cloud, without datafile installed:
"      open vim, type i, type woyouyigemeng, hit <C-6>
"  (2) play with cjk standard file, with datafile installed:
"      open vim, type i, type sssss, hit <C-6>, hit 1/2/3/4/5/<Space>

" ============================================= }}}
let s:VimIM += [" ====  initialization   ==== {{{"]
" =================================================
if exists("b:loaded_vimim") || &cp || v:version<700
    finish
endif
scriptencoding utf-8
let b:loaded_vimim = 1
let s:path = expand("<sfile>:p:h")."/"

" -----------------------------------------
function! s:vimim_frontend_initialization()
" -----------------------------------------
    sil!call s:vimim_force_scan_current_buffer()
    sil!call s:vimim_initialize_shuangpin()
    sil!call s:vimim_initialize_keycode()
    sil!call s:vimim_set_special_im_property()
    sil!call s:vimim_initialize_frontend_punctuation()
    sil!call s:vimim_initialize_skin()
endfunction

" ---------------------------------------------
function! s:vimim_backend_initialization_once()
" ---------------------------------------------
    if empty(s:backend_loaded)
        let s:backend_loaded += 1
    else
        return
    endif
    sil!call s:vimim_super_reset()
    sil!call s:vimim_initialize_encoding()
    sil!call s:vimim_initialize_session()
    sil!call s:vimim_initialize_cjk_file()
    sil!call s:vimim_initialize_frontend()
    sil!call s:vimim_initialize_backend()
    sil!call s:vimim_initialize_i_setting()
    sil!call s:vimim_dictionary_chinese()
    sil!call s:vimim_dictionary_punctuation()
    sil!call s:vimim_dictionary_im_keycode()
    sil!call s:vimim_scan_backend_embedded_datafile()
    sil!call s:vimim_scan_backend_embedded_directory()
    sil!call s:vimim_dictionary_quantifiers()
    sil!call s:vimim_scan_backend_mycloud()
    sil!call s:vimim_scan_backend_cloud()
    sil!call s:vimim_scan_english_file()
    sil!call s:vimim_initialize_keycode()
endfunction

" ------------------------------------
function! s:vimim_initialize_session()
" ------------------------------------
    let s:uxxxx = '^u\x\x\x\x\|^\d\d\d\d\d\>'
    let s:smart_single_quotes = 1
    let s:smart_double_quotes = 1
    let s:www_libcall = 0
    let s:www_executable = 0
    let s:cloud_sogou_key = 0
    let s:vimim_cloud_plugin = 0
    let s:one_key_correction = 0
    let s:quanpin_table = {}
    let s:shuangpin_table = {}
    let s:shuangpin_keycode_chinese = {}
    let s:quantifiers = {}
    let s:current_positions = [0,0,1,0]
    let s:seamless_positions = []
    let s:start_row_before = 0
    let s:start_column_before = 1
    let s:scriptnames_output = 0
    let a = char2nr('a')
    let z = char2nr('z')
    let A = char2nr('A')
    let Z = char2nr('Z')
    let Az_nr_list = extend(range(A,Z), range(a,z))
    let s:Az_list = map(Az_nr_list, "nr2char(".'v:val'.")")
    let s:az_list = map(range(a,z), "nr2char(".'v:val'.")")
    let s:AZ_list = map(range(A,Z), "nr2char(".'v:val'.")")
    let s:valid_key = 0
    let s:valid_keys = s:az_list
    let s:abcd = "'abcdvfgz"
    let s:qwerty = split('pqwertyuio','\zs')
    let s:chinese_punctuation = (s:vimim_chinese_punctuation+1)%2
    let s:chinese_mode_switch = 0
    let s:vimim_debugs = []
endfunction

" --------------------------------
function! s:vimim_chinese(english)
" --------------------------------
    let key = a:english
    let chinese = key
    if has_key(s:chinese, key)
        let chinese = get(s:chinese[key], 0)
        if v:lc_time !~ 'gb2312'
        \&& len(s:chinese[key]) > 1
        \&& s:vimim_tab_as_onekey < 2
            let chinese = get(s:chinese[key], 1)
        endif
    endif
    return chinese
endfunction

" ------------------------------------
function! s:vimim_dictionary_chinese()
" ------------------------------------
    let s:space = "　"
    let s:plus  = "＋"
    let s:colon = "："
    let s:left  = "【"
    let s:right = "】"
    let s:chinese = {}
    let s:chinese['chinese']     = ['中文']
    let s:chinese['english']     = ['英文']
    let s:chinese['datafile']    = ['文件']
    let s:chinese['directory']   = ['目录','目錄']
    let s:chinese['database']    = ['词库','詞庫']
    let s:chinese['standard']    = ['标准','標準']
    let s:chinese['cjk']         = ['字库','字庫']
    let s:chinese['auto']        = ['自动','自動']
    let s:chinese['computer']    = ['电脑','電腦']
    let s:chinese['encoding']    = ['编码','編碼']
    let s:chinese['environment'] = ['环境','環境']
    let s:chinese['input']       = ['输入','輸入']
    let s:chinese['font']        = ['字体','字體']
    let s:chinese['static']      = ['静态','靜態']
    let s:chinese['dynamic']     = ['动态','動態']
    let s:chinese['style']       = ['风格','風格']
    let s:chinese['wubi']        = ['五笔','五筆']
    let s:chinese['hangul']      = ['韩文','韓文']
    let s:chinese['xinhua']      = ['新华','新華']
    let s:chinese['zhengma']     = ['郑码','鄭碼']
    let s:chinese['cangjie']     = ['仓颉','倉頡']
    let s:chinese['boshiamy']    = ['呒虾米','嘸蝦米']
    let s:chinese['newcentury']  = ['新世纪','新世紀']
    let s:chinese['taijima']     = ['太极码','太極碼']
    let s:chinese['yong']        = ['永码','永碼']
    let s:chinese['wu']          = ['吴语','吳語']
    let s:chinese['erbi']        = ['二笔','二筆']
    let s:chinese['configure']   = ['设置','設置']
    let s:chinese['jidian']      = ['极点','極點']
    let s:chinese['shuangpin']   = ['双拼','雙拼']
    let s:chinese['abc']         = ['智能双打','智能雙打']
    let s:chinese['ms']          = ['微软','微軟']
    let s:chinese['nature']      = ['自然码','自然碼']
    let s:chinese['purple']      = ['紫光']
    let s:chinese['plusplus']    = ['加加']
    let s:chinese['flypy']       = ['小鹤','小鶴']
    let s:chinese['cloudatwill'] = ['想云就云','想雲就雲']
    let s:chinese['mycloud']     = ['自己的云','自己的雲']
    let s:chinese['onekey']      = ['点石成金','點石成金']
    let s:chinese['quick']       = ['速成']
    let s:chinese['phonetic']    = ['注音']
    let s:chinese['array30']     = ['行列']
    let s:chinese['sogou']       = ['搜狗']
    let s:chinese['pinyin']      = ['拼音']
    let s:chinese['myversion']   = ['版本']
    let s:chinese['full_width']  = ['全角']
    let s:chinese['half_width']  = ['半角']
endfunction

" ---------------------------------------
function! s:vimim_dictionary_im_keycode()
" ---------------------------------------
    let s:im_keycode = {}
    let s:im_keycode['pinyin']   = "[0-9a-z'.]"
    let s:im_keycode['sogou']    = "[0-9a-z']"
    let s:im_keycode['mycloud']  = "[0-9a-z']"
    let s:im_keycode['hangul']   = "[0-9a-z']"
    let s:im_keycode['xinhua']   = "[0-9a-z']"
    let s:im_keycode['quick']    = "[0-9a-z']"
    let s:im_keycode['wubi']     = "[0-9a-z']"
    let s:im_keycode['erbi']     = "[a-z'.,;/]"
    let s:im_keycode['yong']     = "[a-z'.;/]"
    let s:im_keycode['wu']       = "[a-z'.]"
    let s:im_keycode['nature']   = "[a-z'.]"
    let s:im_keycode['zhengma']  = "[a-z']"
    let s:im_keycode['cangjie']  = "[a-z']"
    let s:im_keycode['taijima']  = "[a-z']"
    let s:im_keycode['boshiamy'] = "[][a-z'.,]"
    let s:im_keycode['phonetic'] = "[0-9a-z.,;/]"
    let s:im_keycode['array30']  = "[0-9a-z.,;/]"
    " -------------------------------------------
    let vimimkeys = copy(keys(s:im_keycode))
    call add(vimimkeys, 'pinyin_quote_sogou')
    call add(vimimkeys, 'pinyin_sogou')
    call add(vimimkeys, 'pinyin_huge')
    call add(vimimkeys, 'pinyin_fcitx')
    call add(vimimkeys, 'pinyin_canton')
    call add(vimimkeys, 'pinyin_hongkong')
    call add(vimimkeys, 'wubijd')
    call add(vimimkeys, 'wubi98')
    call add(vimimkeys, 'wubi2000')
    let s:all_vimim_input_methods = copy(vimimkeys)
endfunction

" -------------------------------------------------------
function! s:vimim_expand_character_class(character_class)
" -------------------------------------------------------
    let character_string = ""
    let i = 0
    while i < 256
        let char = nr2char(i)
        if char =~# a:character_class
            let character_string .= char
        endif
        let i += 1
    endwhile
    return character_string
endfunction

" ------------------------------------
function! s:vimim_initialize_keycode()
" ------------------------------------
    let keycode = "[0-9a-z'.]"
    let keycode2 = s:backend[s:ui.root][s:ui.im].keycode
    if !empty(keycode2)
        let keycode = copy(keycode2)
    endif
    if !empty(s:vimim_shuangpin)
        let keycode = s:shuangpin_keycode_chinese.keycode
    endif
    let s:valid_key = copy(keycode)
    let keycode_real = s:vimim_expand_character_class(keycode)
    let s:valid_keys = split(keycode_real, '\zs')
endfunction

" ============================================= }}}
let s:VimIM += [" ====  customization    ==== {{{"]
" =================================================

" -----------------------------------
function! s:vimim_initialize_global()
" -----------------------------------
    let s:vimimconf = []
    let G = []
    call add(G, "g:vimim_tab_as_onekey")
    call add(G, "g:vimim_digit_4corner")
    call add(G, "g:vimim_data_file")
    call add(G, "g:vimim_data_directory")
    call add(G, "g:vimim_poem_directory")
    call add(G, "g:vimim_chinese_input_mode")
    call add(G, "g:vimim_ctrl_space_to_toggle")
    call add(G, "g:vimim_backslash_close_pinyin")
    call add(G, "g:vimim_imode_pinyin")
    call add(G, "g:vimim_shuangpin")
    call add(G, "g:vimim_latex_suite")
    call add(G, "g:vimim_cloud_sogou")
    call add(G, "g:vimim_mycloud_url")
    call add(G, "g:vimim_use_cache")
    call add(G, "g:vimim_debug")
    " -----------------------------------
    call s:vimim_set_global_default(G, 0)
    " -----------------------------------
    let G = []
    call add(G, "g:vimim_custom_label")
    call add(G, "g:vimim_custom_color")
    call add(G, "g:vimim_custom_statusline")
    call add(G, "g:vimim_onekey_nonstop")
    call add(G, "g:vimim_chinese_punctuation")
    call add(G, "g:vimim_search_next")
    " -----------------------------------
    call s:vimim_set_global_default(G, 1)
    " -----------------------------------
    let s:backend_loaded = 0
    let s:chinese_input_mode = "onekey"
    if empty(s:vimim_chinese_input_mode)
        let s:vimim_chinese_input_mode = "dynamic"
    elseif s:vimim_chinese_input_mode == 1
        let s:vimim_chinese_input_mode = "static"
    endif
endfunction

" ----------------------------------------------------
function! s:vimim_set_global_default(options, default)
" ----------------------------------------------------
    let vimimconf = []
    for variable in a:options
        let s_variable = substitute(variable,"g:","s:",'')
        if exists(variable)
            call add(vimimconf, variable .' = '. eval(variable))
            exe 'let '. s_variable .'='. variable
            exe 'unlet! ' . variable
        else
            call add(s:vimimconf, variable .'='. a:default)
            exe 'let '. s_variable . '=' . a:default
        endif
    endfor
    call extend(s:vimimconf, vimimconf, 0)
endfunction

" ============================================= }}}
let s:VimIM += [" ====  easter eggs      ==== {{{"]
" =================================================

" -------------------------
function! s:vimim_egg_vim()
" -------------------------
    let eggs  = ["vi    文本編輯器"]
    let eggs += ["vim   最牛文本編輯器"]
    let eggs += ["vim   精力"]
    let eggs += ["vim   生氣"]
    let eggs += ["vimim 中文輸入法"]
    return eggs
endfunction

" -------------------------------
function! s:vimim_egg_vimimhelp()
" -------------------------------
    let eggs = []
    call add(eggs, "官方网址 " . s:url[0] . " ")
    call add(eggs, "标准字库 " . s:url[1] . " ")
    call add(eggs, "民间词库 " . s:url[2] . " ")
    call add(eggs, "新闻论坛 " . s:url[3] . " ")
    call add(eggs, "最新主页 " . s:url[4] . " ")
    call add(eggs, "最新程式 " . s:url[5] . " ")
    call add(eggs, "错误报告 " . s:url[6] . " ")
    return eggs
endfunction

" ------------------------------
function! s:vimim_egg_vimimvim()
" ------------------------------
    let eggs = copy(s:VimIM)
    let filter = "strpart(" . 'v:val' . ", 0, 28)"
    return map(eggs, filter)
endfunction

" ---------------------------
function! s:vimim_egg_vimim()
" ---------------------------
    let eggs = []
    let option = "os"
    if has("win32unix")
        let option = "cygwin"
    elseif has("win32")
        let option = "Windows32"
    elseif has("win64")
        let option = "Windows64"
    elseif has("unix")
        let option = "unix"
    elseif has("macunix")
        let option = "macunix"
    endif
    let option .= "_" . &term
    let computer = s:vimim_chinese('computer') . s:colon
    call add(eggs, computer . option)
    " --------------------------------------------------------------
    let myversion = s:vimim_chinese('myversion') . s:colon
    let option = get(split($VimIM), 1)
    if !empty(option)
        let option = "vimim.vim=" . option
    endif
    let vim = s:space . s:space . v:progname . "=" . v:version
    call add(eggs, myversion . option . vim)
    " --------------------------------------------------------------
    let encoding = s:vimim_chinese('encoding') . s:colon
    call add(eggs, encoding . &encoding . s:space . &fileencodings)
    " --------------------------------------------------------------
    if has("gui_running")
        let option = s:vimim_chinese('font') . s:colon . &guifontwide
        call add(eggs, option)
    endif
    " --------------------------------------------------------------
    let option = s:vimim_chinese('environment') . s:colon . v:lc_time
    call add(eggs, option)
    " --------------------------------------------------------------
    let im = s:vimim_statusline()
    let toggle = "i_CTRL-Bslash"
    let buffer = expand("%:p:t")
    if buffer =~# '.vimim\>'
        let toggle = s:vimim_chinese('auto') . s:space . buffer
    elseif s:vimim_ctrl_space_to_toggle == 1
        let toggle = "toggle_with_CTRL-Space"
    elseif s:vimim_tab_as_onekey == 2
        let toggle = "Tab_as_OneKey_NonStop"
        let im = s:vimim_chinese('onekey') . s:space
        let im .= s:ui.statusline . s:space . "VimIM"
    endif
    let option = s:vimim_chinese('style') . s:colon . toggle
    call add(eggs, option)
    " --------------------------------------------------------------
    let database = s:vimim_chinese('database') . s:colon
    if s:has_cjk_file > 0
        let ciku  = database . s:vimim_chinese('standard')
        let ciku .= s:vimim_chinese('cjk') . s:colon
        call add(eggs, ciku . s:cjk_file)
    endif
    if s:has_english_file > 0
        let ciku = database . s:vimim_chinese('english') . database
        call add(eggs, ciku . s:english_file)
    endif
    if len(s:ui.frontends) > 0
        for frontend in s:ui.frontends
            let ui_root = get(frontend, 0)
            let ui_im = get(frontend, 1)
            let ciku =  database . s:vimim_chinese(ui_root) . database
            let datafile = s:backend[ui_root][ui_im].name
            call add(eggs, ciku . datafile)
        endfor
    endif
    " --------------------------------------------------------------
    if !empty(im)
        let option = s:vimim_chinese('input') . s:colon . im
        call add(eggs, option)
    endif
    " --------------------------------------------------------------
    if s:vimim_cloud_sogou == 888
        let sogou = s:vimim_chinese('sogou')
        let option = sogou . s:colon . s:vimim_chinese('cloudatwill')
        call add(eggs, option)
    endif
    " --------------------------------------------------------------
    let filter = 'v:val . " "'
    call map(eggs, filter)
    " --------------------------------------------------------------
    call add(eggs, s:vimim_chinese('configure') . s:colon)
    " gather vimim configuration information
    let vimimconf = copy(s:vimimconf)
    let filter = '":let " . v:val . " "'
    call map(vimimconf, filter)
    " append vimim configuration to the vimim egg
    call extend(eggs, vimimconf)
    " --------------------------------------------------------------
    return eggs
endfunction

" ----------------------------------------
function! s:vimim_easter_chicken(keyboard)
" ----------------------------------------
    let keyboard = a:keyboard
    if keyboard ==# "vim" || keyboard =~# "^vimim"
        " hunt for easter egg
    else
        return []
    endif
    try
        return eval("s:vimim_egg_" . keyboard . "()")
    catch
        call s:debugs('egg::', v:exception)
    endtry
    return []
endfunction

" ============================================= }}}
let s:VimIM += [" ====  vimim.cjk.txt    ==== {{{"]
" =================================================

" -------------------------------------
function! s:vimim_initialize_cjk_file()
" -------------------------------------
    let s:has_slash_grep = 0
    let s:has_cjk_file = 0
    let s:cjk_file = 0
    let s:cjk_cache = {}
    let s:cjk_lines = []
    let datafile = "vimim.cjk.txt"
    let datafile = s:vimim_check_filereadable(datafile)
    if !empty(datafile)
        let s:cjk_file = datafile
        let s:has_cjk_file = 1
    endif
endfunction

" --------------------------------------------
function! s:vimim_cjk_sentence_match(keyboard)
" --------------------------------------------
    let keyboard = a:keyboard
    let keyboard_head = 0
    if s:show_me_not > 0 || len(keyboard) == 1
        let keyboard_head = keyboard
    elseif keyboard =~ '\d'
        if keyboard =~ '^\d' && keyboard !~ '\D'
            let keyboard_head = s:vimim_cjk_every_four(keyboard)
        elseif keyboard =~ '^\l\+\d\+'
            let keyboard_head = s:vimim_cjk_alpha_digit(keyboard)
        endif
    elseif s:has_cjk_file > 1 || s:ui.im == 'pinyin'
        if len(keyboard)%5 < 1 && keyboard !~ "[.']"
            let keyboard_head = s:vimim_cjk_sentence_diy(keyboard)
        endif
        if empty(keyboard_head)
            let keyboard_head = s:vimim_cjk_sentence_alpha(keyboard)
        endif
    endif
    return keyboard_head
endfunction

" ----------------------------------------
function! s:vimim_cjk_every_four(keyboard)
" ----------------------------------------
    " output is '6021' for input  6021272260001762
    let keyboard = a:keyboard
    let block = 4
    if len(keyboard) % block < 1
        let pattern = '^\d\{' . block . '}'
        let delimiter = match(keyboard, pattern)
        if delimiter > -1
            let keyboard = s:vimim_get_keyboard_head_list(keyboard, block)
        endif
    endif
    return keyboard
endfunction

" -----------------------------------------
function! s:vimim_cjk_alpha_digit(keyboard)
" -----------------------------------------
    " output is 'wo23' for input wo23you40yigemeng
    let keyboard = a:keyboard
    if keyboard =~ '^\l\+\d\+\>'
        return keyboard
    endif
    let partition = match(keyboard, '\d')
    while partition > -1
        let partition += 1
        if keyboard[partition : partition] =~ '\D'
            break
        endif
    endwhile
    let head = s:vimim_get_keyboard_head_list(keyboard, partition)
    return head
endfunction

" ------------------------------------------
function! s:vimim_cjk_sentence_diy(keyboard)
" ------------------------------------------
    " output is 'm7712' for input muuqwxeyqpjeqqq
    let keyboard = a:keyboard
    let delimiter = match(keyboard, '^\l\l\l\l\l')
    if delimiter < 0
        return 0
    endif
    let llll = keyboard[1:4]
    let dddd = s:vimim_qwertyuiop_1234567890(llll)
    if empty(dddd)
        return 0
    endif
    let ldddd = keyboard[0:0] . dddd
    let keyboard = ldddd . keyboard[5:-1]
    let head = s:vimim_get_keyboard_head_list(keyboard, 5)
    return head
endfunction

" -----------------------------------------------
function! s:vimim_qwertyuiop_1234567890(keyboard)
" -----------------------------------------------
    " output is '7712' for input uuqw
    if a:keyboard =~ '\d' || s:has_cjk_file < 1
        return 0
    else
    let dddd = ""
    for char in split(a:keyboard, '\zs')
        let digit = match(s:qwerty, char)
        if digit < 0
            return 0
        else
            let dddd .= digit
        endif
    endfor
    return dddd
endfunction

" --------------------------------------------
function! s:vimim_cjk_sentence_alpha(keyboard)
" --------------------------------------------
    let keyboard = a:keyboard
    let a_keyboard = keyboard
    let magic_tail = keyboard[-1:-1]
    if magic_tail == "."
        "  magic trailing dot to use control cjjp: sssss.
        let s:hjkl_m += 1
        let a_keyboard = keyboard[0 : len(keyboard)-2]
    endif
    call s:vimim_load_cjk_file()
    let grep = '^' . a_keyboard . '\>'
    let matched = match(s:cjk_lines, grep)
    if s:hjkl_m > 0
        let keyboard = s:vimim_toggle_cjjp(a_keyboard)
    elseif matched < 0 && s:has_cjk_file > 0
        let keyboard = s:vimim_toggle_pinyin(a_keyboard)
    endif
    let head = a_keyboard
    let partition = match(keyboard, "[.']")
    if partition > -1
        let head = s:vimim_get_keyboard_head_list(a_keyboard, partition)
    endif
    if len(head) > len(a_keyboard)
        let head = a_keyboard
    endif
    return head
endfunction

" -----------------------------------
function! s:vimim_cjk_match(keyboard)
" -----------------------------------
    let keyboard = a:keyboard
    if empty(s:has_cjk_file)
        return []
    endif
    if len(keyboard) == 1 && has_key(s:cjk_cache, keyboard)
        if keyboard =~ '\d'
            let s:cjk_filter = keyboard
        endif
        return s:cjk_cache[keyboard]
    endif
    let dddddd = 6 - 2 * s:vimim_digit_4corner
    let grep_frequency = '.*' . '\s\d\+$'
    let grep = ""
    " ------------------------------------------------------
    if keyboard =~ '\d'
        if keyboard =~# '^\l\l\+[1-5]\>' && empty(len(s:cjk_filter))
            " cjk pinyin with tone: huan2hai2
            let grep =  keyboard . '[a-z ]'
        else
            let digit = ""
            if keyboard =~ '^\d\+' && keyboard !~ '\D'
                " cjk free-style digit input: 7 77 771 7712"
                let digit = keyboard
            elseif keyboard =~ '^\l\+\d\+'
                " cjk free-style input/search: ma7 ma77 ma771 ma7712
                " on line 81:  乐樂 352340 7290 le4yue4 music happy 426
                let digit = substitute(keyboard,'\a','','g')
            endif
            if !empty(digit)
                let space = dddddd - len(digit)
                let grep  = '\s' . digit
                let grep .= '\d\{' . space . '}\s'
                if dddddd == 6
                    let grep .= '\d\d\d\d\s'
                endif
                let alpha = substitute(keyboard,'\d','','g')
                if !empty(alpha)
                    " search le or yue from le4yue4
                    let grep .= '\(\l\+\d\)\=' . alpha
                elseif len(keyboard) == 1
                    " one-char-list by frequency y72/yue72 l72/le72
                    " search l or y from le4yue4 music happy 426
                    let grep .= grep_frequency
                endif
            endif
            if len(keyboard) < dddddd && len(string(digit)) > 0
                let s:cjk_filter = digit
            endif
        endif
    elseif s:ui.im == 'pinyin'
        if len(keyboard) == 1 && keyboard !~ '[ai]'
            " cjk one-char-list by frequency y72/yue72 l72/le72
            let grep = '[ 0-9]' . keyboard . '\l*\d' . grep_frequency
        elseif keyboard =~ '^\l'
            " cjk multiple-char-list without frequency: huan2hai2
            " support all cases: /huan /hai /yet /huan2 /hai2
            let grep = '[ 0-9]' . keyboard . '[0-9]'
        endif
        if s:ui.root != 'directory'
            let grep = 0
        endif
    else
        return []
    endif
    " ------------------------------------------------------
    let results = s:vimim_cjk_grep_results(grep)
    if len(results) > 0
        let results = sort(results, "s:vimim_sort_on_last")
        let filter = "strpart(" . 'v:val' . ", 0, s:multibyte)"
        call map(results, filter)
        if len(keyboard) == 1
            if has_key(s:cjk_cache, keyboard)
                let msg = "cache is available in memory"
            else
                let s:cjk_cache[keyboard] = results
                return results
            endif
        endif
    endif
    return results
endfunction

" -----------------------------------------
function s:vimim_sort_on_last(line1, line2)
" -----------------------------------------
    let line1 = get(split(a:line1),-1) + 1
    let line2 = get(split(a:line2),-1) + 1
    if line1 < line2
        return -1
    elseif line1 > line2
        return 1
    else
        return 0
    endif
endfunction

" -----------------------------------------------------------
function! s:vimim_get_keyboard_head_list(keyboard, partition)
" -----------------------------------------------------------
    if a:partition < 0
        let s:keyboard_list = []
        return a:keyboard
    endif
    let keyboards = []
    let head = a:keyboard[0 : a:partition-1]
    let tail  = a:keyboard[a:partition : -1]
    call add(keyboards, head)
    if !empty(tail)
        call add(keyboards, tail)
    endif
    if len(s:keyboard_list) < 2
        let s:keyboard_list = copy(keyboards)
    endif
    return head
endfunction

" -----------------------------------------------
function! s:vimim_cjk_filter_from_cache(keyboard)
" -----------------------------------------------
" use 1234567890/qwertyuiop as digit filter
    call s:vimim_load_cjk_file()
    let results = s:vimim_cjk_filter_list(a:keyboard)
    if empty(results) && !empty(len(s:cjk_filter))
        let number_before = strpart(s:cjk_filter,0,len(s:cjk_filter)-1)
        if len(number_before) > 0
            let s:cjk_filter = number_before
            let results = s:vimim_cjk_filter_list(a:keyboard)
        endif
    endif
    if empty(results)
        let s:cjk_filter = ""
    endif
    return results
endfunction

" -----------------------------------------
function! s:vimim_cjk_filter_list(keyboard)
" -----------------------------------------
    let pair_matched_list = []
    let first_in_list = split(get(s:matched_list,0))
    for chinese in s:matched_list
        if len(first_in_list) > 1
            let chinese = get(split(chinese), 1)
        endif
        let chinese = s:vimim_cjk_digit_filter(chinese)
        if empty(chinese)
            let msg = "garbage out and food in"
        else
            call add(pair_matched_list, chinese)
        endif
    endfor
    return pair_matched_list
endfunction

" -----------------------------------------
function! s:vimim_cjk_digit_filter(chinese)
" -----------------------------------------
" smart digital filter: 马力 7712 4002
"   (1) ma<C-6>         马   => filter with 7712
"   (2) mali<C-6>       马力 => filter with 7 4002
" -----------------------------------------
    let chinese = a:chinese
    if empty(len(s:cjk_filter))
    \|| empty(chinese)
    \|| chinese =~ '\w'
        return 0
    endif
    let digit_head = ""
    let digit_tail = ""
    let words = split(chinese,'\zs')
    for cjk in words
        let ddddd = char2nr(cjk)
        let line = ddddd - 19968
        if cjk =~ '\w' ||  line < 0 || line > 20902+200
            continue
        else
            let values = split(s:cjk_lines[line])
            let column = 1 + s:vimim_digit_4corner
            let digit = get(values, column)
            let digit_head .= digit[:0]
            let digit_tail = digit[1:]
        endif
    endfor
    let number = digit_head . digit_tail
    let pattern = "^" . s:cjk_filter
    let matched = match(number, pattern)
    if matched < 0
        let chinese = 0
    endif
    return chinese
endfunction

" ============================================= }}}
let s:VimIM += [" ====  for mom and dad  ==== {{{"]
" =================================================

" ---------------------------------
function! s:vimim_for_mom_and_dad()
" ---------------------------------
    let onekey = ""
    let s:mom_and_dad = 0
    let buffer = expand("%:p:t")
    if buffer =~ 'vimim.mom.txt'
        startinsert!
        let s:vimim_digit_4corner = 0
        let onekey = s:vimim_onekey_action()
        sil!call s:vimim_onekey_start()
    elseif buffer =~ 'vimim.dad.txt'
        set noruler
        let s:vimim_digit_4corner = 1
    else
        return
    endif
    if empty(s:has_cjk_file)
        return
    else
        let s:mom_and_dad = 1
        let s:vimim_tab_as_onekey = 2
    endif
    if has("gui_running") && has("win32")
        autocmd! * <buffer>
        autocmd  FocusLost <buffer> sil!wall
        noremap  <silent>  <Esc> :sil!%y +<CR>
        set tw=30
        set lines=24
        set columns=36
        set report=12345
        let &gfn .= ":h24:w12"
    endif
    sil!exe 'sil!return "' . onekey . '"'
endfunction

" ---------------------------------
function! s:vimim_initialize_skin()
" ---------------------------------
    if s:vimim_custom_color < 1
        return
    endif
    if s:vimim_custom_color == 1
        highlight! link PmenuSel Title
    elseif s:vimim_custom_color == 2
        highlight! PmenuSel NONE
    endif
    highlight! PmenuSbar  NONE
    highlight! PmenuThumb NONE
    highlight! Pmenu      NONE
endfunction

" ------------------------------------
function! s:vimim_cursor_color(switch)
" ------------------------------------
    if empty(a:switch)
        set ruler
        highlight! Cursor guifg=bg guibg=fg
    else
        set noruler
        highlight! Cursor guifg=bg guibg=green
    endif
endfunction

" ============================================= }}}
let s:VimIM += [" ====  /search          ==== {{{"]
" =================================================

" -----------------------------
function! g:vimim_search_next()
" -----------------------------
    let english = @/
    if english =~ '\<' && english =~ '\>'
        let english = substitute(english,'[<>\\]','','g')
    endif
    if len(english) > 1
    \&& len(english) < 24
    \&& english =~ '\w'
    \&& english !~ '\W'
    \&& english !~ '_'
    \&& v:errmsg =~# english
    \&& v:errmsg =~# '^E486: '
        let error = ""
        try
            sil!call s:vimim_search_chinese_from_english(english)
        catch
            let error = v:exception
        endtry
        echon "/" . english . error
    endif
    let v:errmsg = ""
endfunction

" -----------------------------------------------------
function! s:vimim_search_chinese_from_english(keyboard)
" -----------------------------------------------------
    sil!call s:vimim_backend_initialization_once()
    let keyboard = tolower(a:keyboard)
    let cjk_results = []
    let s:english_results = []
    " => slash search unicode /u808f
    let ddddd = s:vimim_get_unicode_ddddd(keyboard)
    " => slash search cjk /m7712x3610j3111 /muuqwxeyqpjeqqq
    if empty(ddddd)
        let keyboards = s:vimim_slash_search_block(keyboard)
        if len(keyboards) > 0
            for keyboard in keyboards
                let chars = s:vimim_cjk_match(keyboard)
                if len(keyboards) == 1
                    let cjk_results = copy(chars)
                elseif len(chars) > 0
                    let collection = "[" . join(chars,'') . "]"
                    call add(cjk_results, collection)
                endif
            endfor
            if len(keyboards) > 1
                let cjk_results = [join(cjk_results,'')]
            endif
        endif
    else
        let cjk_results = [nr2char(ddddd)]
    endif
    " => slash search english /horse
    if keyboard =~ '^\l\+'
        sil!call s:vimim_onekey_english(a:keyboard, 1)
    endif
    let results = []
    if empty(cjk_results) && empty(s:english_results)
        if !empty(s:vimim_shuangpin)
            sil!call s:vimim_initialize_shuangpin()
            let keyboard = s:vimim_get_pinyin_from_shuangpin(keyboard)
        endif
        if s:vimim_cloud_sogou == 1
            " => slash search from sogou cloud
            let results = s:vimim_get_cloud_sogou(keyboard, 1)
        elseif !empty(s:vimim_cloud_plugin)
            " => slash search from mycloud
            let results = s:vimim_get_mycloud_plugin(keyboard)
        endif
    endif
    if empty(results)
        " => slash search from local datafile or directory
        let results = s:vimim_embedded_backend_engine(keyboard,1)
    endif
    call extend(results, s:english_results, 0)
    call extend(results, cjk_results)
    if !empty(results)
        let slash = get(results, 0)
        if len(results) > 1
            let slash = join(results, '\|')
        endif
        if empty(search(slash,'nw'))
            let @/ = a:keyboard
        else
            let @/ = slash
        endif
        echon "/" . a:keyboard
    endif
endfunction

" --------------------------------------------
function! s:vimim_slash_search_block(keyboard)
" --------------------------------------------
" /muuqwxeyqpjeqqq  =>  shortcut   /search
" /m7712x3610j3111  =>  standard   /search
" /ma77xia36ji31    =>  free-style /search
" --------------------------------------------
    if empty(s:has_cjk_file)
        return []
    endif
    let results = []
    let keyboard = a:keyboard
    while len(keyboard) > 1
        let keyboard2 = s:vimim_cjk_sentence_match(keyboard)
        if empty(keyboard2)
            break
        else
            call add(results, keyboard2)
            let keyboard = strpart(keyboard,len(keyboard2))
        endif
    endwhile
    return results
endfunction

" -----------------------------------
function! g:vimim_search_pumvisible()
" -----------------------------------
    let word = s:vimim_onekey_popup_word()
    let @/ = word
    if empty(word)
        let @/ = @_
    endif
    let repeat_times = len(word)/s:multibyte
    let row_start = s:start_row_before
    let row_end = line('.')
    let delete_chars = ""
    if repeat_times > 0 && row_end == row_start
        let delete_chars = repeat("\<BS>", repeat_times)
    endif
    let slash = delete_chars . "\<Esc>"
    sil!call s:vimim_stop()
    sil!exe 'sil!return "' . slash . '"'
endfunction

" ============================================= }}}
let s:VimIM += [" ====  /grep            ==== {{{"]
" =================================================

" --------------------------------
function! s:vimim_slash_grep(grep)
" --------------------------------
    let results = s:vimim_cjk_grep_results(a:grep)
    if len(results) > 0
        let filter = "strpart(".'v:val'.", 0, s:multibyte)"
        call map(results, filter)
    endif
    return results
endfunction

" --------------------------------------
function! s:vimim_cjk_grep_results(grep)
" --------------------------------------
    let grep = a:grep
    " error: grep is e4494
    if empty(grep)
        return []
    endif
    call s:vimim_load_cjk_file()
    if empty(s:has_cjk_file)
        return []
    endif
    let results = []
    let line = match(s:cjk_lines, grep)
    while line > -1
        let values = split(s:cjk_lines[line])
        let frequency_index = get(values, -1)
        if frequency_index =~ '\l'
            let frequency_index = 9999
        endif
        let chinese_frequency = get(values,0) . ' ' . frequency_index
        call add(results, chinese_frequency)
        let line = match(s:cjk_lines, grep, line+1)
    endwhile
    return results
endfunction

" -------------------------------
function! s:vimim_load_cjk_file()
" -------------------------------
    if empty(s:cjk_lines) && s:has_cjk_file > 0
        let msg = "load cjk lines and build one char cache"
    else
        return
    endif
    let s:cjk_lines = s:vimim_readfile(s:cjk_file)
    let cjk = len(s:cjk_lines)
    if cjk < 20902
        let s:cjk_lines = []
        let s:has_cjk_file = 0
    elseif len(s:cjk_cache) > len('abcdefg')
        return
    endif
    if cjk == 20902
        for _ in s:az_list
            call s:vimim_cjk_match(_)
        endfor
    elseif cjk > 20902
        for line in s:cjk_lines[20902: -1]
            let lines = split(line)
            let char = get(lines,0)
            let right = get(lines,1)
            let results = split(right, '\zs')
            if has_key(s:cjk_cache, char)
                let history_results = s:cjk_cache[char]
                call extend(results, history_results, 0)
            endif
            let s:cjk_cache[char] = results
        endfor
    endif
endfunction

" ---------------------------------------------
function! s:vimim_tranfer_chinese() range abort
" ---------------------------------------------
" [usage]   :VimIM
" [feature] (1) "quick and dirty" way to transfer Chinese to Chinese
"           (2) 20% of the effort to solve 80% of the problem
"           (3) 5128/2=2564 Chinese pairs are used for one-to-one mapping
" ---------------------------------------------
    sil!call s:vimim_backend_initialization_once()
    if empty(s:has_cjk_file)
        let msg = "no toggle between simplified and tranditional Chinese"
    elseif &encoding == "utf-8"
        call s:vimim_load_cjk_file()
        exe a:firstline.",".a:lastline.'s/./\=s:vimim_one2one(submatch(0))'
    endif
endfunction

" ------------------------------------------------
function! s:vimim_get_traditional_chinese(chinese)
" ------------------------------------------------
    call s:vimim_load_cjk_file()
    let chinese = ""
    let chinese_list = split(a:chinese,'\zs')
    for char in chinese_list
        let chinese .= s:vimim_one2one(char)
    endfor
    return chinese
endfunction

" --------------------------------
function! s:vimim_one2one(chinese)
" --------------------------------
    let ddddd = char2nr(a:chinese)
    let line = ddddd - 19968
    if line < 0 || line > 20902+200
        return a:chinese
    endif
    let values = split(s:cjk_lines[line])
    let traditional_chinese = get(split(get(values,0),'\zs'),1)
    if empty(traditional_chinese)
        return a:chinese
    else
        return traditional_chinese
    endif
endfunction

" ------------------------------------------
function! <SID>vimim_visual_ctrl_6(keyboard)
" ------------------------------------------
" [input]  马力  highlighted in vim visual mode
" [output] 9a6c   529b    --  in unicode
"          7712   4002    --  in four corner
"          551000 530000  --  in five stroke
"          ma3    li4     --  in pinyin
"          ml 马力        --  in cjjp
" ------------------------------------------
    let keyboard = a:keyboard
    let range = line("'>") - line("'<")
    if empty(range)
        sil!call s:vimim_backend_initialization_once()
        let results = s:vimim_reverse_lookup(keyboard)
        if !empty(results)
            let line = line(".")
            call setline(line, results)
            let new_positions = getpos(".")
            let new_positions[1] = line + len(results) - 1
            let new_positions[2] = len(get(split(get(results,-1)),0))+1
            call setpos(".", new_positions)
        endif
    elseif s:vimim_tab_as_onekey > 0
        sil!call s:vimim_numberList()
    endif
endfunction

" ---------------------------------------
function! s:vimim_reverse_lookup(chinese)
" ---------------------------------------
    let chinese = substitute(a:chinese,'\s\+\|\w\|\n','','g')
    if empty(chinese)
        return []
    endif
    let results = []
    let results_unicode = s:vimim_get_property(chinese, 'unicode')
    if !empty(results_unicode)
        call extend(results, results_unicode)
    endif
    if empty(s:has_cjk_file)
        return results
    endif
    call s:vimim_load_cjk_file()
    let results_digit = s:vimim_get_property(chinese, 2)
    call extend(results, results_digit)
    let results_digit = s:vimim_get_property(chinese, 1)
    call extend(results, results_digit)
    let results_pinyin = []  " 马力 => ma3 li2
    let result_cjjp = ""     " 马力 => ml
    let items = s:vimim_get_property(chinese, 'pinyin')
    if len(items) > 0
        let pinyin_head = get(items,0)
        if !empty(pinyin_head)
            call add(results_pinyin, pinyin_head)
            call add(results_pinyin, get(items,1))
            for pinyin in split(pinyin_head)
                let result_cjjp .= pinyin[0:0]
            endfor
            let result_cjjp .= " ".chinese
        endif
    endif
    if !empty(results_pinyin)
        call extend(results, results_pinyin)
        if result_cjjp =~ '\a'
            call add(results, result_cjjp)
        endif
    endif
    return results
endfunction

" -----------------------------------------------
function! s:vimim_get_property(chinese, property)
" -----------------------------------------------
    let property = a:property
    let headers = []
    let bodies = []
    for chinese in split(a:chinese, '\zs')
        let ddddd = char2nr(chinese)
        let line = ddddd - 19968
        if line < 0 || line > 20902+200
            continue
        endif
        let head = ''
        if property == 'unicode'
            let head = printf('%x', ddddd)
        elseif s:has_cjk_file > 0
            let values = split(s:cjk_lines[line])
            if property =~ '\d'
                let head = get(values, property)
            elseif property == 'pinyin'
                let head = get(values, 3)
            elseif property == 'english'
                let head = join(values[4:-2])
            endif
        endif
        if empty(head)
            continue
        endif
        call add(headers, head)
        let spaces = ''
        let gap = len(head)-2
        if gap > 0
            let space = ' '
            for i in range(gap)
                let spaces .= space
            endfor
        endif
        call add(bodies, chinese . spaces)
    endfor
    return [join(headers), join(bodies)]
endfunction

" ----------------------------------------
function! s:vimim_numberList() range abort
" ----------------------------------------
    let a=line("'<")|let z=line("'>")|let x=z-a+1|let pre=' '
    while (a<=z)
        if match(x,'^9*$')==0|let pre=pre . ' '|endif
        call setline(z, pre . x . "\t" . getline(z))
        let z=z-1|let x=x-1
    endwhile
endfunction

" ============================================= }}}
let s:VimIM += [" ====  debug framework  ==== {{{"]
" =================================================

" ----------------------------------
function! s:vimim_initialize_debug()
" ----------------------------------
    if isdirectory("/home/xma")
        let g:vimim_digit_4corner = 1
        let g:vimim_tab_as_onekey = 2
        let g:vimim_poem_directory = "/home/xma/poem/"
        let g:vimim_data_directory = "/home/vimim/pinyin/"
    endif
endfunction

" -------------------------------------
function! s:vimim_initialize_frontend()
" -------------------------------------
    let s:ui = {}
    let s:ui.im  = ''
    let s:ui.root = ''
    let s:ui.keycode = ''
    let s:ui.statusline = ''
    let s:ui.has_dot = 0
    let s:ui.frontends = []
endfunction

" ------------------------------------
function! s:vimim_initialize_backend()
" ------------------------------------
    let s:backend = {}
    let s:backend.directory = {}
    let s:backend.datafile  = {}
    let s:backend.cloud     = {}
endfunction

" ---------------------------------
function! s:vimim_one_backend_hash()
" ----------------------------------
    let one_backend_hash = {}
    let one_backend_hash.root = 0
    let one_backend_hash.im = 0
    let one_backend_hash.name = 0
    let one_backend_hash.chinese = 0
    let one_backend_hash.directory = 0
    let one_backend_hash.lines = []
    let one_backend_hash.cache = {}
    let one_backend_hash.keycode = "[0-9a-z'.]"
    return one_backend_hash
endfunction

" ----------------------------
function! s:debugs(key, value)
" ----------------------------
    if s:vimim_debug > 0
        let item  = a:key
        let item .= ' = '
        let item .= a:value
        call add(s:vimim_debugs, item)
    endif
endfunction

" ============================================= }}}
let s:VimIM += [" ====  plugin conflict  ==== {{{"]
" =================================================

" -----------------------------------
function! s:vimim_plugins_fix_start()
" -----------------------------------
    if s:vimim_tab_as_onekey == 2
        return
    endif
    " -------------------------------
    if !exists('s:acp_sid')
        let s:acp_sid = s:vimim_getsid('autoload/acp.vim')
        if !empty(s:acp_sid)
            AcpDisable
        endif
    endif
    if !exists('s:supertab_sid')
        let s:supertab_sid = s:vimim_getsid('plugin/supertab.vim')
    endif
    if !exists('s:word_complete')
        let s:word_complete = s:vimim_getsid('plugin/word_complete.vim')
        if !empty(s:word_complete)
            call EndWordComplete()
        endif
    endif
endfunction

" ----------------------------------
function! s:vimim_getsid(scriptname)
" ----------------------------------
" frederick.zou fixed these conflicting plugins:
" supertab      http://www.vim.org/scripts/script.php?script_id=1643
" autocomplpop  http://www.vim.org/scripts/script.php?script_id=1879
" word_complete http://www.vim.org/scripts/script.php?script_id=73
" ------------------------------------------------------------------
    " use s:getsid to get script sid, translate <SID> to <SNR>N_ style
    let l:scriptname = a:scriptname
    " get output of ":scriptnames" in scriptnames_output variable
    if empty(s:scriptnames_output)
        let saved_shellslash=&shellslash
        set shellslash
        redir => s:scriptnames_output
        silent scriptnames
        redir END
        let &shellslash = saved_shellslash
    endif
    for line in split(s:scriptnames_output, "\n")
        " only do non-blank lines
        if line =~ l:scriptname
            " get the first number in the line.
            let nr = matchstr(line, '\d\+')
            return nr
        endif
    endfor
    return 0
endfunction

" ----------------------------------
function! s:vimim_plugins_fix_stop()
" ----------------------------------
    if s:vimim_tab_as_onekey == 2
        return
    endif
    " ------------------------------
    if !empty(s:acp_sid)
        let ACPMappingDrivenkeys = [
            \ '-','_','~','^','.',',',':','!','#','=','%','$','@',
            \ '<','>','/','\','<Space>','<BS>','<CR>',]
        call extend(ACPMappingDrivenkeys, range(10))
        call extend(ACPMappingDrivenkeys, s:Az_list)
        for key in ACPMappingDrivenkeys
            exe printf('iu <silent> %s', key)
            exe printf('im <silent> %s
            \ %s<C-r>=<SNR>%s_feedPopup()<CR>', key, key, s:acp_sid)
        endfor
        AcpEnable
    endif
    " -------------------------------------------------------------
    if !empty(s:supertab_sid)
        let tab = s:supertab_sid
        if g:SuperTabMappingForward =~ '^<tab>$'
            exe printf("im <tab> <C-R>=<SNR>%s_SuperTab('p')<CR>", tab)
        endif
        if g:SuperTabMappingBackward =~ '^<s-tab>$'
            exe printf("im <s-tab> <C-R>=<SNR>%s_SuperTab('n')<CR>", tab)
        endif
    endif
endfunction

" ============================================= }}}
let s:VimIM += [" ====  Chinese mode     ==== {{{"]
" =================================================
" s:chinese_input_mode='onekey'  => (default) OneKey hjkl
" s:chinese_input_mode='dynamic' => (default) dynamic mode
" s:chinese_input_mode='static'  => OneKey but not hit-and-run

" --------------------------
function! <SID>ChineseMode()
" --------------------------
    call s:vimim_backend_initialization_once()
    let s:chinese_input_mode = s:vimim_chinese_input_mode
    let action = ""
    if !empty(s:ui.root) && !empty(s:ui.im)
        let s:chinese_mode_switch += 1
        let switch = 0
        if s:ui.root == 'cloud'
            let switch = s:chinese_mode_switch % 2
        else
            let cycle = len(s:ui.frontends) + 1
            let switch = s:chinese_mode_switch % cycle
            let ui = get(s:ui.frontends, switch-1)
            if empty(ui)
                let switch = 0
            else
                let s:ui.root = get(ui,0)
                let s:ui.im = get(ui,1)
                call s:vimim_frontend_initialization()
                call s:vimim_set_statusline()
                call s:vimim_build_datafile_cache()
                call s:vimim_do_cloud_if_no_embedded_backend()
            endif
        endif
        let action = s:vimim_chinesemode_action(switch)
    endif
    sil!exe 'sil!return "' . action . '"'
endfunction

" ------------------------------------------
function! s:vimim_chinesemode_action(switch)
" ------------------------------------------
    let action = ""
    if empty(a:switch)
        call s:vimim_stop()
        if mode() == 'i'
            let action = "\<C-O>:redraw\<CR>"
        elseif mode() == 'n'
            :redraw!
        endif
    else
        sil!call s:vimim_start()
        if s:vimim_chinese_punctuation > -1
            let s:chinese_punctuation = s:vimim_chinese_punctuation%2
            call s:vimim_punctuation_mapping_on()
        endif
        if s:chinese_input_mode =~ 'dynamic'
            sil!call s:vimim_set_seamless()
            if s:ui.im =~ 'wubi' || s:ui.im =~ 'erbi'
                sil!call s:vimim_dynamic_wubi_auto_trigger()
            else
                sil!call s:vimim_dynamic_alphabet_trigger()
            endif
        elseif s:chinese_input_mode =~ 'static'
            sil!call s:vimim_static_alphabet_auto_select()
            if pumvisible()
                let msg = "<C-\> does nothing on omni menu"
            else
                let action = s:vimim_static_action("")
            endif
        endif
    endif
    sil!exe 'sil!return "' . action . '"'
endfunction

" ------------------------------------
function! s:vimim_static_action(space)
" ------------------------------------
    let space = a:space
    let byte_before = getline(".")[col(".")-2]
    if byte_before =~# s:valid_key
        if s:pattern_not_found < 1
            let space = '\<C-R>=g:vimim()\<CR>'
        else
            let s:pattern_not_found = 0
        endif
    endif
    sil!exe 'sil!return "' . space . '"'
endfunction

" ---------------------------------------------
function! s:vimim_static_alphabet_auto_select()
" ---------------------------------------------
    for char in s:Az_list
        sil!exe 'inoremap <silent> ' . char . '
        \ <C-R>=g:vimim_pumvisible_ctrl_y()<CR>'. char .
        \'<C-R>=g:vimim_reset_after_insert()<CR>'
    endfor
endfunction

" ------------------------------------------
function! s:vimim_dynamic_alphabet_trigger()
" ------------------------------------------
    let not_used_valid_keys = "[0-9.']"
    if s:ui.has_dot == 1
        let not_used_valid_keys = "[0-9]"
    endif
    for char in s:valid_keys
        if char !~# not_used_valid_keys
            sil!exe 'inoremap <silent> ' . char . '
            \ <C-R>=g:vimim_pumvisible_ctrl_e()<CR>'. char .
            \'<C-R>=g:vimim()<CR>'
        endif
    endfor
endfunction

" ---------------------------------------------------------
function! s:vimim_set_keyboard_list(start_column, keyboard)
" ---------------------------------------------------------
    let s:start_column_before = a:start_column
    if len(s:keyboard_list) < 2
        let s:keyboard_list = [a:keyboard]
    endif
endfunction

" ------------------------------
function! s:vimim_set_seamless()
" ------------------------------
    let s:seamless_positions = getpos(".")
    let s:keyboard_list = []
    return ""
endfunction

" -----------------------------------------------
function! s:vimim_get_seamless(current_positions)
" -----------------------------------------------
    if empty(s:seamless_positions)
    \|| empty(a:current_positions)
        return -1
    endif
    let seamless_bufnum = s:seamless_positions[0]
    let seamless_lnum = s:seamless_positions[1]
    let seamless_off = s:seamless_positions[3]
    if seamless_bufnum != a:current_positions[0]
    \|| seamless_lnum != a:current_positions[1]
    \|| seamless_off != a:current_positions[3]
        let s:seamless_positions = []
        return -1
    endif
    let seamless_column = s:seamless_positions[2]-1
    let start_column = a:current_positions[2]-1
    let len = start_column - seamless_column
    let start_row = a:current_positions[1]
    let current_line = getline(start_row)
    let snip = strpart(current_line, seamless_column, len)
    if empty(len(snip))
        return -1
    endif
    if snip =~# s:uxxxx
        " support OneKey after any cjk
    else
        for char in split(snip, '\zs')
            if char !~# s:valid_key
                return -1
            endif
        endfor
    endif
    let s:start_row_before = seamless_lnum
    let s:smart_enter = 0
    return seamless_column
endfunction

" ============================================= }}}
let s:VimIM += [" ====  OneKey           ==== {{{"]
" =================================================

" ------------------------------
function! s:vimim_onekey_start()
" ------------------------------
    let s:chinese_input_mode = "onekey"
    sil!call s:vimim_backend_initialization_once()
    sil!call s:vimim_frontend_initialization()
    sil!call s:vimim_onekey_pumvisible_capital_on()
    sil!call s:vimim_onekey_pumvisible_hjkl_on()
    sil!call s:vimim_onekey_pumvisible_qwert_on()
    sil!call s:vimim_punctuation_navigation_on()
    sil!call s:vimim_start()
endfunction

" ---------------------
function! <SID>OneKey()
" ---------------------
" (1) <OneKey> => start OneKey as "hit and run"
" (2) <OneKey> => stop  OneKey and print out menu
" -----------------------------------------------
    let onekey = ""
    let byte_before = getline(".")[col(".")-2]
    if empty(byte_before) || byte_before =~ '\s'
        if s:vimim_tab_as_onekey > 0
            let onekey = "\t"
        endif
    else
        if pumvisible()
            if s:pattern_not_found > 0
                let s:pattern_not_found = 0
                let onekey = " "
            elseif len(s:popupmenu_list) > 0
                let onekey  = '\<C-R>=g:vimim_pumvisible_ctrl_e()\<CR>'
                let onekey .= '\<C-R>=g:vimim_pumvisible_dump()\<CR>'
                let onekey .= '\<Esc>'
            endif
        else
            sil!call s:vimim_onekey_start()
            let onekey = s:vimim_get_unicode_menu()
            if empty(onekey)
                let onekey = s:vimim_onekey_action()
            endif
        endif
    endif
    sil!exe 'sil!return "' . onekey . '"'
endfunction

" -------------------------------
function! s:vimim_onekey_action()
" -------------------------------
    let onekey = ""
    let current_line = getline(".")
    let char_before = current_line[col(".")-2]
    let char_before_before = current_line[col(".")-3]
    if char_before_before !~# "[0-9A-z]" && empty(s:ui.has_dot)
        let punctuations = s:punctuations
        call extend(punctuations, s:evils)
        if has_key(punctuations, char_before)
            for char in keys(punctuations)
                if char_before_before ==# char
                    let onekey = " "
                    break
                else
                    continue
                endif
            endfor
            if empty(onekey)
                " transfer English punctuation to Chinese punctuation
                let replacement = punctuations[char_before]
                " play sexy quote in sexy mode
                if char_before == "'"
                    let replacement = <SID>vimim_get_single_quote()
                elseif char_before == '"'
                    let replacement = <SID>vimim_get_double_quote()
                endif
                let onekey = "\<BS>" . replacement
            endif
        endif
    endif
    if len(onekey) < len("<BS>")
        if char_before =~ s:valid_key
        \&& s:seamless_positions != getpos(".")
        \&& s:pattern_not_found < 1
            let onekey = '\<C-R>=g:vimim()\<CR>'
        endif
        let s:smart_enter = 0
        let s:pattern_not_found = 0
    endif
    sil!exe 'sil!return "' . onekey . '"'
endfunction

" -----------------------
function! g:vimim_space()
" -----------------------
" (1) <Space> after English (valid keys) => trigger keycode menu
" (3) <Space> after English punctuation  => Chinese punctuation
" (2) <Space> after omni popup menu      => insert Chinese
" (4) <Space> after Chinese              => stop OneKeyNonStop
" ---------------------------------------------------------------
    let space = " "
    if pumvisible()
        let space = "\<C-Y>"
        let s:has_pumvisible = 1
    elseif s:chinese_input_mode =~ 'static'
        let space = s:vimim_static_action(space)
    elseif s:chinese_input_mode =~ 'onekey'
        let char_before = getline(".")[col(".")-2]
        if char_before !~ s:valid_key
        \&& !has_key(s:punctuations, char_before)
            let space = ""
            call s:vimim_stop()
        else
            let space = s:vimim_onekey_action()
        endif
        let s:has_pumvisible = 0
    endif
    sil!exe 'sil!return "' . space . '"'
endfunction

" --------------------------------------
function! g:vimim_nonstop_after_insert()
" --------------------------------------
    if s:chinese_input_mode =~ 'onekey'
    \&& s:vimim_onekey_nonstop < 1
        call s:vimim_stop()
        return ""
    endif
    let key = ""
    if s:has_pumvisible > 0
        let key = g:vimim()
        if len(s:keyboard_list) > 1
            let s:keyboard_list = [get(s:keyboard_list,1)]
            let s:keyboard_shuangpin = 1
        else
            let s:keyboard_shuangpin = 0
        endif
        call g:vimim_reset_after_insert()
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" ------------------------------------
function! g:vimim_one_key_correction()
" ------------------------------------
    let key = '\<Esc>'
    call g:vimim_reset_after_insert()
    let byte_before = getline(".")[col(".")-2]
    if byte_before =~# s:valid_key
        let s:one_key_correction = 1
        let key = '\<C-X>\<C-U>\<BS>'
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" ----------------------------
function! g:vimim_onekey_esc()
" ----------------------------
    if s:chinese_input_mode =~ 'static'
        sil!call g:vimim_reset_after_insert()
    else
        sil!call s:vimim_stop()
    endif
    return ""
endfunction

" ---------------------------------
function! g:vimim_pumvisible_dump()
" ---------------------------------
    let line = ""
    let one_line_clipboard = ""
    let saved_position = getpos(".")
    for items in s:popupmenu_list
        if has_key(items, "menu")
            let line = printf('%s  %s', items.word, items.menu)
        else
            let line = printf('%s', items.word)
        endif
        put=line
        let one_line_clipboard .= line . "\n"
    endfor
    if has("gui_running") && has("win32")
        let @+ = one_line_clipboard
    endif
    call setpos(".", saved_position)
    sil!call s:vimim_stop()
    return ""
endfunction

" ------------------------------------
function! g:vimim_pumvisible_to_clip()
" ------------------------------------
    let chinese = s:vimim_onekey_popup_word()
    if !empty(chinese)
        if has("gui_running") && has("win32")
            let @+ = chinese
        endif
    endif
    call s:vimim_stop()
    sil!exe "sil!return '\<Esc>'"
endfunction

" -----------------------------------
function! s:vimim_onekey_popup_word()
" -----------------------------------
    if pumvisible()
        return ""
    endif
    let column_start = s:start_column_before
    let column_end = col('.') - 1
    let range = column_end - column_start
    let current_line = getline(".")
    let chinese = strpart(current_line, column_start, range)
    return substitute(chinese,'\w','','g')
endfunction

" --------------------------------------
function! s:vimim_onekey_input(keyboard)
" --------------------------------------
    let results = []
    let keyboard = a:keyboard
    if empty(keyboard) || s:chinese_input_mode !~ 'onekey'
        return []
    endif
    " [filter] do digital filter within cache memory
    if s:has_cjk_file > 0
    \&& len(s:cjk_filter) > 0
    \&& len(s:matched_list) > 0
        let results = s:vimim_cjk_filter_from_cache(keyboard)
        if !empty(results)
            return results
        endif
    endif
    " [eggs] hunt classic easter egg ... vim<C-6>
    let results = s:vimim_easter_chicken(keyboard)
    if !empty(results)
        let s:show_me_not = 1
        return results
    endif
    " [poem] check entry in special directories first
    let results = s:vimim_get_poem(keyboard)
    if !empty(results)
        let s:show_me_not = 1
        return results
    endif
    " [unicode] support direct unicode/gb/big5 input
    let results = s:vimim_get_unicode_list(keyboard)
    if !empty(results)
        let s:keyboard_list = [keyboard]
        return results
    endif
    " [english] english cannot be ignored
    if keyboard =~ '^\l\+'
        sil!call s:vimim_onekey_english(keyboard, 0)
    endif
    " [imode] magic i: (1) English number (2) qwerty shortcut
    if keyboard =~# '^i'
        if keyboard =~ '\d'
            let results = s:vimim_imode_number(keyboard, 'i')
            if !empty(len(results))
                return results
            endif
        elseif s:has_cjk_file > 1 || s:vimim_imode_pinyin > 0
            let dddd = s:vimim_qwertyuiop_1234567890(keyboard[1:])
            if !empty(dddd)
                let keyboard = dddd " iypwqwuww => 60212722
            endif
        endif
    endif
    " [cjk] cjk database works like swiss-army knife
    if s:has_cjk_file > 0
        " try to search pinyin/digit entries
        let keyboard = s:vimim_cjk_sentence_match(keyboard)
        let results = s:vimim_cjk_match(keyboard)
        if keyboard =~ '^\l\d\d\d\d'
        \&& len(results) > 0
        \&& len(s:english_results) > 0
            call extend(s:english_results, results)
        endif
    endif
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  user interface   ==== {{{"]
" =================================================

" ----------------
function! IMName()
" ----------------
" This function is for user-defined 'stl' 'statusline'
    if s:chinese_input_mode =~ 'onekey'
        if pumvisible()
            return s:vimim_statusline()
        endif
    else
        return s:vimim_statusline()
    endif
    return ""
endfunction

" --------------------------------
function! s:vimim_set_statusline()
" --------------------------------
    if s:vimim_custom_statusline < 1
        return
    endif
    set laststatus=2
    if empty(&statusline)
        set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P%{IMName()}
    elseif &statusline =~ 'IMName'
        " nothing, because it is already in the statusline
    elseif &statusline =~ '\V\^%!'
        let &statusline .= '.IMName()'
    else
        let &statusline .= '%{IMName()}'
    endif
endfunction

" ----------------------------
function! s:vimim_statusline()
" ----------------------------
    if empty(s:ui.root) || empty(s:ui.im)
        return ""
    endif
    if has_key(s:im_keycode, s:ui.im)
        let s:ui.statusline = s:backend[s:ui.root][s:ui.im].chinese
    endif
    let datafile = s:backend[s:ui.root][s:ui.im].name
    if s:ui.im =~# 'wubi'
        if datafile =~# 'wubi98'
            let s:ui.statusline .= '98'
        elseif datafile =~# 'wubi2000'
            let newcentury = s:vimim_chinese('newcentury')
            let s:ui.statusline = newcentury . s:ui.statusline
        elseif datafile =~# 'wubijd'
            let jidian = s:vimim_chinese('jidian')
            let s:ui.statusline = jidian . s:ui.statusline
        endif
        return s:vimim_get_chinese_im()
    endif
    if s:vimim_cloud_sogou == 1
        let s:ui.statusline = s:backend.cloud.sogou.chinese
    elseif s:vimim_cloud_sogou == -777
        if !empty(s:vimim_cloud_plugin)
            let __getname = s:backend.cloud.mycloud.directory
            let s:ui.statusline .= s:space . __getname
        endif
    endif
    if !empty(s:vimim_shuangpin)
        let s:ui.statusline .= s:space
        let s:ui.statusline .= s:shuangpin_keycode_chinese.chinese
    endif
    return s:vimim_get_chinese_im()
endfunction

" --------------------------------
function! s:vimim_get_chinese_im()
" --------------------------------
    let input_style = s:vimim_chinese('chinese')
    if s:vimim_chinese_input_mode =~ 'dynamic'
        let input_style .= s:vimim_chinese('dynamic')
    elseif s:vimim_chinese_input_mode =~ 'static'
        let input_style .= s:vimim_chinese('static')
    endif
    if s:chinese_input_mode !~ 'onekey'
        let punctuation = s:vimim_chinese('half_width')
        if s:chinese_punctuation > 0
            let punctuation = s:vimim_chinese('full_width')
        endif
        let s:ui.statusline .= s:space . punctuation
    endif
    let statusline = s:left . s:ui.statusline . s:right
    let statusline .= "VimIM"
    return input_style . statusline
endfunction

" ------------------------------------
function! s:vimim_123456789_label_on()
" ------------------------------------
    if s:vimim_custom_label < 1
        return
    endif
    let labels = range(1,9)
    if s:chinese_input_mode =~ 'onekey'
        let abcd_list = split(s:abcd, '\zs')
        let labels += abcd_list
        if s:has_cjk_file > 0
            let labels = abcd_list
        endif
        call remove(labels, "'")
    else
        for _ in abcd_list
            sil!exe 'iunmap '. _
        endfor
    endif
    for _ in labels
        sil!exe'inoremap <silent>  '._.'
        \  <C-R>=g:vimim_123456789_label("'._.'")<CR>'
        \.'<C-R>=g:vimim_nonstop_after_insert()<CR>'
    endfor
endfunction

" ----------------------------------
function! g:vimim_123456789_label(n)
" ----------------------------------
    let label = a:n
    if pumvisible()
        let n = match(s:abcd, label)
        if label =~ '\d'
            let n = label - 1
        endif
        let down = repeat("\<Down>", n)
        let yes = "\<C-Y>"
        let s:has_pumvisible = 1
        let label = down . yes
    endif
    sil!exe 'sil!return "' . label . '"'
endfunction

" --------------------------------------
function! s:vimim_ctrl_e_ctrl_x_ctrl_u()
" --------------------------------------
    return '\<C-E>\<C-R>=g:vimim()\<CR>'
endfunction

" --------------------------------
function! s:vimim_menu_search(key)
" --------------------------------
    let slash = ""
    if pumvisible()
        let slash  = '\<C-R>=g:vimim_space()\<CR>'
        let slash .= '\<C-R>=g:vimim_search_pumvisible()\<CR>'
        let slash .= a:key . '\<CR>'
    endif
    sil!exe 'sil!return "' . slash . '"'
endfunction

" -----------------------------------
function! s:vimim_square_bracket(key)
" -----------------------------------
    let bracket = a:key
    if pumvisible()
        let i = -1
        let left = ""
        let right = ""
        if bracket == "]"
            let i = 0
            let left = "\<Left>"
            let right = "\<Right>"
        endif
        let backspace = '\<C-R>=g:vimim_bracket_backspace('.i.')\<CR>'
        let yes = "\<C-Y>"
        let bracket = yes . left . backspace . right
    endif
    sil!exe 'sil!return "' . bracket . '"'
endfunction

" -----------------------------------------
function! g:vimim_bracket_backspace(offset)
" -----------------------------------------
    let column_end = col('.')-1
    let column_start = s:start_column_before
    let range = column_end - column_start
    let repeat_times = range/s:multibyte
    let repeat_times += a:offset
    let row_end = line('.')
    let row_start = s:start_row_before
    let delete_char = ""
    if repeat_times > 0 && row_end == row_start
        let delete_char = repeat("\<BS>", repeat_times)
    endif
    if repeat_times < 1
        let current_line = getline(".")
        let chinese = strpart(current_line, column_start, s:multibyte)
        let delete_char = chinese
        if empty(a:offset)
            let chinese = s:left . chinese . s:right
            let delete_char = "\<Right>\<BS>" . chinese . "\<Left>"
        endif
    endif
    return delete_char
endfunction

" --------------------------------
function! <SID>vimim_smart_enter()
" --------------------------------
" (1) single <Enter> ==> Seamless
" (2) double <Enter> ==> <Space>
" (3) triple <Enter> ==> <Enter>
" --------------------------------
    let key = ""
    let enter = "\<CR>"
    let byte_before = getline(".")[col(".")-2]
    if byte_before =~ '\S'
        let s:smart_enter += 1
    else
        let key = enter
    endif
    if s:smart_enter == 1
        " the first <Enter> does seamless
        let s:pattern_not_found = 0
        call s:vimim_set_seamless()
    else
        if s:smart_enter == 2
            let key = " "   " the 2nd <Enter> becomes <Space>
        else
            let key = enter " <Enter> is <Enter>
        endif
        let s:smart_enter = 0
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" -----------------------------------
function! g:vimim_pumvisible_ctrl_y()
" -----------------------------------
    let key = ""
    if pumvisible()
        let key = "\<C-Y>"
        let s:has_pumvisible = 1
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" -----------------------------------
function! g:vimim_pumvisible_ctrl_e()
" -----------------------------------
    let key = ""
    if pumvisible()
        let key = "\<C-E>"
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" --------------------------------------
function! g:vimim_pumvisible_ctrl_e_on()
" --------------------------------------
    if s:chinese_input_mode =~ 'dynamic'
        let s:pumvisible_ctrl_e = 1
    endif
    return g:vimim_pumvisible_ctrl_e()
endfunction

" ---------------------------
function! g:vimim_backspace()
" ---------------------------
    call s:vimim_super_reset()
    let s:pattern_not_found = 0
    let key = '\<BS>'
    if s:pumvisible_ctrl_e > 0
        let s:pumvisible_ctrl_e = 0
        let key .= '\<C-R>=g:vimim()\<CR>'
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" --------------------------------------------
function! s:vimim_popupmenu_list(matched_list)
" --------------------------------------------
    let lines = a:matched_list
    if empty(lines)
        return []
    else
        let s:matched_list = copy(lines)
    endif
    if s:hjkl_pageup_pagedown > 0
        let lines = s:vimim_pageup_pagedown(lines)
    endif
    let keyboard = join(s:keyboard_list,"")
    if s:hjkl_n > 0 && s:hjkl_n%2 > 0
        if s:show_me_not > 0
            let lines = reverse(copy(lines))
        elseif s:ui.im == 'pinyin'
            let keyboard = join(split(join(s:keyboard_list,""),"'"),"")
        endif
    endif
    let keyboard_head = get(s:keyboard_list,0)
    let label = 1
    let extra_text = ""
    let popupmenu_list = []
    let first_in_list = get(a:matched_list,0)
    for chinese in lines
        if first_in_list =~ '\s' && s:show_me_not < 1
            let pairs = split(chinese)
            if len(pairs) < 2
                continue
            endif
            let keyboard_head = get(pairs, 0)
            let chinese = get(pairs, 1)
        endif
        if s:hjkl_x % 2 > 0 && s:has_cjk_file > 0
            let chinese = s:vimim_get_traditional_chinese(chinese)
        endif
        if s:hjkl_h % 2 > 0 && s:show_me_not < 1
            let ddddd = char2nr(chinese)
            let extra_text = s:vimim_cjk_property_display(ddddd)
        endif
        if empty(s:vimim_cloud_plugin)
            if !empty(keyboard) && s:show_me_not < 1
                let keyboard_head_length = len(keyboard_head)
                if empty(s:ui.has_dot) && keyboard =~ "['.]"
                    " for vimim classic demo: i.have.a.dream
                    let keyboard_head_length += 1
                endif
                let chinese .= strpart(keyboard, keyboard_head_length)
            endif
        else
            let extra_text = get(split(keyboard_head,"_"),0)
        endif
        if empty(chinese)
            let chinese = s:space
        endif
        let complete_items = {}
        if s:vimim_custom_label > 0
            let labeling = s:vimim_get_labeling(label, keyboard)
            if !empty(labeling)
                let complete_items["abbr"] = labeling . chinese
            endif
            let label += 1
        endif
        if !empty(extra_text)
            let complete_items["menu"] = extra_text
        endif
        let complete_items["word"] = chinese
        let complete_items["dup"] = 1
        call add(popupmenu_list, complete_items)
    endfor
    if s:chinese_input_mode =~ 'onekey'
        let s:popupmenu_list = copy(popupmenu_list)
    endif
    return popupmenu_list
endfunction

" ---------------------------------------------
function! s:vimim_get_labeling(label, keyboard)
" ---------------------------------------------
    let labeling = a:label
    let fmt = '%2s'
    if s:chinese_input_mode =~ 'onekey'
        if s:show_me_not > 0
            let fmt = '%02s'
            if s:hjkl_h % 2 < 1
                let labeling = ""
            endif
        elseif a:label < &pumheight+1
            let label2 = s:abcd[a:label-1]
            if a:label < 2
                let label2 = "_"
            endif
            let labeling .= label2
            if s:has_cjk_file > 0
                let labeling = label2
            endif
        endif
        if s:hjkl_l > 0 && &pumheight < 1
            let fmt = '%02s'
        endif
    endif
    if !empty(labeling)
        let labeling = printf(fmt, labeling) . "\t"
    endif
    return labeling
endfunction

" ---------------------------------------------
function! s:vimim_pageup_pagedown(matched_list)
" ---------------------------------------------
    let matched_list = a:matched_list
    let length = len(matched_list)
    if s:vimim_custom_label < 1 || length <= &pumheight
        return matched_list
    endif
    let page = s:hjkl_pageup_pagedown * &pumheight
    if page < 0
        " no more PageUp after the first page
        let s:hjkl_pageup_pagedown += 1
        let first_page = &pumheight - 1
        let matched_list = matched_list[0 : first_page]
    elseif page >= length
        " no more PageDown after the last page
        let s:hjkl_pageup_pagedown -= 1
        let last_page = length / &pumheight
        if empty(length % &pumheight)
            let last_page -= 1
        endif
        let last_page = last_page * &pumheight
        let matched_list = matched_list[last_page : -1]
    else
        let matched_list = matched_list[page :]
    endif
    return matched_list
endfunction

" ============================================= }}}
let s:VimIM += [" ====  hjkl             ==== {{{"]
" =================================================

" ----------------------------------
function! s:vimim_get_poem(keyboard)
" ----------------------------------
    let lines = []
    let dirs = [s:path, s:vimim_poem_directory]
    for dir in dirs
        let lines = s:vimim_get_from_directory(a:keyboard, dir)
        if empty(lines)
            continue
        else
            break
        endif
    endfor
    if empty(lines)
        return []
    else
        call add(lines,'')
        call insert(lines,'')
    endif
    if s:hjkl_m > 0 && s:hjkl_m%2 > 0
        let lines = s:vimim_hjkl_rotation(copy(lines))
    endif
    return lines
endfunction

" -------------------------------------------
function! s:vimim_hjkl_rotation(matched_list)
" -------------------------------------------
    let lines = a:matched_list
    let max = max(map(copy(lines), 'strlen(v:val)')) + 1
    let results = []
    for line in lines
        if line =~ '\w'
            return lines
        endif
        let spaces = ''
        let gap = (max-len(line))/s:multibyte
        if gap > 0
            for i in range(gap)
                let spaces .= s:space
            endfor
        endif
        let line .= spaces
        call add(results, line)
    endfor
    let rotations = ['']
    for i in range(max/s:multibyte)
        let column = ''
        for line in reverse(copy(results))
            let lines = split(line,'\zs')
            let line = get(lines, i)
            if !empty(line)
                let column .= line
            endif
        endfor
        call add(rotations, column)
    endfor
    return rotations
endfunction

" ----------------------------------------------
function! <SID>vimim_onekey_pumvisible_hjkl(key)
" ----------------------------------------------
    let hjkl = a:key
    if pumvisible()
        if a:key == 'j'
            let hjkl  = '\<Down>'
        elseif a:key == 'k'
            let hjkl  = '\<Up>'
        elseif a:key =~ "[<>]"
            let hjkl  = '\<C-Y>'
            let hjkl .= s:punctuations[nr2char(char2nr(a:key)-16)]
            let hjkl .= '\<C-R>=g:vimim_space()\<CR>'
        else
            if a:key == 'h'
                let s:hjkl_h += 1
            elseif a:key == 'l'
                let pumheight = &pumheight
                let &pumheight = s:hjkl_l
                let s:hjkl_l = pumheight
            elseif a:key == 's'
                call g:vimim_reset_after_insert()
            elseif a:key == 'x'
                let s:hjkl_x += 1
            elseif a:key == 'm'
                let s:hjkl_m += 1
                let s:keyboard_list = []
            elseif a:key == 'n'
                let s:hjkl_n += 1
                let s:keyboard_list = []
            endif
            let hjkl = s:vimim_ctrl_e_ctrl_x_ctrl_u()
        endif
    endif
    sil!exe 'sil!return "' . hjkl . '"'
endfunction

" -----------------------------------------------
function! <SID>vimim_punctuations_navigation(key)
" -----------------------------------------------
    let hjkl = a:key
    if pumvisible()
        if a:key =~ ";"
            let hjkl  = '\<C-R>=g:vimim_space()\<CR>'
            let hjkl .= '\<C-R>=g:vimim_pumvisible_to_clip()\<CR>'
        elseif a:key =~ "[][]"
            let hjkl  = s:vimim_square_bracket(a:key)
        elseif a:key =~ "[/?]"
            let hjkl  = s:vimim_menu_search(a:key)
        elseif a:key =~ "[-,]"
            if s:hjkl_l > 0 && &pumheight < 1
                let hjkl = '\<PageUp>'
            else
                let s:hjkl_pageup_pagedown -= 1
                let hjkl  = s:vimim_ctrl_e_ctrl_x_ctrl_u()
            endif
        elseif a:key =~ "[=.]"
            if s:hjkl_l > 0 && &pumheight < 1
                let hjkl = '\<PageDown>'
            else
                let s:hjkl_pageup_pagedown += 1
                let hjkl  = s:vimim_ctrl_e_ctrl_x_ctrl_u()
            endif
        endif
    endif
    sil!exe 'sil!return "' . hjkl . '"'
endfunction

" ----------------------------------------------
function! s:vimim_onekey_pumvisible_capital_on()
" ----------------------------------------------
    for _ in s:AZ_list
        sil!exe 'inoremap <silent> <expr> '._.'
        \ <SID>vimim_onkey_pumvisible_capital("'._.'")'
    endfor
endfunction

" ------------------------------------------------
function! <SID>vimim_onkey_pumvisible_capital(key)
" ------------------------------------------------
    let hjkl = a:key
    if pumvisible()
        let hjkl  = '\<C-R>=g:vimim_pumvisible_ctrl_e()\<CR>'
        let hjkl .= tolower(a:key)
        let hjkl .= '\<C-R>=g:vimim()\<CR>'
    endif
    sil!exe 'sil!return "' . hjkl . '"'
endfunction

" -------------------------------------------
function! s:vimim_onekey_pumvisible_hjkl_on()
" -------------------------------------------
    let hjkl = 'jk<>hlmnsx'
    for _ in split(hjkl, '\zs')
        sil!exe 'inoremap <silent> <expr> '._.'
        \ <SID>vimim_onekey_pumvisible_hjkl("'._.'")'
    endfor
endfunction

" --------------------------------------------
function! s:vimim_onekey_pumvisible_qwert_on()
" --------------------------------------------
    let labels = s:qwerty
    if s:has_cjk_file > 0
        let labels += range(10)
    endif
    for _ in labels
        sil!exe'inoremap <silent>  '._.'
        \  <C-R>=<SID>vimim_onekey_pumvisible_qwerty("'._.'")<CR>'
    endfor
endfunction

" ----------------------------------------------
function! <SID>vimim_onekey_pumvisible_qwerty(n)
" ----------------------------------------------
    let label = a:n
    if pumvisible()
        if s:has_cjk_file > 0
            if label =~ '\l'
                let label = match(s:qwerty, a:n)
            endif
            if empty(len(s:cjk_filter))
                let s:cjk_filter = label
            else
                let s:cjk_filter .= label
            endif
            let label = s:vimim_ctrl_e_ctrl_x_ctrl_u()
        else
            let label = g:vimim_pumvisible_ctrl_y()
        endif
    endif
    sil!exe 'sil!return "' . label . '"'
endfunction

" ============================================= }}}
let s:VimIM += [" ====  cjk number       ==== {{{"]
" =================================================

" ----------------------------------------
function! s:vimim_dictionary_quantifiers()
" ----------------------------------------
    if s:vimim_imode_pinyin < 1
        return
    endif
    let s:quantifiers['1'] = '一壹甲①⒈⑴'
    let s:quantifiers['2'] = '二贰乙②⒉⑵'
    let s:quantifiers['3'] = '三叁丙③⒊⑶'
    let s:quantifiers['4'] = '四肆丁④⒋⑷'
    let s:quantifiers['5'] = '五伍戊⑤⒌⑸'
    let s:quantifiers['6'] = '六陆己⑥⒍⑹'
    let s:quantifiers['7'] = '七柒庚⑦⒎⑺'
    let s:quantifiers['8'] = '八捌辛⑧⒏⑻'
    let s:quantifiers['9'] = '九玖壬⑨⒐⑼'
    let s:quantifiers['0'] = '〇零癸⑩⒑⑽十拾'
    let s:quantifiers['a'] = '秒'
    let s:quantifiers['b'] = '步百佰把包杯本笔部班'
    let s:quantifiers['c'] = '厘次餐场串处床'
    let s:quantifiers['d'] = '第度点袋道滴碟日顶栋堆对朵堵顿'
    let s:quantifiers['e'] = '亿'
    let s:quantifiers['f'] = '分份发封付副幅峰方服'
    let s:quantifiers['g'] = '个根股管'
    let s:quantifiers['h'] = '时毫行盒壶户回'
    let s:quantifiers['i'] = '毫'
    let s:quantifiers['j'] = '斤家具架间件节剂具捲卷茎记'
    let s:quantifiers['k'] = '克口块棵颗捆孔'
    let s:quantifiers['l'] = '里粒类辆列轮厘升领缕'
    let s:quantifiers['m'] = '月米名枚面门'
    let s:quantifiers['n'] = '年'
    let s:quantifiers['o'] = '度'
    let s:quantifiers['p'] = '磅盆瓶排盘盆匹片篇撇喷'
    let s:quantifiers['q'] = '千仟群'
    let s:quantifiers['r'] = '日'
    let s:quantifiers['s'] = '十拾时升艘扇首双所束手秒'
    let s:quantifiers['t'] = '吨条头通堂趟台套桶筒贴'
    let s:quantifiers['u'] = '微'
    let s:quantifiers['w'] = '万位味碗窝'
    let s:quantifiers['x'] = '升席些项'
    let s:quantifiers['y'] = '年亿叶月'
    let s:quantifiers['z'] = '种只张株支枝盏座阵桩尊则站幢宗兆'
endfunction

" ----------------------------------------------
function! s:vimim_imode_number(keyboard, prefix)
" ----------------------------------------------
    " usage: i88<C-6> ii88<C-6> i1g<C-6> isw8ql
    if empty(s:vimim_imode_pinyin)
        return []
    endif
    let keyboard = a:keyboard
    if keyboard[0:1] ==# 'ii'
        let keyboard = 'I' . strpart(keyboard,2)
    endif
    let ii_keyboard = keyboard
    let keyboard = strpart(keyboard,1)
    if keyboard !~ '^\d\+' && keyboard !~# '^[ds]'
    \&& len(substitute(keyboard,'\d','','')) > 1
        return []
    endif
    let digit_alpha = keyboard
    if keyboard =~# '^\d*\l\{1}$'
        let digit_alpha = keyboard[:-2]
    endif
    let keyboards = split(digit_alpha, '\ze')
    let i = ii_keyboard[:0]
    let number = ""
    for char in keyboards
        if has_key(s:quantifiers, char)
            let quantifiers = split(s:quantifiers[char], '\zs')
            if i ==# 'i'
                let char = get(quantifiers, 0)
            elseif i ==# 'I'
                let char = get(quantifiers, 1)
            endif
        endif
        let number .= char
    endfor
    if empty(number)
        return []
    endif
    let numbers = [number]
    let last_char = keyboard[-1:]
    if !empty(last_char) && has_key(s:quantifiers, last_char)
        let quantifier = s:quantifiers[last_char]
        let quantifiers = split(quantifier, '\zs')
        if keyboard =~# '^[ds]\=\d*\l\{1}$'
            if keyboard =~# '^[ds]'
                let number = strpart(number,0,len(number)-s:multibyte)
            endif
            let numbers = map(copy(quantifiers), 'number . v:val')
        elseif keyboard =~# '^\d*$' && len(keyboards)<2 && i ==# 'i'
            let numbers = quantifiers
        endif
    endif
    return numbers
endfunction

" ============================================= }}}
let s:VimIM += [" ====  cjk punctuation  ==== {{{"]
" =================================================

" ----------------------------------------
function! s:vimim_dictionary_punctuation()
" ----------------------------------------
    let s:punctuations = {}
    let s:punctuations['@'] = s:space
    let s:punctuations['+'] = s:plus
    let s:punctuations[':'] = s:colon
    let s:punctuations['['] = s:left
    let s:punctuations[']'] = s:right
    let s:punctuations['#'] = '＃'
    let s:punctuations['&'] = '＆'
    let s:punctuations['%'] = '％'
    let s:punctuations['$'] = '￥'
    let s:punctuations['!'] = '！'
    let s:punctuations['~'] = '～'
    let s:punctuations['('] = '（'
    let s:punctuations[')'] = '）'
    let s:punctuations['{'] = '〖'
    let s:punctuations['}'] = '〗'
    let s:punctuations['^'] = '……'
    let s:punctuations['_'] = '——'
    let s:punctuations['<'] = '《'
    let s:punctuations['>'] = '》'
    let s:punctuations['-'] = '－'
    let s:punctuations['='] = '＝'
    let s:punctuations[';'] = '；'
    let s:punctuations[','] = '，'
    let s:punctuations['.'] = '。'
    let s:punctuations['?'] = '？'
    let s:punctuations['*'] = '﹡'
    " ------------------------------------
    let s:evils = {}
    if empty(s:vimim_backslash_close_pinyin)
        let s:evils['\'] = '、'
    endif
    if empty(s:vimim_latex_suite)
        let s:evils["'"] = '‘’'
        let s:evils['"'] = '“”'
    endif
endfunction

" -------------------------------------------------
function! s:vimim_initialize_frontend_punctuation()
" -------------------------------------------------
    for char in s:valid_keys
        if has_key(s:punctuations, char)
            if !empty(s:vimim_cloud_plugin) || s:ui.has_dot == 1
                unlet s:punctuations[char]
            elseif char !~# "[*.']"
                unlet s:punctuations[char]
            endif
        endif
    endfor
endfunction

" ---------------------------------------
function! <SID>vimim_toggle_punctuation()
" ---------------------------------------
    let s:chinese_punctuation = (s:chinese_punctuation+1)%2
    call s:vimim_set_statusline()
    call s:vimim_punctuation_mapping_on()
    return  ""
endfunction

" ----------------------------------------
function! s:vimim_punctuation_mapping_on()
" ----------------------------------------
    if s:vimim_chinese_punctuation < 0
        return ""
    else
        call s:vimim_evil_punctuation_mapping_on()
    endif
    for key in keys(s:punctuations)
        sil!exe 'inoremap <silent> '. key .'
        \    <C-R>=<SID>vimim_punctuation_mapping("'. key .'")<CR>'
        \ . '<C-R>=g:vimim_reset_after_insert()<CR>'
    endfor
    sil!call s:vimim_punctuation_navigation_on()
    return ""
endfunction

" ---------------------------------------------
function! s:vimim_evil_punctuation_mapping_on()
" ---------------------------------------------
    if s:chinese_punctuation > 0
        if empty(s:vimim_latex_suite)
            inoremap ' <C-R>=<SID>vimim_get_single_quote()<CR>
            inoremap " <C-R>=<SID>vimim_get_double_quote()<CR>
        endif
        if empty(s:vimim_backslash_close_pinyin)
            sil!exe 'inoremap <Bslash> ' . s:evils['\']
        endif
    else
        for _ in keys(s:evils)
            sil!exe 'iunmap '. _
        endfor
    endif
endfunction

" -------------------------------------
function! <SID>vimim_get_single_quote()
" -------------------------------------
    let key = "'"
    if !has_key(s:evils, key)
        return ""
    endif
    let pair = s:evils[key]
    let pairs = split(pair,'\zs')
    let s:smart_single_quotes += 1
    return get(pairs, s:smart_single_quotes % 2)
endfunction

" -------------------------------------
function! <SID>vimim_get_double_quote()
" -------------------------------------
    let key = '"'
    if !has_key(s:evils, key)
        return ""
    endif
    let pair = s:evils[key]
    let pairs = split(pair,'\zs')
    let s:smart_double_quotes += 1
    return get(pairs, s:smart_double_quotes % 2)
endfunction

" -------------------------------------------
function! <SID>vimim_punctuation_mapping(key)
" -------------------------------------------
    let key = a:key
    let value = key
    if s:chinese_punctuation > 0
        let byte_before = getline(".")[col(".")-2]
        if byte_before !~ '\w' || pumvisible()
            if has_key(s:punctuations, key)
                let value = s:punctuations[key]
            else
                let value = a:key
            endif
        endif
    endif
    if pumvisible()
        let value = "\<C-Y>" . value
        let s:has_pumvisible = 1
    endif
    sil!exe 'sil!return "' . value . '"'
endfunction

" -------------------------------------------
function! s:vimim_punctuation_navigation_on()
" -------------------------------------------
    if s:vimim_chinese_punctuation < 0
        return ""
    endif
    let punctuation = "[]-="
    if s:chinese_input_mode =~ 'onekey'
        let punctuation .= ".,/?;"
    endif
    let punctuations = split(punctuation,'\zs')
    for char in s:valid_keys
        let i = index(punctuations, char)
        if i > -1 && char != "."
            unlet punctuations[i]
        endif
    endfor
    for _ in punctuations
        sil!exe 'inoremap <silent> <expr> '._.'
        \ <SID>vimim_punctuations_navigation("'._.'")'
    endfor
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input english    ==== {{{"]
" =================================================

" -----------------------------------
function! s:vimim_scan_english_file()
" -----------------------------------
    let s:has_english_file = 0
    let s:english_file = 0
    let s:english_lines = []
    let s:english_results = []
    let datafile = "vimim.txt"
    let datafile = s:vimim_check_filereadable(datafile)
    if s:has_cjk_file > 1 || s:ui.im =~ 'pinyin'
        if !empty(datafile)
            let s:english_file = datafile
            let s:has_english_file = 1
        endif
    endif
endfunction

" -------------------------------------------
function! s:vimim_check_filereadable(default)
" -------------------------------------------
    let default = a:default
    let datafile = s:vimim_poem_directory . default
    if filereadable(datafile)
        let default = 0
    else
        let datafile = s:path . default
        if filereadable(datafile)
            let default = 0
        endif
    endif
    if empty(default)
        return datafile
    endif
    return 0
endfunction

" -----------------------------------------------
function! s:vimim_onekey_english(keyboard, order)
" -----------------------------------------------
    let results = []
    if s:has_cjk_file > 0 && s:ui.im == 'pinyin'
        " select english from vimim.cjk.txt
        let grep_english = '\s' . a:keyboard . '\s'
        let results = s:vimim_cjk_grep_results(grep_english)
        if len(results) > 0
            let filter = "strpart(".'v:val'.", 0, s:multibyte)"
            call map(results, filter)
            let s:english_results = copy(results)
        endif
    endif
    if s:has_english_file > 0
        " select english from vimim.txt
        if empty(s:english_lines)
            let s:english_lines = s:vimim_readfile(s:english_file)
        endif
        let grep_english = '^' . a:keyboard . '\>'
        let matched = match(s:english_lines, grep_english)
        if matched < 0
            " no more scan for: dream 梦想
        else
            let line = s:english_lines[matched]
            let results = split(line)[1:]
            if empty(a:order)
                call extend(s:english_results, results)
            else
                call extend(s:english_results, results, 0)
            endif
        endif
    endif
endfunction

" ----------------------------------
function! s:vimim_readfile(datafile)
" ----------------------------------
    if !filereadable(a:datafile)
        return []
    endif
    let lines = readfile(a:datafile)
    if s:localization > 0
        let  results = []
        for line in lines
            let line = s:vimim_i18n_read(line)
            call add(results, line)
        endfor
        let lines = results
    endif
    return lines
endfunction

" -------------------------------
function! s:vimim_i18n_read(line)
" -------------------------------
    let line = a:line
    if s:localization == 1
        let line = iconv(line, "chinese", "utf-8")
    elseif s:localization == 2
        let line = iconv(line, "utf-8", &enc)
    endif
    return line
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input pinyin     ==== {{{"]
" =================================================

" ----------------------------------------
function! s:vimim_add_apostrophe(keyboard)
" ----------------------------------------
    let keyboard = a:keyboard
    if keyboard =~ "[']"
    \&& keyboard[0:0] != "'"
    \&& keyboard[-1:-1] != "'"
        let msg = "valid apostrophe is typed"
    else
        let keyboard = s:vimim_quanpin_transform(keyboard)
    endif
    return keyboard
endfunction

" ------------------------------------------------
function! s:vimim_get_pinyin_from_pinyin(keyboard)
" ------------------------------------------------
    let keyboard = s:vimim_quanpin_transform(a:keyboard)
    let results = split(keyboard, "'")
    if len(results) > 1
        return results
    endif
    return []
endfunction

" ---------------------------------------
function! s:vimim_toggle_pinyin(keyboard)
" ---------------------------------------
    let keyboard = a:keyboard
    if s:hjkl_n < 1
        return keyboard
    elseif s:hjkl_n % 2 > 0
        " set pin'yin: woyouyigemeng => wo.you.yi.ge.meng
        let keyboard = s:vimim_quanpin_transform(keyboard)
    elseif len(s:keyboard_list) > 0 && get(s:keyboard_list,0) =~ "'"
        " reset pinyin: wo.you.yi.ge.meng => woyouyigemeng
        let keyboard = join(split(join(s:keyboard_list,""),"'"),"")
    endif
    return keyboard
endfunction

" -------------------------------------
function! s:vimim_toggle_cjjp(keyboard)
" -------------------------------------
    let keyboard = a:keyboard
    if s:hjkl_m < 1
        return keyboard
    elseif s:hjkl_m % 2 > 0
        " set cjjp:   wyygm => w'y'y'g'm
        let keyboard = join(split(keyboard,'\zs'),"'")
    elseif len(s:keyboard_list) > 0 && get(s:keyboard_list,0) =~ "'"
        " reset cjjp: w'y'y'g'm => wyygm
        let keyboard = join(split(join(s:keyboard_list,""),"'"),"")
    endif
    return keyboard
endfunction

" -------------------------------------------
function! s:vimim_quanpin_transform(keyboard)
" -------------------------------------------
    let qptable = s:quanpin_table
    if empty(qptable)
        return ""
    else
        let msg = "start pinyin breakdown: pinyin=>pin'yin"
    endif
    let item = a:keyboard
    let pinyinstr = ""
    let index = 0
    let lenitem = len(item)
    while index < lenitem
        if item[index] !~ "[a-z]"
            let index += 1
            continue
        endif
        for i in range(6,1,-1)
            let tmp = item[index : ]
            if len(tmp) < i
                continue
            endif
            let end = index+i
            let matchstr = item[index : end-1]
            if has_key(qptable, matchstr)
                let tempstr = item[end-1 : end]
                " special case for fanguo, which should be fan'guo
                if tempstr == "gu" || tempstr == "nu" || tempstr == "ni"
                    if has_key(qptable, matchstr[:-2])
                        let i -= 1
                        let matchstr = matchstr[:-2]
                    endif
                endif
                " follow ibus' rule
                let tempstr2 = item[end-2 : end+1]
                let tempstr3 = item[end-1 : end+1]
                let tempstr4 = item[end-1 : end+2]
                if (tempstr == "ge" && tempstr3 != "ger")
                    \ || (tempstr == "ne" && tempstr3 != "ner")
                    \ || (tempstr4 == "gong" || tempstr3 == "gou")
                    \ || (tempstr4 == "nong" || tempstr3 == "nou")
                    \ || (tempstr == "ga" || tempstr == "na")
                    \ || tempstr2 == "ier"
                    if has_key(qptable, matchstr[:-2])
                        let i -= 1
                        let matchstr = matchstr[:-2]
                    endif
                endif
                let pinyinstr .= "'" . qptable[matchstr]
                let index += i
                break
            elseif i == 1
                let pinyinstr .= "'" . item[index]
                let index += 1
                break
            else
                continue
            endif
        endfor
    endwhile
    if pinyinstr[0] == "'"
        return pinyinstr[1:]
    else
        return pinyinstr
    endif
endfunction

" --------------------------------------
function! s:vimim_create_quanpin_table()
" --------------------------------------
    let pinyin_list = s:vimim_get_pinyin_table()
    let table = {}
    for key in pinyin_list
        if key[0] == "'"
            let table[key[1:]] = key[1:]
        else
            let table[key] = key
        endif
    endfor
    for shengmu in ["b", "p", "m", "f", "d", "t", "l", "n", "g", "k", "h",
        \"j", "q", "x", "zh", "ch", "sh", "r", "z", "c", "s", "y", "w"]
        let table[shengmu] = shengmu
    endfor
    return table
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input shuangpin  ==== {{{"]
" =================================================

" --------------------------------------
function! s:vimim_initialize_shuangpin()
" --------------------------------------
    if empty(s:vimim_shuangpin) || !empty(s:shuangpin_table)
        return
    endif
    let s:vimim_imode_pinyin = 0
    let rules = s:vimim_shuangpin_generic()
    let chinese = ""
    let shuangpin = s:vimim_chinese('shuangpin')
    let keycode = "[0-9a-z'.]"
    if s:vimim_shuangpin == 'abc'
        let rules = s:vimim_shuangpin_abc(rules)
        let s:vimim_imode_pinyin = 1
        let chinese = s:vimim_chinese('abc')
        let shuangpin = ""
    elseif s:vimim_shuangpin == 'ms'
        let rules = s:vimim_shuangpin_ms(rules)
        let chinese = s:vimim_chinese('ms')
        let keycode = "[0-9a-z'.;]"
    elseif s:vimim_shuangpin == 'nature'
        let rules = s:vimim_shuangpin_nature(rules)
        let chinese = s:vimim_chinese('nature')
    elseif s:vimim_shuangpin == 'plusplus'
        let rules = s:vimim_shuangpin_plusplus(rules)
        let chinese = s:vimim_chinese('plusplus')
    elseif s:vimim_shuangpin == 'purple'
        let rules = s:vimim_shuangpin_purple(rules)
        let chinese = s:vimim_chinese('purple')
        let keycode = "[0-9a-z'.;]"
    elseif s:vimim_shuangpin == 'flypy'
        let rules = s:vimim_shuangpin_flypy(rules)
        let chinese = s:vimim_chinese('flypy')
    endif
    let s:shuangpin_table = s:vimim_create_shuangpin_table(rules)
    let s:shuangpin_keycode_chinese.chinese = chinese . shuangpin
    let s:shuangpin_keycode_chinese.keycode = keycode
endfunction

" ---------------------------------------------------
function! s:vimim_get_pinyin_from_shuangpin(keyboard)
" ---------------------------------------------------
    let keyboard = a:keyboard
    let keyboard2 = s:vimim_shuangpin_transform(keyboard)
    if keyboard2 != keyboard
        let keyboard = copy(keyboard2)
        let s:keyboard_shuangpin = 1
    endif
    return keyboard
endfunction

" ---------------------------------------------
function! s:vimim_shuangpin_transform(keyboard)
" ---------------------------------------------
    let keyboard = a:keyboard
    let size = strlen(keyboard)
    let ptr = 0
    let output = ""
    let bchar = ""    " work-around for sogou
    while ptr < size
        if keyboard[ptr] !~ "[a-z;]"
            " bypass all non-characters, i.e. 0-9 and A-Z are bypassed
            let output .= keyboard[ptr]
            let ptr += 1
        else
            if keyboard[ptr+1] =~ "[a-z;]"
                let sp1 = keyboard[ptr].keyboard[ptr+1]
            else
                let sp1 = keyboard[ptr]
            endif
            if has_key(s:shuangpin_table, sp1)
                " the last odd shuangpin code are output as only shengmu
                let output .= bchar . s:shuangpin_table[sp1]
            else
                " invalid shuangpin code are preserved
                let output .= sp1
            endif
            let ptr += strlen(sp1)
        endif
    endwhile
    if output[0] == "'"
        return output[1:]
    else
        return output
    endif
endfunction

"-----------------------------------
function! s:vimim_get_pinyin_table()
"-----------------------------------
" List of all valid pinyin.  Note: Don't change this function!
return [
\"'a", "'ai", "'an", "'ang", "'ao", 'ba', 'bai', 'ban', 'bang', 'bao',
\'bei', 'ben', 'beng', 'bi', 'bian', 'biao', 'bie', 'bin', 'bing', 'bo',
\'bu', 'ca', 'cai', 'can', 'cang', 'cao', 'ce', 'cen', 'ceng', 'cha',
\'chai', 'chan', 'chang', 'chao', 'che', 'chen', 'cheng', 'chi', 'chong',
\'chou', 'chu', 'chua', 'chuai', 'chuan', 'chuang', 'chui', 'chun', 'chuo',
\'ci', 'cong', 'cou', 'cu', 'cuan', 'cui', 'cun', 'cuo', 'da', 'dai',
\'dan', 'dang', 'dao', 'de', 'dei', 'deng', 'di', 'dia', 'dian', 'diao',
\'die', 'ding', 'diu', 'dong', 'dou', 'du', 'duan', 'dui', 'dun', 'duo',
\"'e", "'ei", "'en", "'er", 'fa', 'fan', 'fang', 'fe', 'fei', 'fen',
\'feng', 'fiao', 'fo', 'fou', 'fu', 'ga', 'gai', 'gan', 'gang', 'gao',
\'ge', 'gei', 'gen', 'geng', 'gong', 'gou', 'gu', 'gua', 'guai', 'guan',
\'guang', 'gui', 'gun', 'guo', 'ha', 'hai', 'han', 'hang', 'hao', 'he',
\'hei', 'hen', 'heng', 'hong', 'hou', 'hu', 'hua', 'huai', 'huan', 'huang',
\'hui', 'hun', 'huo', "'i", 'ji', 'jia', 'jian', 'jiang', 'jiao', 'jie',
\'jin', 'jing', 'jiong', 'jiu', 'ju', 'juan', 'jue', 'jun', 'ka', 'kai',
\'kan', 'kang', 'kao', 'ke', 'ken', 'keng', 'kong', 'kou', 'ku', 'kua',
\'kuai', 'kuan', 'kuang', 'kui', 'kun', 'kuo', 'la', 'lai', 'lan', 'lang',
\'lao', 'le', 'lei', 'leng', 'li', 'lia', 'lian', 'liang', 'liao', 'lie',
\'lin', 'ling', 'liu', 'long', 'lou', 'lu', 'luan', 'lue', 'lun', 'luo',
\'lv', 'ma', 'mai', 'man', 'mang', 'mao', 'me', 'mei', 'men', 'meng', 'mi',
\'mian', 'miao', 'mie', 'min', 'ming', 'miu', 'mo', 'mou', 'mu', 'na',
\'nai', 'nan', 'nang', 'nao', 'ne', 'nei', 'nen', 'neng', "'ng", 'ni',
\'nian', 'niang', 'niao', 'nie', 'nin', 'ning', 'niu', 'nong', 'nou', 'nu',
\'nuan', 'nue', 'nuo', 'nv', "'o", "'ou", 'pa', 'pai', 'pan', 'pang',
\'pao', 'pei', 'pen', 'peng', 'pi', 'pian', 'piao', 'pie', 'pin', 'ping',
\'po', 'pou', 'pu', 'qi', 'qia', 'qian', 'qiang', 'qiao', 'qie', 'qin',
\'qing', 'qiong', 'qiu', 'qu', 'quan', 'que', 'qun', 'ran', 'rang', 'rao',
\'re', 'ren', 'reng', 'ri', 'rong', 'rou', 'ru', 'ruan', 'rui', 'run',
\'ruo', 'sa', 'sai', 'san', 'sang', 'sao', 'se', 'sen', 'seng', 'sha',
\'shai', 'shan', 'shang', 'shao', 'she', 'shei', 'shen', 'sheng', 'shi',
\'shou', 'shu', 'shua', 'shuai', 'shuan', 'shuang', 'shui', 'shun', 'shuo',
\'si', 'song', 'sou', 'su', 'suan', 'sui', 'sun', 'suo', 'ta', 'tai',
\'tan', 'tang', 'tao', 'te', 'teng', 'ti', 'tian', 'tiao', 'tie', 'ting',
\'tong', 'tou', 'tu', 'tuan', 'tui', 'tun', 'tuo', "'u", "'v", 'wa', 'wai',
\'wan', 'wang', 'wei', 'wen', 'weng', 'wo', 'wu', 'xi', 'xia', 'xian',
\'xiang', 'xiao', 'xie', 'xin', 'xing', 'xiong', 'xiu', 'xu', 'xuan',
\'xue', 'xun', 'ya', 'yan', 'yang', 'yao', 'ye', 'yi', 'yin', 'ying', 'yo',
\'yong', 'you', 'yu', 'yuan', 'yue', 'yun', 'za', 'zai', 'zan', 'zang',
\'zao', 'ze', 'zei', 'zen', 'zeng', 'zha', 'zhai', 'zhan', 'zhang', 'zhao',
\'zhe', 'zhen', 'zheng', 'zhi', 'zhong', 'zhou', 'zhu', 'zhua', 'zhuai',
\'zhuan', 'zhuang', 'zhui', 'zhun', 'zhuo', 'zi', 'zong', 'zou', 'zu',
\'zuan', 'zui', 'zun', 'zuo']
endfunction

" --------------------------------------------
function! s:vimim_create_shuangpin_table(rule)
" --------------------------------------------
    let pinyin_list = s:vimim_get_pinyin_table()
    let rules = a:rule
    let sptable = {}
    " generate table for shengmu-yunmu pairs match
    for key in pinyin_list
        if key !~ "['a-z]*"
            continue
        endif
        if key[1] == "h"
            let shengmu = key[:1]
            let yunmu = key[2:]
        else
            let shengmu = key[0]
            let yunmu = key[1:]
        endif
        if has_key(rules[0], shengmu)
            let shuangpin_shengmu = rules[0][shengmu]
        else
            continue
        endif
        if has_key(rules[1], yunmu)
            let shuangpin_yunmu = rules[1][yunmu]
        else
            continue
        endif
        let sp1 = shuangpin_shengmu.shuangpin_yunmu
        if !has_key(sptable, sp1)
            if key[0] == "'"
                let key = key[1:]
            end
            let sptable[sp1] = key
        endif
    endfor
    " the jxqy+v special case handling
    if s:vimim_shuangpin == 'abc'
    \|| s:vimim_shuangpin == 'purple'
    \|| s:vimim_shuangpin == 'nature'
    \|| s:vimim_shuangpin == 'flypy'
        let jxqy = {"jv" : "ju", "qv" : "qu", "xv" : "xu", "yv" : "yu"}
        call extend(sptable, jxqy)
    elseif s:vimim_shuangpin == 'ms'
        let jxqy = {"jv" : "jue", "qv" : "que", "xv" : "xue", "yv" : "yue"}
        call extend(sptable, jxqy)
    endif
    " the flypy shuangpin special case handling
    if s:vimim_shuangpin == 'flypy'
        let flypy = {"aa" : "a", "oo" : "o", "ee" : "e",
                    \"an" : "an", "ao" : "ao", "ai" : "ai", "ah": "ang",
                    \"os" : "ong","ou" : "ou",
                    \"en" : "en", "er" : "er", "ei" : "ei", "eg": "eng" }
        call extend(sptable, flypy)
    endif
    " the nature shuangpin special case handling
    if s:vimim_shuangpin == 'nature'
        let nature = {"aa" : "a", "oo" : "o", "ee" : "e" }
        call extend(sptable, nature)
    endif
    " generate table for shengmu-only match
    for [key, value] in items(rules[0])
        if key[0] == "'"
            let sptable[value] = ""
        else
            let sptable[value] = key
        end
    endfor
    " finished init sptable, will use in s:vimim_shuangpin_transform
    return sptable
endfunction

" -----------------------------------
function! s:vimim_shuangpin_generic()
" -----------------------------------
" generate the default value of shuangpin table
    let shengmu_list = {}
    for shengmu in ["b", "p", "m", "f", "d", "t", "l", "n", "g",
                \"k", "h", "j", "q", "x", "r", "z", "c", "s", "y", "w"]
        let shengmu_list[shengmu] = shengmu
    endfor
    let shengmu_list["'"] = "o"
    let yunmu_list = {}
    for yunmu in ["a", "o", "e", "i", "u", "v"]
        let yunmu_list[yunmu] = yunmu
    endfor
    let s:shuangpin_rule = [shengmu_list, yunmu_list]
    return s:shuangpin_rule
endfunction

" -----------------------------------
function! s:vimim_shuangpin_abc(rule)
" -----------------------------------
" [auto cloud test] vim sogou.shuangpin_abc.vimim
" vtpc => shuang pin => double pinyin
    call extend(a:rule[0],{ "zh" : "a", "ch" : "e", "sh" : "v" })
    call extend(a:rule[1],{
        \"an" : "j", "ao" : "k", "ai" : "l", "ang": "h",
        \"ong": "s", "ou" : "b",
        \"en" : "f", "er" : "r", "ei" : "q", "eng": "g", "ng" : "g",
        \"ia" : "d", "iu" : "r", "ie" : "x", "in" : "c", "ing": "y",
        \"iao": "z", "ian": "w", "iang": "t", "iong" : "s",
        \"un" : "n", "ua" : "d", "uo" : "o", "ue" : "m", "ui" : "m",
        \"uai": "c", "uan": "p", "uang": "t" } )
    return a:rule
endfunction

" ----------------------------------
function! s:vimim_shuangpin_ms(rule)
" ----------------------------------
" [auto cloud test] vim sogou.shuangpin_ms.vimim
" vi=>zhi ii=>chi ui=>shi keng=>keneng
    call extend(a:rule[0],{ "zh" : "v", "ch" : "i", "sh" : "u" })
    call extend(a:rule[1],{
        \"an" : "j", "ao" : "k", "ai" : "l", "ang": "h",
        \"ong": "s", "ou" : "b",
        \"en" : "f", "er" : "r", "ei" : "z", "eng": "g", "ng" : "g",
        \"ia" : "w", "iu" : "q", "ie" : "x", "in" : "n", "ing": ";",
        \"iao": "c", "ian": "m", "iang" : "d", "iong" : "s",
        \"un" : "p", "ua" : "w", "uo" : "o", "ue" : "t", "ui" : "v",
        \"uai": "y", "uan": "r", "uang" : "d" ,
        \"v" : "y"} )
    return a:rule
endfunction

" --------------------------------------
function! s:vimim_shuangpin_nature(rule)
" --------------------------------------
" [auto cloud test] vim sogou.shuangpin_nature.vimim
" goal: 'woui' => wo shi => i am
    call extend(a:rule[0],{ "zh" : "v", "ch" : "i", "sh" : "u" })
    call extend(a:rule[1],{
        \"an" : "j", "ao" : "k", "ai" : "l", "ang": "h",
        \"ong": "s", "ou" : "b",
        \"en" : "f", "er" : "r", "ei" : "z", "eng": "g", "ng" : "g",
        \"ia" : "w", "iu" : "q", "ie" : "x", "in" : "n", "ing": "y",
        \"iao": "c", "ian": "m", "iang" : "d", "iong" : "s",
        \"un" : "p", "ua" : "w", "uo" : "o", "ue" : "t", "ui" : "v",
        \"uai": "y", "uan": "r", "uang" : "d" } )
    return a:rule
endfunction

" ----------------------------------------
function! s:vimim_shuangpin_plusplus(rule)
" ----------------------------------------
" [auto cloud test] vim sogou.shuangpin_plusplus.vimim
    call extend(a:rule[0],{ "zh" : "v", "ch" : "u", "sh" : "i" })
    call extend(a:rule[1],{
        \"an" : "f", "ao" : "d", "ai" : "s", "ang": "g",
        \"ong": "y", "ou" : "p",
        \"en" : "r", "er" : "q", "ei" : "w", "eng": "t", "ng" : "t",
        \"ia" : "b", "iu" : "n", "ie" : "m", "in" : "l", "ing": "q",
        \"iao": "k", "ian": "j", "iang" : "h", "iong" : "y",
        \"un" : "z", "ua" : "b", "uo" : "o", "ue" : "x", "ui" : "v",
        \"uai": "x", "uan": "c", "uang" : "h" } )
    return a:rule
endfunction

" --------------------------------------
function! s:vimim_shuangpin_purple(rule)
" --------------------------------------
" [auto cloud test] vim sogou.shuangpin_purple.vimim
    call extend(a:rule[0],{ "zh" : "u", "ch" : "a", "sh" : "i" })
    call extend(a:rule[1],{
        \"an" : "r", "ao" : "q", "ai" : "p", "ang": "s",
        \"ong": "h", "ou" : "z",
        \"en" : "w", "er" : "j", "ei" : "k", "eng": "t", "ng" : "t",
        \"ia" : "x", "iu" : "j", "ie" : "d", "in" : "y", "ing": ";",
        \"iao": "b", "ian": "f", "iang" : "g", "iong" : "h",
        \"un" : "m", "ua" : "x", "uo" : "o", "ue" : "n", "ui" : "n",
        \"uai": "y", "uan": "l", "uang" : "g"} )
    return a:rule
endfunction

" -------------------------------------
function! s:vimim_shuangpin_flypy(rule)
" -------------------------------------
" [auto cloud test] vim sogou.shuangpin_flypy.vimim
    call extend(a:rule[0],{ "zh" : "v", "ch" : "i", "sh" : "u" })
    call extend(a:rule[1],{
        \"an" : "j", "ao" : "c", "ai" : "d", "ang": "h",
        \"ong": "s", "ou" : "z",
        \"en" : "f", "er" : "r", "ei" : "w", "eng": "g", "ng" : "g",
        \"ia" : "x", "iu" : "q", "ie" : "p", "in" : "b", "ing": "k",
        \"iao": "n", "ian": "m", "iang" : "l", "iong" : "s",
        \"un" : "y", "ua" : "x", "uo" : "o", "ue" : "t", "ui" : "v",
        \"uai": "k", "uan": "r", "uang" : "l" } )
    return a:rule
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input misc       ==== {{{"]
" =================================================

" -------------------------------------
function! s:vimim_get_valid_im_name(im)
" -------------------------------------
    let im = a:im
    if empty(im)
        let im = 0
    elseif im =~ '^wubi'
        let im = 'wubi'
    elseif im =~ '^pinyin'
        let im = 'pinyin'
        let s:vimim_imode_pinyin = 1
    elseif im !~ s:all_vimim_input_methods
        let im = 0
    endif
    return im
endfunction

" -----------------------------------------
function! s:vimim_set_special_im_property()
" -----------------------------------------
    if  s:ui.im == 'pinyin' || s:has_cjk_file > 0
        let s:quanpin_table = s:vimim_create_quanpin_table()
    endif
    if s:backend[s:ui.root][s:ui.im].name =~# "quote"
        let s:ui.has_dot = 2  " has_apostrophe_in_datafile
    endif
    if s:ui.im == 'wu'
    \|| s:ui.im == 'erbi'
    \|| s:ui.im == 'yong'
    \|| s:ui.im == 'nature'
    \|| s:ui.im == 'boshiamy'
        let s:ui.has_dot = 1  " dot in datafile
        let s:vimim_chinese_punctuation = -99
    endif
    if s:ui.im == 'phonetic'
    \|| s:ui.im == 'array30'
        let s:ui.has_dot = 1
        let s:vimim_chinese_punctuation = -99
        let s:vimim_chinese_input_mode = "static"
    endif
endfunction

" -----------------------------------------------
function! s:vimim_wubi_4char_auto_input(keyboard)
" -----------------------------------------------
" support wubi non-stop typing by auto selection on each 4th
    let keyboard = a:keyboard
    if s:chinese_input_mode =~ 'dynamic'
        if len(keyboard) > 4
            let start = 4*((len(keyboard)-1)/4)
            let keyboard = strpart(keyboard, start)
        endif
        let s:keyboard_list = [keyboard]
    endif
    return keyboard
endfunction

" -------------------------------------------
function! s:vimim_dynamic_wubi_auto_trigger()
" -------------------------------------------
    let not_used_valid_keys = "[0-9.']"
    for char in s:valid_keys
        if char !~# not_used_valid_keys
            sil!exe 'inoremap <silent> ' . char . '
            \ <C-R>=g:vimim_pumvisible_wubi_ctrl_e_ctrl_y()<CR>'
            \. char . '<C-R>=g:vimim()<CR>'
        endif
    endfor
endfunction

" -----------------------------------------------
function! g:vimim_pumvisible_wubi_ctrl_e_ctrl_y()
" -----------------------------------------------
    let key = ""
    if pumvisible()
        let key = "\<C-E>"
        if empty(len(get(s:keyboard_list,0))%4)
            let key = "\<C-Y>"
            let s:has_pumvisible = 1
            let s:keyboard_list = []
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" ------------------------------------------------
function! s:vimim_erbi_first_punctuation(keyboard)
" ------------------------------------------------
    let keyboard = a:keyboard
    let chinese_punctuation = 0
    if len(keyboard) == 1
    \&& keyboard =~ "[.,/;]"
    \&& has_key(s:punctuations, keyboard)
        let chinese_punctuation = s:punctuations[keyboard]
    endif
    return chinese_punctuation
endfunction

" ----------------------------------------------------
" http://www.vim.org/scripts/script.php?script_id=2006
" ----------------------------------------------------
let s:progressbar = {}
function! NewSimpleProgressBar(title, max_value, ...)
    if !has("statusline")
        return {}
    endif
    let winnr = a:0 ? a:1 : winnr()
    let b = copy(s:progressbar)
    let b.title = a:title
    let b.max_value = a:max_value
    let b.cur_value = 0
    let b.winnr = winnr
    let b.items = {
        \ 'title' : { 'color' : 'Statusline' },
        \ 'bar' : { 'fillchar' : ' ', 'color' : 'Statusline' ,
        \           'fillcolor' : 'DiffDelete' , 'bg' : 'Statusline' },
        \ 'counter' : { 'color' : 'Statusline' } }
    let b.stl_save = getwinvar(winnr,"&statusline")
    let b.lst_save = &laststatus"
    return b
endfunction
function! s:progressbar.paint()
    let max_len = winwidth(self.winnr)-1
    let t_len = strlen(self.title)+1+1
    let c_len = 2*strlen(self.max_value)+1+1+1
    let pb_len = max_len - t_len - c_len - 2
    let cur_pb_len = (pb_len*self.cur_value)/self.max_value
    let t_color = self.items.title.color
    let b_fcolor = self.items.bar.fillcolor
    let b_color = self.items.bar.color
    let c_color = self.items.counter.color
    let fc= strpart(self.items.bar.fillchar." ",0,1)
    let stl = "%#".t_color."#%-( ".self.title." %)".
        \"%#".b_color."#|".
        \"%#".b_fcolor."#%-(".repeat(fc,cur_pb_len)."%)".
        \"%#".b_color."#".repeat(" ",pb_len-cur_pb_len)."|".
        \"%=%#".c_color."#%( ".repeat(" ",(strlen(self.max_value)-
        \strlen(self.cur_value))).self.cur_value."/".self.max_value."  %)"
    set laststatus=2
    call setwinvar(self.winnr,"&stl",stl)
    redraw
endfunction
function! s:progressbar.incr( ... )
    let i = a:0 ? a:1 : 1
    let i+=self.cur_value
    let i = i < 0 ? 0 : i > self.max_value ? self.max_value : i
    let self.cur_value = i
    call self.paint()
    return self.cur_value
endfunction
function! s:progressbar.restore()
    call setwinvar(self.winnr,"&stl",self.stl_save)
    let &laststatus=self.lst_save
    redraw
endfunction

" ============================================= }}}
let s:VimIM += [" ====  backend unicode  ==== {{{"]
" =================================================

" -------------------------------------
function! s:vimim_initialize_encoding()
" -------------------------------------
    let s:encoding = "utf8"
    if &encoding == "chinese"
    \|| &encoding == "cp936"
    \|| &encoding == "gb2312"
    \|| &encoding == "gbk"
    \|| &encoding == "euc-cn"
        let s:encoding = "chinese"
    elseif &encoding == "taiwan"
    \|| &encoding == "cp950"
    \|| &encoding == "big5"
    \|| &encoding == "euc-tw"
        let s:encoding = "taiwan"
    endif
" ------------ ----------------- --------------
" vim encoding datafile encoding s:localization
" ------------ ----------------- --------------
"   utf-8          utf-8                0
"   utf-8          chinese              1
"   chinese        utf-8                2
"   chinese        chinese              3
" ------------ ----------------- --------------
    let s:localization = 0
    if &encoding == "utf-8"
        if len("datafile_fenc_chinese") > 20110129
            let s:localization = 1
        endif
    else
        let s:localization = 2
    endif
    if s:localization > 0
        let warning = "performance hit if &encoding & datafile differs!"
    endif
    let s:multibyte = 2
    if &encoding == "utf-8"
        let s:multibyte = 3
    endif
endfunction

" ------------------------------------------
function! s:vimim_get_unicode_list(keyboard)
" ------------------------------------------
    let ddddd = s:vimim_get_unicode_ddddd(a:keyboard)
    if ddddd < 8888 || ddddd > 19968+20902
        return []
    endif
    let words = []
    let height = 108
    for i in range(height)
        let chinese = nr2char(ddddd+i)
        call add(words, chinese)
    endfor
    return words
endfunction

" ----------------------------------
function! s:vimim_get_unicode_menu()
" ----------------------------------
    let byte_before = getline(".")[col(".")-2]
    if empty(byte_before) || byte_before =~# s:valid_key
        return 0
    endif
    let start = s:multibyte + 1
    let char_before = getline(".")[col(".")-start : col(".")-2]
    let ddddd = char2nr(char_before)
    let uxxxx = 0
    if ddddd > 127
        let uxxxx = printf('u%04x', ddddd)
    endif
    if !empty(uxxxx)
        let s:hjkl_h = 1
        call s:vimim_set_seamless()
        let uxxxx .= '\<C-R>=g:vimim()\<CR>'
    endif
    sil!exe 'sil!return "' . uxxxx . '"'
endfunction

" -------------------------------------------
function! s:vimim_get_unicode_ddddd(keyboard)
" -------------------------------------------
    let keyboard = a:keyboard
    if strlen(keyboard) != 5
        return 0
    endif
    let ddddd = 0
    if keyboard =~# '^u\x\{4}$'
        " show hex unicode popup menu: u808f
        let xxxx = keyboard[1:]
        let ddddd = str2nr(xxxx, 16)
    elseif keyboard =~# '^\d\{5}$'
        " show decimal unicode popup menu: 32911
        let ddddd = str2nr(keyboard, 10)
    endif
    if empty(ddddd) || ddddd > 0xffff
        return 0
    endif
    return ddddd
endfunction

" -------------------------------------------
function! s:vimim_cjk_property_display(ddddd)
" -------------------------------------------
    let unicode = printf('u%04x', a:ddddd)
    if s:has_cjk_file < 1
        return unicode . s:space . a:ddddd
    endif
    call s:vimim_load_cjk_file()
    let chinese = nr2char(a:ddddd)
    let five = get(s:vimim_get_property(chinese,1),0)
    let four = get(s:vimim_get_property(chinese,2),0)
    let digit = five
    if s:vimim_digit_4corner > 0
        let digit = four
    endif
    if  s:has_slash_grep > 0
        let digit = five . s:space . four
    endif
    let pinyin = get(s:vimim_get_property(chinese,'pinyin'),0)
    let english = get(s:vimim_get_property(chinese,'english'),0)
    let keyboard_head = get(s:keyboard_list,0)
    if keyboard_head =~ s:uxxxx
        let unicode = unicode . s:space
    else
        let unicode = ""
    endif
    let unicode .= digit . s:space . pinyin
    if !empty(english)
        let unicode .= s:space . english
    endif
    return unicode
endfunction

" ============================================= }}}
let s:VimIM += [" ====  backend file     ==== {{{"]
" =================================================

" ------------------------------------------------
function! s:vimim_scan_backend_embedded_datafile()
" ------------------------------------------------
    if s:mom_and_dad > 0 || s:vimim_tab_as_onekey > 1
        return
    endif
    for im in s:all_vimim_input_methods
        let datafile = s:vimim_data_file
        if !empty(datafile) && filereadable(datafile)
            if datafile =~ '\<' . im . '\>'
                call s:vimim_set_datafile(im, datafile)
            endif
        endif
        let datafile = s:path . "vimim." . im . ".txt"
        if filereadable(datafile)
            call s:vimim_set_datafile(im, datafile)
        else
            let datafile = 0
            continue
        endif
    endfor
endfunction

" ------------------------------------------
function! s:vimim_set_datafile(im, datafile)
" ------------------------------------------
    let im = s:vimim_get_valid_im_name(a:im)
    let datafile = a:datafile
    if empty(im)
    \|| empty(datafile)
    \|| !filereadable(datafile)
    \|| isdirectory(datafile)
        return
    endif
    let s:ui.root = "datafile"
    let s:ui.im = im
    call insert(s:ui.frontends, [s:ui.root, s:ui.im])
    let s:backend.datafile[im] = s:vimim_one_backend_hash()
    let s:backend.datafile[im].root = "datafile"
    let s:backend.datafile[im].im = im
    let s:backend.datafile[im].name = datafile
    let s:backend.datafile[im].keycode = s:im_keycode[im]
    let s:backend.datafile[im].chinese = s:vimim_chinese(im)
    if empty(s:backend.datafile[im].lines)
        let s:backend.datafile[im].lines = s:vimim_readfile(datafile)
    endif
endfunction

" ----------------------------------------
function! s:vimim_get_from_cache(keyboard)
" ----------------------------------------
    let keyboard = a:keyboard
    if empty(a:keyboard)
    \|| empty(s:backend[s:ui.root][s:ui.im].cache)
        return []
    endif
    let results = []
    if has_key(s:backend[s:ui.root][s:ui.im].cache, keyboard)
        let results = s:backend[s:ui.root][s:ui.im].cache[keyboard]
    endif
    if s:ui.im =~ 'pinyin' && len(results) > 0 && len(results) < 20
        let extras = s:vimim_more_pinyin_datafile(keyboard)
        if len(extras) > 0
            let make_pair_filter = 'keyboard ." ". v:val'
            call map(results, make_pair_filter)
            call extend(results, extras)
        endif
    endif
    return results
endfunction

" ----------------------------------------------
function! s:vimim_more_pinyin_datafile(keyboard)
" ----------------------------------------------
    let candidates = s:vimim_more_pinyin_candidates(a:keyboard)
    if empty(candidates)
        return []
    endif
    let results = []
    let lines = s:backend[s:ui.root][s:ui.im].lines
    for candidate in candidates
        let pattern = '^' . candidate . '\>'
        let matched = match(lines, pattern, 0)
        if matched < 0
            continue
        endif
        let oneline = lines[matched]
        let matched_list = s:vimim_make_pair_matched_list(oneline)
        call extend(results, matched_list)
    endfor
    return results
endfunction

" ----------------------------------------------
function! s:vimim_sentence_match_cache(keyboard)
" ----------------------------------------------
    let keyboard = a:keyboard
    if empty(keyboard)
    \|| empty(s:backend[s:ui.root][s:ui.im].cache)
        return []
    endif
    if has_key(s:backend[s:ui.root][s:ui.im].cache, keyboard)
        return keyboard
    elseif empty(s:english_results)
        " scan more on cache when English is not found
    else
        return 0
    endif
    let im = s:ui.im
    let max = len(keyboard)
    let found = 0
    while max > 1
        let max -= 1
        let head = strpart(keyboard, 0, max)
        if has_key(s:backend[s:ui.root][s:ui.im].cache, head)
            let found = 1
            break
        else
            continue
        endif
    endwhile
    if found > 0
        return keyboard[0 : max-1]
    else
        return 0
    endif
endfunction

" -------------------------------------------------
function! s:vimim_sentence_match_datafile(keyboard)
" -------------------------------------------------
    let keyboard = a:keyboard
    let lines = s:backend[s:ui.root][s:ui.im].lines
    let pattern = '^' . keyboard . '\>'
    let match_start = match(lines, pattern)
    if match_start > -1
        return keyboard
    elseif empty(s:english_results)
        " scan more on datafile when English is not found
    else
        return 0
    endif
    let max = len(keyboard)
    " wo'you'yige'meng works in this algorithm
    while max > 1
        let max -= 1
        let head = strpart(keyboard, 0, max)
        let pattern = '^' . head . '\>'
        let match_start = match(lines, pattern)
        if match_start < 0
            continue
        else
            break
        endif
    endwhile
    if match_start < 0
        return 0
    else
        return keyboard[0 : max-1]
    endif
endfunction

" ---------------------------------------------------
function! s:vimim_get_from_datafile(keyboard, search)
" ---------------------------------------------------
    let keyboard = a:keyboard
    let lines = s:backend[s:ui.root][s:ui.im].lines
    if empty(keyboard) || empty(lines)
        return []
    endif
    let pattern = '^' . keyboard . '\>'
    let matched = match(lines, pattern)
    if matched < 0
        return []
    endif
    let oneline = lines[matched]
    let results = split(oneline)[1:]
    let pairs = split(oneline)
    if a:search < 1 && s:ui.im =~ 'pinyin'
    \&& len(pairs) > 0 && len(pairs) < 20
        let extras = s:vimim_more_pinyin_datafile(keyboard)
        if len(extras) > 0
            let results = s:vimim_make_pair_matched_list(oneline)
            call extend(results, extras)
        endif
    endif
    return results
endfunction

" -----------------------------------------------
function! s:vimim_make_pair_matched_list(oneline)
" -----------------------------------------------
" [input]    lively 热闹 活泼
" [output] ['lively 热闹', 'lively 活泼']
    let oneline_list = split(a:oneline)
    let menu = remove(oneline_list, 0)
    if empty(menu) || menu =~ '\W'
        return []
    endif
    let results = []
    for chinese in oneline_list
        let menu_chinese = menu .' '. chinese
        call add(results, menu_chinese)
    endfor
    return results
endfunction

" ------------------------------------------------
function! s:vimim_more_pinyin_candidates(keyboard)
" ------------------------------------------------
" [purpose] make standard layout for popup menu
"           in   =>  mamahuhu
"           out  =>  mamahuhu, mama, ma
" ------------------------------------------------
    let keyboard = a:keyboard
    if empty(s:english_results)
        " break up keyboard only if it is not english
    else
        return []
    endif
    let keyboards = s:vimim_get_pinyin_from_pinyin(keyboard)
    if empty(keyboards) || empty(keyboard)
        return []
    endif
    let candidates = []
    for i in reverse(range(len(keyboards)-1))
        let candidate = join(keyboards[0 : i], "")
        call add(candidates, candidate)
    endfor
    return candidates
endfunction

" --------------------------------------
function! s:vimim_build_datafile_cache()
" --------------------------------------
    if s:vimim_use_cache < 1
        return
    endif
    if s:backend[s:ui.root][s:ui.im].root == "datafile"
        if empty(s:backend[s:ui.root][s:ui.im].lines)
            let msg = "no way to build datafile cache"
        elseif empty(s:backend[s:ui.root][s:ui.im].cache)
            let im = s:vimim_chinese(s:ui.im)
            let database = s:vimim_chinese('database')
            let total = len(s:backend[s:ui.root][s:ui.im].lines)
            let progress = "VimIM loading " . im . database
            let progressbar = NewSimpleProgressBar(progress, total)
            try
                call s:vimim_load_datafile_cache(progressbar)
            finally
                call progressbar.restore()
            endtry
        endif
    endif
endfunction

" ------------------------------------------------
function! s:vimim_load_datafile_cache(progressbar)
" ------------------------------------------------
    if empty(s:backend[s:ui.root][s:ui.im].cache)
        let msg = "cache only needs to be loaded once"
    else
        return
    endif
    for line in s:backend[s:ui.root][s:ui.im].lines
        call a:progressbar.incr(1)
        let oneline_list = split(line)
        let menu = remove(oneline_list, 0)
        let s:backend[s:ui.root][s:ui.im].cache[menu] = oneline_list
    endfor
endfunction

" -------------------------------------------
function! s:vimim_force_scan_current_buffer()
" -------------------------------------------
" auto enter chinese input mode => vim vimim
" auto mycloud input            => vim mycloud.vimim
" auto cloud input              => vim sogou.vimim
" auto cloud onekey             => vim sogou.onekey.vimim
" auto wubi dynamic input mode  => vim wubi.dynamic.vimim
" -------------------------------------------
    let buffer = expand("%:p:t")
    if buffer !~ '.vimim\>'
        return
    endif
    " ---------------------------------------
    if buffer =~ 'dynamic'
        let s:vimim_chinese_input_mode = 'dynamic'
    elseif buffer =~ 'static'
        let s:vimim_chinese_input_mode = 'static'
    endif
    " ---------------------------------------
    if buffer =~ 'shuangpin_abc'
        let s:vimim_shuangpin = 'abc'
    elseif buffer =~ 'shuangpin_ms'
        let s:vimim_shuangpin = 'ms'
    elseif buffer =~ 'shuangpin_nature'
        let s:vimim_shuangpin = 'nature'
    elseif buffer =~ 'shuangpin_plusplus'
        let s:vimim_shuangpin = 'plusplus'
    elseif buffer =~ 'shuangpin_purple'
        let s:vimim_shuangpin = 'purple'
    elseif buffer =~ 'shuangpin_flypy'
        let s:vimim_shuangpin = 'flypy'
    endif
    " ---------------------------------------
    if buffer =~# 'sogou'
        let s:vimim_cloud_sogou = 1
        call s:vimim_set_sogou()
    elseif buffer =~# 'mycloud'
        call s:vimim_do_force_mycloud()
    else
        for input_method in s:all_vimim_input_methods
            if buffer =~ input_method . '\>'
                break
            else
                continue
            endif
        endfor
        if buffer =~ input_method
            if buffer =~# 'cache'
                let s:vimim_use_cache = 1
            endif
            let s:vimim_cloud_sogou = 0
            let s:vimim_cloud_plugin = 0
            let datafile = s:path . "vimim." . input_method . ".txt"
            call s:vimim_set_datafile(input_method, datafile)
        endif
    endif
endfunction

" -------------------------------------------------
function! s:vimim_get_im_from_buffer_name(filename)
" -------------------------------------------------
    let im = 0
    for key in copy(keys(s:im_keycode))
        let pattern = '\<' . key . '\>'
        let matched = match(a:filename, pattern)
        if matched < 0
            continue
        else
            let im = key
            break
        endif
    endfor
    return im
endfunction

" ============================================= }}}
let s:VimIM += [" ====  backend dir      ==== {{{"]
" =================================================

" -------------------------------------------------
function! s:vimim_scan_backend_embedded_directory()
" -------------------------------------------------
    if s:mom_and_dad > 0
        return
    endif
    for im in s:all_vimim_input_methods
        let dir = s:vimim_data_directory
        if !empty(dir) && isdirectory(dir)
            let tail = get(split(dir,"/"), -1)
            if tail =~ '\<' . im . '\>'
                call s:vimim_set_directory(im, dir)
            endif
        endif
        let dir = s:path . im
        if isdirectory(dir)
            call s:vimim_set_directory(im, dir)
        else
            let dir = 0
            continue
        endif
    endfor
endfunction

" --------------------------------------
function! s:vimim_set_directory(im, dir)
" --------------------------------------
    let im = s:vimim_get_valid_im_name(a:im)
    let dir = a:dir
    if empty(im) || empty(dir) || !isdirectory(dir)
        return
    endif
    let s:ui.root = "directory"
    let s:ui.im = im
    call add(s:ui.frontends, [s:ui.root, s:ui.im])
    if empty(s:backend.directory)
        let s:backend.directory[im] = s:vimim_one_backend_hash()
        let s:backend.directory[im].root = "directory"
        let s:backend.directory[im].name = s:vimim_data_directory
        let s:backend.directory[im].im = im
        let s:backend.directory[im].keycode = s:im_keycode[im]
        let s:backend.directory[im].chinese = s:vimim_chinese(im)
    endif
endfunction

" ----------------------------------------------------
function! s:vimim_more_pinyin_directory(keyboard, dir)
" ----------------------------------------------------
    let candidates = s:vimim_more_pinyin_candidates(a:keyboard)
    if empty(candidates)
        return []
    endif
    let results = []
    for candidate in candidates
        let matches = []
        let filename = a:dir . candidate
        if filereadable(filename)
            let matches = s:vimim_readfile(filename)
        elseif s:has_cjk_file > 0 && s:chinese_input_mode =~ 'onekey'
            let matches = s:vimim_cjk_match(candidate)[0:20]
        endif
        if empty(matches)
            continue
        else
            call map(matches, 'candidate ." ". v:val')
            call extend(results, matches)
        endif
    endfor
    return results
endfunction

" -------------------------------------------------
function! s:vimim_get_from_directory(keyboard, dir)
" -------------------------------------------------
    if empty(a:dir) || empty(a:keyboard)
        return []
    endif
    let results = []
    let filename = a:dir . a:keyboard
    if filereadable(filename)
        let results = s:vimim_readfile(filename)
    endif
    return results
endfunction

" --------------------------------------------------
function! s:vimim_sentence_match_directory(keyboard)
" --------------------------------------------------
    let keyboard = a:keyboard
    let filename = s:vimim_data_directory . keyboard
    if filereadable(filename)
        return keyboard
    elseif empty(s:english_results)
        " scan more on directory when English is not found
    else
        return 0
    endif
    let max = len(keyboard)
    "  i.have.a.dream works in this algorithm
    while max > 1
        let max -= 1
        let head = strpart(keyboard, 0, max)
        let filename = s:vimim_data_directory . head
        " workaround: filereadable("/filename.") returns true
        if filereadable(filename)
            if head[-1:-1] != "."
                break
            endif
        else
            continue
        endif
    endwhile
    if filereadable(filename)
        return keyboard[0 : max-1]
    else
        return 0
    endif
endfunction

" -----------------------
function! g:vimim_mkdir()
" -----------------------
" purpose: create one file per entry based on vimim.pinyin.txt
"    (1) $cd $VIM/vimfiles/plugin/vimim/
"    (2) $vi vimim.pinyin.txt => :call g:vimim_mkdir()
" ----------------------------------------------------
    let root = expand("%:p:h")
    let dir = root . "/" . expand("%:e:e:r")
    if !exists(dir) && !isdirectory(dir)
        call mkdir(dir, "p")
    endif
    let option = 'prepend'
    let lines = readfile(bufname("%"))
    for line in lines
        let entries = split(line)
        let key = get(entries, 0)
        if match(key, "'") > -1
            let key = substitute(key,"'",'','g')
        endif
        let key_as_filename = dir . "/" . key
        let chinese_list = entries[1:]
        let first_list = []
        let second_list = []
        if filereadable(key_as_filename)
            let contents = split(join(readfile(key_as_filename)))
            if option =~ 'append'
                let first_list = contents
                let second_list = chinese_list
            elseif option =~ 'prepend'
                let first_list = chinese_list
                let second_list = contents
            elseif option =~ 'replace'
                let first_list = chinese_list
                let option = 'append'
            endif
            call extend(first_list, second_list)
            let chinese_list = copy(first_list)
        endif
        let results = s:vimim_remove_duplication(chinese_list)
        if !empty(results)
            call writefile(results, key_as_filename)
        endif
    endfor
endfunction

" -------------------------------------------
function! s:vimim_remove_duplication(chinese)
" -------------------------------------------
    if empty(a:chinese)
        return []
    endif
    let cache = {}
    let results = []
    for line in a:chinese
        let characters = split(line)
        for char in characters
            if has_key(cache, char) || empty(char)
                continue
            else
                let cache[char] = char
                call add(results, char)
            endif
        endfor
    endfor
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  backend cloud    ==== {{{"]
" =================================================

" ------------------------------------
function! s:vimim_scan_backend_cloud()
" ------------------------------------
" s:vimim_cloud_sogou=0  : default, auto open when no datafile
" s:vimim_cloud_sogou=-1 : cloud is shut down without condition
" -------------------------------------------------------------
    if empty(s:backend.datafile)
    \&& empty(s:backend.directory)
    \&& empty(s:vimim_cloud_plugin)
        call s:vimim_set_sogou()
        if s:has_cjk_file == 1
            " it seems better to use local cjk
            let s:has_cjk_file = 2
            let s:ui.im = 'pinyin'
        endif
    endif
    if empty(s:vimim_cloud_sogou)
        let s:vimim_cloud_sogou = 888
    endif
endfunction

" ---------------------------
function! s:vimim_set_sogou()
" ---------------------------
    if s:ui.root == "cloud" && s:ui.im == "sogou"
        return
    endif
    let cloud = s:vimim_set_cloud_backend_if_www_executable('sogou')
    if empty(cloud)
        let s:vimim_cloud_sogou = 0
        let s:backend.cloud = {}
    else
        let s:ui.root = "cloud"
        let s:ui.im = "sogou"
        let s:vimim_cloud_plugin = 0
    endif
endfunction

" -------------------------------------------------------
function! s:vimim_set_cloud_backend_if_www_executable(im)
" -------------------------------------------------------
    let im = a:im
    if empty(s:backend.cloud)
        let s:backend.cloud[im] = s:vimim_one_backend_hash()
    endif
    let cloud = s:vimim_check_http_executable(im)
    if empty(cloud)
        return 0
    else
        let s:backend.cloud[im].root = "cloud"
        let s:backend.cloud[im].im = im
        let s:backend.cloud[im].keycode = s:im_keycode[im]
        let s:backend.cloud[im].chinese = s:vimim_chinese(im)
        return cloud
    endif
endfunction

" -----------------------------------------
function! s:vimim_check_http_executable(im)
" -----------------------------------------
    if s:vimim_cloud_sogou < 0
        return {}
    endif
    " step #1 of 3: try to find libvimim
    let cloud = s:vimim_get_libvimim()
    if !empty(cloud) && filereadable(cloud)
        " in win32, strip the .dll suffix
        if has("win32") && cloud[-4:] ==? ".dll"
            let cloud = cloud[:-5]
        endif
        let ret = libcall(cloud, "do_geturl", "__isvalid")
        if ret ==# "True"
            let s:www_executable = cloud
            let s:www_libcall = 1
            call s:vimim_do_cloud_if_no_embedded_backend()
        else
            return {}
        endif
    endif
    " step #2 of 3: try to find wget
    if empty(s:www_executable)
        let wget = 0
        let wget_exe = s:path . "wget.exe"
        if executable(wget_exe)
            let wget = wget_exe
        elseif executable('wget')
            let wget = "wget"
        endif
        if !empty(wget)
            let wget_option = " -qO - --timeout 20 -t 10 "
            let s:www_executable = wget . wget_option
        endif
    endif
    " step #3 of 3: try to find curl if no wget
    if empty(s:www_executable)
        if executable('curl')
            let s:www_executable = "curl -s "
        endif
    endif
    if empty(s:www_executable)
        return {}
    else
        call s:vimim_do_cloud_if_no_embedded_backend()
    endif
    return s:backend.cloud[a:im]
endfunction

" -------------------------------------------------
function! s:vimim_do_cloud_if_no_embedded_backend()
" -------------------------------------------------
    if empty(s:backend.directory) && empty(s:backend.datafile)
        if s:has_cjk_file > 0 && s:chinese_input_mode =~ 'onekey'
            let s:vimim_cloud_sogou = 888
        else
            let s:vimim_cloud_sogou = 1
        endif
    endif
endfunction

" ------------------------------------
function! s:vimim_magic_tail(keyboard)
" ------------------------------------
    let keyboard = a:keyboard
    if keyboard =~ '\d'
        return []
    endif
    let magic_tail = keyboard[-1:-1]
    let last_but_one = keyboard[-2:-2]
    if magic_tail =~ "[.']" && last_but_one =~ "[0-9a-z]"
        " play with magic trailing char
    else
        return []
    endif
    let keyboards = []
    " ----------------------------------------------------
    " <dot> triple play in OneKey:
    "   (1) magic trailing dot => forced-non-cloud in cloud
    "   (2) magic trailing dot => forced-cjk-match
    "   (3) as word partition  => match dot by dot
    " ----------------------------------------------------
    if magic_tail ==# "."
        " trailing dot => forced-non-cloud
        let s:has_no_internet = 2
        call add(keyboards, -1)
    elseif magic_tail ==# "'"
        " trailing apostrophe => forced-cloud
        let s:has_no_internet -= 2
        let cloud = s:vimim_set_cloud_backend_if_www_executable('sogou')
        if empty(cloud)
            return []
        endif
        call add(keyboards, 1)
    endif
    " ----------------------------------------------------
    " <apostrophe> double play in OneKey:
    "   (1) magic trailing apostrophe => cloud at will
    "   (2) as word partition  => match apostrophe by apostrophe
    " ----------------------------------------------------
    let keyboard = keyboard[:-2]
    call insert(keyboards, keyboard)
    return keyboards
endfunction

" -------------------------------------------------
function! s:vimim_to_cloud_or_not(keyboard, clouds)
" -------------------------------------------------
    if s:chinese_input_mode =~ 'onekey'
        if s:has_cjk_file > 1 && get(a:clouds, 1) < 1
            return 0
        endif
    endif
    let keyboard = a:keyboard
    if keyboard =~ "[^a-z]"
    \|| s:vimim_cloud_sogou < 1
    \|| s:has_no_internet > 1
        return 0
    endif
    if s:has_no_internet < 0
    \|| s:vimim_cloud_sogou == 1
    \|| get(a:clouds, 1) > 0
        return 1
    endif
    let threshold_to_trigger_cloud = len(keyboard)
    if s:chinese_input_mode !~ 'dynamic' && s:ui.im == 'pinyin'
        let pinyins = s:vimim_get_pinyin_from_pinyin(keyboard)
        let threshold_to_trigger_cloud = len(pinyins)
    endif
    if threshold_to_trigger_cloud < s:vimim_cloud_sogou
        return 0
    endif
    return 1
endfunction

" ------------------------------------------------
function! s:vimim_get_cloud_sogou(keyboard, force)
" ------------------------------------------------
    let keyboard = a:keyboard
    if empty(keyboard)
    \|| keyboard =~# '\L'
    \|| empty(s:www_executable)
    \|| (s:vimim_cloud_sogou < 1 && a:force < 1)
        return []
    endif
    " --------------------------------------------------------
    let sogou_key = 'http://web.pinyin.sogou.com/web_ime/patch.php'
    if empty(s:cloud_sogou_key)
        let output = s:vimim_get_from_http(sogou_key)
        " only use sogou when we get a valid key
        if empty(output)
            return []
        endif
        let s:cloud_sogou_key = get(split(output, '"'), 1)
    endif
    " --------------------------------------------------------
    " http://web.pinyin.sogou.com/web_ime/get_ajax/woyouyigemeng.key
    let cloud = 'http://web.pinyin.sogou.com/api/py?key='
    let cloud = cloud . s:cloud_sogou_key .'&query='
    let input = cloud . keyboard
    let output = s:vimim_get_from_http(input)
    if empty(output)
        return []
    endif
    " --------------------------------------------------------
    let first = match(output, '"', 0)
    let second = match(output, '"', 0, 2)
    if first > 0 && second > 0
        let output = strpart(output, first+1, second-first-1)
        let output = s:vimim_url_xx_to_chinese(output)
    endif
    if empty(output)
        return []
    endif
    if empty(s:localization)
        " support gb and big5 in addition to utf8
    else
        let output = s:vimim_i18n_read(output)
    endif
    " --------------------------------------------------------
    " from output => '我有一个梦：13    +
    " to   output => ['woyouyigemeng 我有一个梦']
    let menu = []
    for item in split(output, '\t+')
        let item_list = split(item, '：')
        if len(item_list) > 1
            let chinese = get(item_list,0)
            let english = strpart(keyboard, 0, get(item_list,1))
            let new_item = english . " " . chinese
            call add(menu, new_item)
        endif
    endfor
    return menu
endfunction

" ------------------------------------
function! s:vimim_get_from_http(input)
" ------------------------------------
    if empty(s:www_executable)
        return 0
    endif
    let input = a:input
    let output = 0
    try
        if s:www_libcall > 0
            let output = libcall(s:www_executable, "do_geturl", input)
        else
            let input = '"' . input . '"'
            let output = system(s:www_executable . input)
        endif
    catch
        call s:debugs("sogou::", output ." ". v:exception)
        let output = 0
    endtry
    return output
endfunction

" ============================================= }}}
let s:VimIM += [" ====  backend mycloud  ==== {{{"]
" =================================================

" --------------------------------------
function! s:vimim_scan_backend_mycloud()
" --------------------------------------
" let g:vimim_mycloud_url = "app:python d:/mycloud/mycloud.py"
" let g:vimim_mycloud_url = "app:".$VIM."/src/mycloud/mycloud"
" let g:vimim_mycloud_url = "dll:".$HOME."/plugin/cygvimim.dll"
" let g:vimim_mycloud_url = "dll:".$HOME."/plugin/libvimim.so"
" let g:vimim_mycloud_url = "dll:/home/im/plugin/libmyplugin.so:arg:func"
" let g:vimim_mycloud_url = "dll:/data/libvimim.so:192.168.0.1"
" let g:vimim_mycloud_url = "http://pim-cloud.appspot.com/abc/"
" let g:vimim_mycloud_url = "http://pim-cloud.appspot.com/ms/"
" ------------------------------------------------------------
    if empty(s:backend.datafile) && empty(s:backend.directory)
        call s:vimim_set_mycloud()
    endif
endfunction

" ----------------------------------
function! s:vimim_do_force_mycloud()
" ----------------------------------
" [auto mycloud test] vim mycloud.vimim
    if s:vimim_mycloud_url =~ '^http\|^dll\|^app'
        return
    endif
    let s:vimim_mycloud_url = "http://pim-cloud.appspot.com/qp/"
    call s:vimim_set_mycloud()
endfunction

" -----------------------------
function! s:vimim_set_mycloud()
" -----------------------------
    if s:ui.root == "cloud" && s:ui.im == "mycloud"
        return
    endif
    let mycloud = s:vimim_set_mycloud_backend()
    if empty(mycloud)
        let msg = "mycloud is not available"
    else
        let s:ui.root = "cloud"
        let s:ui.im = "mycloud"
    endif
endfunction

" -------------------------------------
function! s:vimim_set_mycloud_backend()
" -------------------------------------
    let cloud = s:vimim_set_cloud_backend_if_www_executable('mycloud')
    if empty(cloud)
        return {}
    endif
    let mycloud = s:vimim_check_mycloud_availability()
    if empty(mycloud)
        let s:backend.cloud = {}
        return {}
    else
        let s:vimim_cloud_sogou = -777
        let s:vimim_cloud_plugin = mycloud
        return s:backend.cloud.mycloud
    endif
endfunction

" --------------------------------------------
function! s:vimim_check_mycloud_availability()
" --------------------------------------------
" reuse s:vimim_mycloud_url for forced buffer scan: vim mycloud.vimim
    let cloud = 0
    if empty(s:vimim_mycloud_url)
        let cloud = s:vimim_check_mycloud_plugin_libcall()
    else
        let cloud = s:vimim_check_mycloud_plugin_url()
    endif
    if empty(cloud)
        let s:vimim_cloud_plugin = 0
        return 0
    endif
    let ret = s:vimim_access_mycloud(cloud, "__getname")
    let directory = split(ret, "\t")[0]
    let ret = s:vimim_access_mycloud(cloud, "__getkeychars")
    let keycode = split(ret, "\t")[0]
    if empty(keycode)
        let s:vimim_cloud_plugin = 0
        return 0
    else
        let s:backend.cloud.mycloud.directory = directory
        let s:backend.cloud.mycloud.keycode = s:im_keycode["mycloud"]
        return cloud
    endif
endfunction

" ------------------------------------------
function! s:vimim_access_mycloud(cloud, cmd)
" ------------------------------------------
"  use the same function to access mycloud by libcall() or system()
    let executable = s:www_executable
    if s:cloud_plugin_mode == "libcall"
        let arg = s:cloud_plugin_arg
        if empty(arg)
            return libcall(a:cloud, s:cloud_plugin_func, a:cmd)
        else
            return libcall(a:cloud, s:cloud_plugin_func, arg." ".a:cmd)
        endif
    elseif s:cloud_plugin_mode == "system"
        return system(a:cloud." ".shellescape(a:cmd))
    elseif s:cloud_plugin_mode == "www"
        let input = s:vimim_rot13(a:cmd)
        if s:www_libcall
            let ret = libcall(executable, "do_geturl", a:cloud.input)
        else
            let ret = system(executable . shellescape(a:cloud.input))
        endif
        let output = s:vimim_rot13(ret)
        let ret = s:vimim_url_xx_to_chinese(output)
        return ret
    endif
    return ""
endfunction

" ------------------------------
function! s:vimim_get_libvimim()
" ------------------------------
    let cloud = ""
    if has("win32") || has("win32unix")
        let cloud = "libvimim.dll"
    elseif has("unix")
        let cloud = "libvimim.so"
    else
        return ""
    endif
    let cloud = s:path . cloud
    if filereadable(cloud)
        return cloud
    endif
    return ""
endfunction

" ----------------------------------------------
function! s:vimim_check_mycloud_plugin_libcall()
" ----------------------------------------------
    " we do plug-n-play for libcall(), not for system()
    let cloud = s:vimim_get_libvimim()
    if empty(cloud)
        return 0
    endif
    let s:cloud_plugin_mode = "libcall"
    let s:cloud_plugin_arg = ""
    let s:cloud_plugin_func = 'do_getlocal'
    if filereadable(cloud)
        if has("win32")
            " we don't need to strip ".dll" for "win32unix".
            let cloud = cloud[:-5]
        endif
        try
            let ret = s:vimim_access_mycloud(cloud, "__isvalid")
            if split(ret, "\t")[0] == "True"
                return cloud
            endif
        catch
            call s:debugs('libcall_mycloud2::error=',v:exception)
        endtry
    endif
    " libcall check failed, we now check system()
    if has("gui_win32")
        return 0
    endif
    " on linux, we do plug-n-play
    let cloud = s:path . "mycloud/mycloud"
    if !executable(cloud)
        if !executable("python")
            return 0
        endif
        let cloud = "python " . cloud
    endif
    " in POSIX system, we can use system() for mycloud
    let s:cloud_plugin_mode = "system"
    let ret = s:vimim_access_mycloud(cloud, "__isvalid")
    if split(ret, "\t")[0] == "True"
        return cloud
    endif
    return 0
endfunction

" ------------------------------------------
function! s:vimim_check_mycloud_plugin_url()
" ------------------------------------------
    " we do set-and-play on all systems
    let part = split(s:vimim_mycloud_url, ':')
    let lenpart = len(part)
    if lenpart <= 1
        call s:debugs("invalid_cloud_plugin_url::","")
    elseif part[0] ==# 'app'
        if !has("gui_win32")
            " strip the first root if contains ":"
            if lenpart == 3
                if part[1][0] == '/'
                    let cloud = part[1][1:] . ':' .  part[2]
                else
                    let cloud = part[1] . ':' . part[2]
                endif
            elseif lenpart == 2
                let cloud = part[1]
            endif
            " in POSIX system, we can use system() for mycloud
            if executable(split(cloud, " ")[0])
                let s:cloud_plugin_mode = "system"
                let ret = s:vimim_access_mycloud(cloud, "__isvalid")
                if split(ret, "\t")[0] == "True"
                    return cloud
                endif
            endif
        endif
    elseif part[0] ==# "dll"
        if len(part[1]) == 1
            let base = 1
        else
            let base = 0
        endif
        " provide function name
        if lenpart >= base+4
            let s:cloud_plugin_func = part[base+3]
        else
            let s:cloud_plugin_func = 'do_getlocal'
        endif
        " provide argument
        if lenpart >= base+3
            let s:cloud_plugin_arg = part[base+2]
        else
            let s:cloud_plugin_arg = ""
        endif
        " provide the dll
        if base == 1
            let cloud = part[1] . ':' . part[2]
        else
            let cloud = part[1]
        endif
        if filereadable(cloud)
            let s:cloud_plugin_mode = "libcall"
            " strip off the .dll suffix, only required for win32
            if has("win32") && cloud[-4:] ==? ".dll"
                let cloud = cloud[:-5]
            endif
            try
                let ret = s:vimim_access_mycloud(cloud, "__isvalid")
                if split(ret, "\t")[0] == "True"
                    return cloud
                endif
            catch
                call s:debugs('libcall_mycloud1::', v:exception)
            endtry
        endif
    elseif part[0] ==# "http" || part[0] ==# "https"
        let cloud = s:vimim_mycloud_url
        if !empty(s:www_executable)
            let s:cloud_plugin_mode = "www"
            let ret = s:vimim_access_mycloud(cloud, "__isvalid")
            if split(ret, "\t")[0] == "True"
                return cloud
            endif
        endif
    else
        call s:debugs("invalid_cloud_plugin_url::","")
    endif
    return 0
endfunction

" --------------------------------------------
function! s:vimim_get_mycloud_plugin(keyboard)
" --------------------------------------------
    if empty(s:vimim_cloud_plugin)
        return []
    endif
    let cloud = s:vimim_cloud_plugin
    let output = 0
    try
        let output = s:vimim_access_mycloud(cloud, a:keyboard)
    catch
        let output = 0
        call s:debugs('mycloud::',v:exception)
    endtry
    if empty(output)
        return []
    endif
    return s:vimim_process_mycloud_output(a:keyboard, output)
endfunction

" --------------------------------------------------------
function! s:vimim_process_mycloud_output(keyboard, output)
" --------------------------------------------------------
" one line typical output:  春梦 8 4420
    if empty(a:output) || empty(a:keyboard)
        return []
    endif
    let menu = []
    for item in split(a:output, '\n')
        let item_list = split(item, '\t')
        let chinese = get(item_list,0)
        if s:localization > 0
            let chinese = s:vimim_i18n_read(chinese)
        endif
        if empty(chinese) || get(item_list,1,-1)<0
            " bypass the debug line which have -1
            continue
        endif
        let extra_text = get(item_list,2)
        let english = a:keyboard[get(item_list,1):]
        let new_item = extra_text . " " . chinese . english
        call add(menu, new_item)
    endfor
    return menu
endfunction

" -------------------------------------
function! s:vimim_url_xx_to_chinese(xx)
" -------------------------------------
    let input = a:xx
    let output = a:xx
    if s:www_libcall > 0
        let output = libcall(s:www_executable, "do_unquote", a:xx)
    else
        let output = substitute(input, '%\(\x\x\)',
                    \ '\=eval(''"\x''.submatch(1).''"'')','g')
    endif
    return output
endfunction

" -------------------------------
function! s:vimim_rot13(keyboard)
" -------------------------------
    let rot13 = a:keyboard
    let a = "12345abcdefghijklmABCDEFGHIJKLM"
    let z = "98760nopqrstuvwxyzNOPQRSTUVWXYZ"
    let rot13 = tr(rot13, a.z, z.a)
    return rot13
endfunction

" ============================================= }}}
let s:VimIM += [" ====  core workflow    ==== {{{"]
" =================================================

" --------------------------------------
function! s:vimim_initialize_i_setting()
" --------------------------------------
    let s:saved_cpo=&cpo
    let s:saved_iminsert=&iminsert
    let s:completefunc=&completefunc
    let s:completeopt=&completeopt
    let s:saved_lazyredraw=&lazyredraw
    let s:saved_pumheight=&pumheight
    let s:saved_laststatus=&laststatus
    let s:saved_hlsearch=&hlsearch
    let s:saved_smartcase=&smartcase
endfunction

" ------------------------------
function! s:vimim_i_setting_on()
" ------------------------------
    set completefunc=VimIM
    set completeopt=menuone
    set nolazyredraw
    set hlsearch
    set smartcase
    set iminsert=1
    if empty(&pumheight)
        let &pumheight=9
    endif
endfunction

" -------------------------------
function! s:vimim_i_setting_off()
" -------------------------------
    let &cpo=s:saved_cpo
    let &iminsert=s:saved_iminsert
    let &completefunc=s:completefunc
    let &completeopt=s:completeopt
    let &lazyredraw=s:saved_lazyredraw
    let &pumheight=s:saved_pumheight
    let &laststatus=s:saved_laststatus
    let &hlsearch=s:saved_hlsearch
    let &smartcase=s:saved_smartcase
endfunction

" -----------------------
function! s:vimim_start()
" -----------------------
    sil!call s:vimim_plugins_fix_start()
    sil!call s:vimim_i_setting_on()
    sil!call s:vimim_cursor_color(1)
    sil!call s:vimim_super_reset()
    sil!call s:vimim_123456789_label_on()
    sil!call s:vimim_helper_mapping_on()
endfunction

" ----------------------
function! s:vimim_stop()
" ----------------------
    sil!call s:vimim_i_setting_off()
    sil!call s:vimim_cursor_color(0)
    sil!call s:vimim_super_reset()
    sil!call s:vimim_i_map_off()
    sil!call s:vimim_plugins_fix_stop()
    sil!call s:vimim_initialize_mapping()
endfunction

" -----------------------------
function! s:vimim_super_reset()
" -----------------------------
    sil!call s:vimim_reset_before_anything()
    sil!call g:vimim_reset_after_insert()
endfunction

" ---------------------------------------
function! s:vimim_reset_before_anything()
" ---------------------------------------
    let s:hjkl_h = 0
    let s:hjkl_l = 0
    let s:hjkl_m = 0
    let s:hjkl_n = 0
    let s:hjkl_x = 0
    let s:show_me_not = 0
    let s:smart_enter = 0
    let s:pumvisible_ctrl_e  = 0
    let s:pattern_not_found  = 0
    let s:keyboard_shuangpin = 0
    let s:popupmenu_list = []
    let s:matched_list   = []
    let s:keyboard_list  = []
endfunction

" ------------------------------------
function! g:vimim_reset_after_insert()
" ------------------------------------
    let s:cjk_filter = ""
    let s:has_no_internet = 0
    let s:has_pumvisible = 0
    let s:hjkl_pageup_pagedown = 0
    return ""
endfunction

" -----------------
function! g:vimim()
" -----------------
    let key = ""
    let byte_before = getline(".")[col(".")-2]
    if byte_before =~ s:valid_key
        let key  = '\<C-X>\<C-U>'
        let key .= '\<C-R>=g:vimim_menu_select()\<CR>'
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" -----------------------------
function! g:vimim_menu_select()
" -----------------------------
    let key = ""
    if pumvisible()
        let key = '\<C-P>\<Down>'
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" ---------------------------
function! s:vimim_i_map_off()
" ---------------------------
    let unmap_list = range(0,9)
    call extend(unmap_list, s:AZ_list)
    call extend(unmap_list, s:valid_keys)
    call extend(unmap_list, keys(s:evils))
    call extend(unmap_list, keys(s:punctuations))
    call extend(unmap_list, ['<Esc>','<CR>','<BS>','<Space>'])
    for _ in unmap_list
        sil!exe 'iunmap '. _
    endfor
endfunction

" ============================================= }}}
let s:VimIM += [" ====  core engine      ==== {{{"]
" =================================================

" ---------------------------------------------------------
function! s:vimim_embedded_backend_engine(keyboard, search)
" ---------------------------------------------------------
    let keyboard = a:keyboard
    let im = s:ui.im
    let root = s:ui.root
    if empty(im)
    \|| empty(root)
    \|| s:show_me_not > 0
    \|| keyboard !~# s:valid_key
        return []
    endif
    if s:has_cjk_file < 1 && s:ui.im == 'pinyin'
        let keyboard = s:vimim_toggle_pinyin(keyboard)
    endif
    if s:ui.has_dot == 2
        let keyboard = s:vimim_add_apostrophe(keyboard)
    endif
    let results = []
    let keyboard2 = 0
    if root =~# "directory"
        let dir = s:backend[root][im].name
        let keyboard2 = s:vimim_sentence_match_directory(keyboard)
        let results = s:vimim_get_from_directory(keyboard2, dir)
        if keyboard ==# keyboard2 && s:ui.im =~ 'pinyin'
        \&& a:search < 1 && len(results) > 0 && len(results) < 20
            let extras = s:vimim_more_pinyin_directory(keyboard, dir)
            if len(extras) > 0 && len(results) > 0
                call map(results, 'keyboard ." ". v:val')
                call extend(results, extras)
            endif
        endif
    elseif root =~# "datafile"
        if empty(s:backend[root][im].cache)
            let keyboard2 = s:vimim_sentence_match_datafile(keyboard)
            let results = s:vimim_get_from_datafile(keyboard2, a:search)
        else
            let keyboard2 = s:vimim_sentence_match_cache(keyboard)
            let results = s:vimim_get_from_cache(keyboard2)
        endif
    endif
    if s:chinese_input_mode !~ "dynamic" && len(s:keyboard_list) < 2
        if empty(keyboard2)
            let s:keyboard_list = [keyboard]
        elseif len(keyboard2) < len(keyboard)
            let tail = strpart(keyboard,len(keyboard2))
            let s:keyboard_list = [keyboard2, tail]
        elseif s:ui.im == 'pinyin'
            let s:keyboard_list = [keyboard2, ""]
        endif
    endif
    return results
endfunction

" ------------------------------
function! VimIM(start, keyboard)
" ------------------------------
if a:start

    let current_positions = getpos(".")
    let start_column = current_positions[2]-1
    let start_row = current_positions[1]
    let current_line = getline(start_row)
    let byte_before = current_line[start_column-1]
    let current_line_left = current_line[0 : start_column-2]

    " [/grep] state-of-the-art slash grep
    if s:chinese_input_mode =~ 'onekey'
        let s:has_slash_grep = 0
        let slash_column = match(current_line_left, "/")
        if slash_column > -1 && s:has_cjk_file > 0
            let more = 0
            while more > -1
                let more = match(current_line_left, "/", slash_column)
                let slash_column += 1
            endwhile
            let grep = current_line_left[slash_column : -1]
            let space = match(grep, '\s')
            if space < 0
                let s:has_slash_grep = 1
                return slash_column - 1
            endif
        endif
    endif

    " take care of seamless English/Chinese input
    let seamless_column = s:vimim_get_seamless(current_positions)
    if seamless_column < 0
        let msg = "no need to set seamless"
    else
        let len = current_positions[2]-1 - seamless_column
        let keyboard = strpart(current_line, seamless_column, len)
        call s:vimim_set_keyboard_list(seamless_column, keyboard)
        return seamless_column
    endif

    let last_seen_nonsense_column = copy(start_column)
    let last_seen_backslash_column = copy(start_column)
    let all_digit = 1
    let nonsense_pattern = "[0-9.']"
    if s:ui.has_dot == 1
        let nonsense_pattern = "[.]"
    endif
    while start_column > 0
        if byte_before =~# s:valid_key
            let start_column -= 1
            if byte_before !~# nonsense_pattern
                let last_seen_nonsense_column = start_column
                if all_digit > 0
                    let all_digit = 0
                endif
            endif
        elseif byte_before=='\' && s:vimim_backslash_close_pinyin>0
            " do nothing for pinyin with leading backslash
            return last_seen_backslash_column
        else
            break
        endif
        let byte_before = current_line[start_column-1]
    endwhile
    if all_digit < 1
        let start_column = last_seen_nonsense_column
    endif

    let s:start_row_before = start_row
    let s:current_positions = current_positions
    let len = current_positions[2]-1 - start_column
    let keyboard = strpart(current_line, start_column, len)
    call s:vimim_set_keyboard_list(start_column, keyboard)

    return start_column

else

    let s:show_me_not = 0
    let s:english_results = []
    let results = []
    let keyboard = a:keyboard

    " [/grep] slash grep to search cjk
    if s:has_slash_grep > 0
        let uxxxx = keyboard[s:multibyte : -1]
        if uxxxx =~ s:uxxxx
            let keyboard = uxxxx
        else
            let results = s:vimim_slash_grep(keyboard)
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [input] start to initialize legal input
    let keyboard = s:vimim_get_valid_keyboard(keyboard)
    if empty(keyboard)
        return
    endif

    " [one_key_correction] for static mode using Esc
    if s:one_key_correction > 0
        let s:one_key_correction = 0
        return [' ']
    endif

    " [onekey] play with nothing but OneKey
    let results = s:vimim_onekey_input(keyboard)
    if !empty(len(results)) && empty(s:english_results)
        return s:vimim_popupmenu_list(results)
    endif

    " [mycloud] get chunmeng from mycloud local or www
    if empty(s:vimim_cloud_plugin)
        let msg = "keep local mycloud code for the future"
    else
        let results = s:vimim_get_mycloud_plugin(keyboard)
        if empty(len(results))
            return []
        else
            let s:keyboard_list = [keyboard]
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [cloud] magic trailing apostrophe to control cloud
    let clouds = s:vimim_magic_tail(keyboard)
    if !empty(len(clouds))
        " usage: woyouyigemeng'<C-6>
        let keyboard = get(clouds, 0)
    endif

    " [shuangpin] support 6 major shuangpin
    if !empty(s:vimim_shuangpin)
        if s:chinese_input_mode =~ 'dynamic'
            let s:keyboard_shuangpin = 0
        endif
        if empty(s:keyboard_shuangpin)
            let keyboard = s:vimim_get_pinyin_from_shuangpin(keyboard)
        endif
    endif

    " [sogou] to make cloud come true for woyouyigemeng
    let cloud = s:vimim_to_cloud_or_not(keyboard, clouds)
    if cloud > 0
        let results = s:vimim_get_cloud_sogou(keyboard, cloud)
        if empty(len(results))
            if s:vimim_cloud_sogou > 2
                let s:has_no_internet += 1
            endif
        else
            let s:has_no_internet = -1
            let s:keyboard_list = [keyboard]
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [wubi] support wubi auto input
    if s:ui.im == 'wubi' || s:ui.im == 'erbi'
        let keyboard = s:vimim_wubi_4char_auto_input(keyboard)
        if s:ui.im =~ 'erbi'
            let punctuation = s:vimim_erbi_first_punctuation(keyboard)
            if !empty(punctuation)
                return [punctuation]
            endif
        endif
    endif

    " [backend] plug-n-play embedded backend engine
    let results = s:vimim_embedded_backend_engine(keyboard,0)
    if empty(s:english_results)
        " no english is found for the keyboard input
    else
        call extend(results, s:english_results, 0)
        let results = s:vimim_remove_duplication(results)
    endif
    if !empty(results)
        return s:vimim_popupmenu_list(results)
    endif

    " [sogou] last try before giving up
    if s:has_cjk_file > 0 && s:chinese_input_mode =~ 'onekey'
        let keyboard_head = s:vimim_cjk_sentence_match(keyboard.".")
        if !empty(keyboard_head)
            let results = s:vimim_cjk_match(keyboard_head)
        endif
    elseif s:vimim_cloud_sogou == 1 && keyboard !~# '\L'
        let results = s:vimim_get_cloud_sogou(keyboard, 1)
    endif
    if !empty(len(results))
        return s:vimim_popupmenu_list(results)
    endif

    " [seamless] for OneKeyNonStop and seamless English input
    let s:pattern_not_found += 1
    if s:chinese_input_mode =~ 'onekey'
        let results = [s:space]
    else
        call s:vimim_set_seamless()
    endif
    return s:vimim_popupmenu_list(results)

endif
endfunction

" --------------------------------------------
function! s:vimim_get_valid_keyboard(keyboard)
" --------------------------------------------
    let keyboard = a:keyboard
    if empty(str2nr(keyboard))
        let msg = "keyboard input is alphabet only"
    else
        let keyboard = get(s:keyboard_list,0)
    endif
    if a:keyboard =~# s:uxxxx
        return keyboard
    endif
    if keyboard !~# s:valid_key
        return 0
    endif
    if keyboard =~ "['.]['.]" && empty(s:ui.has_dot)
        " ignore multiple nonsense dots
        let s:pattern_not_found += 1
        return 0
    endif
    return keyboard
endfunction

" ============================================= }}}
let s:VimIM += [" ====  core driver      ==== {{{"]
" =================================================

" -----------------------------------
function! s:vimim_helper_mapping_on()
" -----------------------------------
    inoremap <BS>    <C-R>=g:vimim_pumvisible_ctrl_e_on()<CR>
                    \<C-R>=g:vimim_backspace()<CR>
    inoremap <CR>    <C-R>=g:vimim_pumvisible_ctrl_e()<CR>
                    \<C-R>=<SID>vimim_smart_enter()<CR>
    inoremap <Space> <C-R>=g:vimim_space()<CR>
                    \<C-R>=g:vimim_nonstop_after_insert()<CR>
    " -------------------------------------------------------
    if s:chinese_input_mode !~ 'onekey'
    \&& s:vimim_chinese_punctuation > -1
        inoremap <expr> <C-^> <SID>vimim_toggle_punctuation()
    endif
    " -------------------------------------------------------
    if s:chinese_input_mode =~ 'onekey'
        inoremap <silent> <Esc> <Esc>:call g:vimim_onekey_esc()<CR>
    elseif s:chinese_input_mode =~ 'static'
        inoremap <silent> <Esc> <C-R>=g:vimim_pumvisible_ctrl_e()<CR>
                               \<C-R>=g:vimim_one_key_correction()<CR>
    endif
endfunction

" ------------------------------------
function! s:vimim_initialize_mapping()
" ------------------------------------
    sil!call s:vimim_chinesemode_mapping_on()
    sil!call s:vimim_onekey_mapping_on()
endfunction

" ----------------------------------------
function! s:vimim_chinesemode_mapping_on()
" ----------------------------------------
    if s:vimim_tab_as_onekey < 2
        inoremap <unique> <expr>     <Plug>VimimTrigger <SID>ChineseMode()
            imap <silent> <C-Bslash> <Plug>VimimTrigger
         noremap <silent> <C-Bslash> :call <SID>ChineseMode()<CR>
    endif
    if s:vimim_ctrl_space_to_toggle == 1
        if has("gui_running")
             map <C-Space> <C-Bslash>
            imap <C-Space> <C-Bslash>
        elseif has("win32unix")
             map <C-@> <C-Bslash>
            imap <C-@> <C-Bslash>
        endif
    endif
endfunction

" -----------------------------------
function! s:vimim_onekey_mapping_on()
" -----------------------------------
    if !hasmapto('<Plug>VimimOneKey', 'i')
        inoremap <unique> <expr> <Plug>VimimOneKey <SID>OneKey()
    endif
    if s:vimim_tab_as_onekey < 2 && !hasmapto('<C-^>', 'i')
        imap <silent> <C-^> <Plug>VimimOneKey
    endif
    if s:vimim_tab_as_onekey > 0 && !hasmapto('<Tab>', 'i')
        imap <silent> <Tab> <Plug>VimimOneKey
    endif
    if s:vimim_tab_as_onekey == 2
        xnoremap <silent> <Tab> y:call <SID>vimim_visual_ctrl_6(@0)<CR>
    elseif !hasmapto('<C-^>', 'v')
        xnoremap <silent> <C-^> y:call <SID>vimim_visual_ctrl_6(@0)<CR>
    endif
    if s:vimim_search_next > 0
        noremap <silent> n :call g:vimim_search_next()<CR>n
    endif
    :com! -range=% VimIM <line1>,<line2>call s:vimim_tranfer_chinese()
endfunction

" ------------------------------------
function! s:vimim_initialize_autocmd()
" ------------------------------------
" [egg] promote any dot vimim file to be our first-class citizen
    if has("autocmd") && s:mom_and_dad < 1
        augroup vimim_auto_chinese_mode
            autocmd BufNewFile *.vimim startinsert
            autocmd BufEnter   *.vimim sil!call <SID>ChineseMode()
        augroup END
    endif
endfunction

sil!call s:vimim_initialize_debug()
sil!call s:vimim_initialize_global()
sil!call s:vimim_for_mom_and_dad()
sil!call s:vimim_initialize_mapping()
sil!call s:vimim_initialize_autocmd()
" ======================================= }}}
