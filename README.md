# vim-yomigana
mecabを使って漢字のひらがなやカタカナを取得・置換するプラグインです

## 必要なもの
- vim9script (TODO: レガシーにも対応したほうがいいかなぁ？)
- mecab … パスを通しておいてください

## インストール
.vimrc例
```vimscript
JetPack 'utubo/vim-yomigana'
```

mecabは各自でインストールしてください

### 使い方

#### キーマップ
- `<Plug>(yomigana-to-kata)`, `<Plug>(yomigana-to-hira)`  
  現在行またはビジュアルモードの選択範囲をカタカナまたはひらがなに置換します

- デフォルト
```vimscript
nnoremap <Leader>K <Plug>(yomigana-to-kata)
nnoremap <Leader>H <Plug>(yomigana-to-hira)
xnoremap <Leader>K <Plug>(yomigana-to-kata)
xnoremap <Leader>H <Plug>(yomigana-to-hira)
```

#### 関数

- `yomigana#GetKata({文字列})`, `yomigana#GetHira({文字列})`  
  文字列の読みをカタカナまたはひらがなで返します  
  例えば、以下のようにすることでファイル全体をひらがなにできます  
  ```vimscript
  :%s/.*/\=yomigana#GetHira(submatch(0))/g
  ```

