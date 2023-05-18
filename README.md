# vim-yomigana
MeCabを利用して漢字をカタカナやひらがなに置換したりするプラグインです

## 必要なもの
- Vim9 script (TODO: レガシーにも対応したほうがいいかなぁ？)
- MeCab … パスを通しておいてください

## インストール
.vimrc例  
※このREADME.mdに記載してあるVimscriptは全てVim9 Scriptです
```vimscript
Jetpack 'utubo/vim-yomigana'
```

MeCabのインストール手順は割愛します🙇

### Windowsの場合

MeCabインストーラーをデフォルトのまま実施した場合は.vimrcに以下を追記してください
```vimscript
g:yomigana = {
  mecab: 'cmd /C "C:\Program Files (x86)\MeCab\bin\mecab.exe"',
  mecab_enc: 'sjis'
}
```

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

デフォルトのキーマップを使いたくない場合は.vimrcに以下を記述してください
```vimscript
g:yomigana = { default_key_mappings: false }
```

### 関数

- `yomigana#GetKata({文字列})`, `yomigana#GetHira({文字列})`  
  文字列の読みをカタカナまたはひらがなで返します  
  例えば、以下コマンドでファイル全体をひらがなにできます(処理中はvimが固まります)  
  ```vimscript
  :keepp %s/.*/\=yomigana#GetHira(submatch(0))/
  ```

## オプション

### `g:yomigana.default_key_mappings`

`false`の場合、デフォルトのキーマッピングをしません

### `g:yomigana.mecab`

mecabコマンドの文字列です  
デフォルトは`mecab`です  
必要に応じて`/usr/local/bin/mecab`としたりオプションをつけたりしてください  
vim-yomiganaはMeCabの出力フォーマットは以下を想定しています  
読みがなを取得できない場合は`-F`オプションで調節してください
```
読み<Tab>*,*,*,*,*,*,*,よみ,*
・先頭～<Tab>の前が元の単語
・`,`区切りで後ろから2番目(インデックス=`-2`)が読みがな
```

### `g:yomigana.mecab_enc`

mecabコマンドのエンコードです  
WindowでShit-jisを選択した場合は`sjis`を設定してください。

### `g:yomigana.yomigana_index` (名前が微妙なので変更するかも…)
MeCabの出力フォーマットの読みがなの位置です  
デフォルトは`-2`(後ろから2番目)です

