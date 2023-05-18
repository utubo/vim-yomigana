vim9script

var default = {
  mecab: 'mecab',
  mecab_enc: '',
  yomigana_index: -2,
  default_key_mappings: true
}
if has('win32')
  default.mecab = executable('mecab.exe') ? 'cmd /C "mecab.exe"' : 'cmd /C "%ProgramFiles(x86)%\MeCab\bin\mecab.exe"'
  default.mecab_enc = 'sjis'
endif
g:yomigana = default->extend(get(g:, 'yomigana', { }))

xnoremap <silent> <Plug>(yomigana-to-kata) :keepp s/\(\(\%V.\)\+\)/\=yomigana#GetKata(submatch(1))/g<CR>
xnoremap <silent> <Plug>(yomigana-to-hira) :keepp s/\(\(\%V.\)\+\)/\=yomigana#GetHira(submatch(1))/g<CR>
nnoremap <silent> <Plug>(yomigana-to-kata) <ScriptCmd>&opfunc = 'yomigana#ToKata'<CR>g@
nnoremap <silent> <Plug>(yomigana-to-hira) <ScriptCmd>&opfunc = 'yomigana#ToHira'<CR>g@

if !g:yomigana.default_key_mappings
  finish
endif

xnoremap <Leader>K <Plug>(yomigana-to-kata)
xnoremap <Leader>H <Plug>(yomigana-to-hira)
nnoremap <Leader>K <Plug>(yomigana-to-kata)
nnoremap <Leader>H <Plug>(yomigana-to-hira)
nnoremap <Leader>KK <Plug>(yomigana-to-kata)_
nnoremap <Leader>HH <Plug>(yomigana-to-hira)_

