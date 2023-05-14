vim9script

nnoremap <silent> <Plug>(yomigana-to-kata) :keepp s/\(.\+\)/\=yomigana#GetKata(submatch(1))/g<CR>
nnoremap <silent> <Plug>(yomigana-to-hira) :keepp s/\(.\+\)/\=yomigana#GetHira(submatch(1))/g<CR>
xnoremap <silent> <Plug>(yomigana-to-kata) :keepp s/\(\(\%V.\)\+\)/\=yomigana#GetKata(submatch(1))/g<CR>
xnoremap <silent> <Plug>(yomigana-to-hira) :keepp s/\(\(\%V.\)\+\)/\=yomigana#GetHira(submatch(1))/g<CR>

nnoremap <Leader>K <Plug>(yomigana-to-kata)
nnoremap <Leader>H <Plug>(yomigana-to-hira)
xnoremap <Leader>K <Plug>(yomigana-to-kata)
xnoremap <Leader>H <Plug>(yomigana-to-hira)

