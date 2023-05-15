vim9script

xnoremap <silent> <Plug>(yomigana-to-kata) :keepp s/\(\(\%V.\)\+\)/\=yomigana#GetKata(submatch(1))/g<CR>
xnoremap <silent> <Plug>(yomigana-to-hira) :keepp s/\(\(\%V.\)\+\)/\=yomigana#GetHira(submatch(1))/g<CR>
nnoremap <silent> <Plug>(yomigana-to-kata) <ScriptCmd>&opfunc = 'yomigana#ToKata'<CR>g@
nnoremap <silent> <Plug>(yomigana-to-hira) <ScriptCmd>&opfunc = 'yomigana#ToHira'<CR>g@

xnoremap <Leader>K <Plug>(yomigana-to-kata)
xnoremap <Leader>H <Plug>(yomigana-to-hira)
nnoremap <Leader>K <Plug>(yomigana-to-kata)
nnoremap <Leader>H <Plug>(yomigana-to-hira)
nnoremap <Leader>KK <Plug>(yomigana-to-kata)_
nnoremap <Leader>HH <Plug>(yomigana-to-hira)_

