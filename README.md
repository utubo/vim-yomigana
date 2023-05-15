# vim-yomigana
mecabを利用して漢字をカタカナやひらがなに置換したりするプラグインです

## 必要なもの
- vim9script (TODO: レガシーにも対応したほうがいいかなぁ？)
- mecab … パスを通しておいてください

## インストール
.vimrc例
```vimscript
JetPack 'utubo/vim-yomigana'
```

mecabのインストール手順は割愛します🙇

## 使い方

### キーマップ
- `<Plug>(yomigana-to-kata)`, `<Plug>(yomigana-to-hira)`  
  指定範囲をカタカナまたはひらがなに置換します  

- デフォルト
```vimscript
xnoremap <Leader>K <Plug>(yomigana-to-kata)
xnoremap <Leader>H <Plug>(yomigana-to-hira)
nnoremap <Leader>K <Plug>(yomigana-to-kata)
nnoremap <Leader>H <Plug>(yomigana-to-hira)
nnoremap <Leader>KK <Plug>(yomigana-to-kata)_
nnoremap <Leader>HH <Plug>(yomigana-to-hira)_
```

例えば`<Leader>K$`で行末までカタカナに置換します

### 関数

- `yomigana#GetKata({文字列})`, `yomigana#GetHira({文字列})`  
  文字列の読みをカタカナまたはひらがなで返します  
  例えば、以下コマンドでファイル全体をひらがなにできます(処理中はvimが固まります)  
  ```vimscript
  :keepp %s/.*/\=yomigana#GetHira(submatch(0))/
  ```

