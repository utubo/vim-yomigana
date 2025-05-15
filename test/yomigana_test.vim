vim9script

var suite = themis#suite('Test for .vimrc')
const assert = themis#helper('assert')

nnoremap K <Plug>(yomigana-to-kata)
nnoremap H <Plug>(yomigana-to-hira)

# MeCabモック入力値
const tmp = tempname()
def GotInput(): string
  return readfile(tmp)->join("\n")
enddef
suite.before = () => {
  writefile([''], tmp)
}
suite.after = () => {
  silent! delete(tmp)
}

# MeCabモック
def SetUpMeCabMock(result: list<string>)
  g:yomigana.mecab =
    $'read line; echo "$line" > {tmp};' ..
    "echo '" .. result->join("'; echo '") .. "';"
  g:yomigana.skkjisyo = []
  g:yomigana.mode = 'mecab'
enddef

# テスト本体

suite.TestGetKataGetHira = () => {
  const mock_result =<< trim END
    漢字	*,*,*,*,*,*,カンジ,*
    を	*,*,*,*,*,*,ヲ,*
    読み仮名	*,*,*,*,*,*,ヨミガナ,*
    に	*,*,*,*,*,*,ニ,*
    変換	*,*,*,*,*,*,ヘンカン,*
    空白	*,*,*,*,*,*,クウハク,*
    や	*,*,*,*,*,*,ヤ,*
    絵文字	*,*,*,*,*,*,エモジ,*
    🎈	*,*,*,*,*,*,*,*
    は	*,*,*,*,*,*,ハ,*
    そのまま	*,*,*,*,*,*,ソノママ,*
  END
  SetUpMeCabMock(mock_result)
  const src = '漢字を読み仮名に変換。空白 や絵文字🎈はそのまま'
  assert.equals(src->yomigana#GetKata(), 'カンジヲヨミガナニヘンカン。クウハク ヤエモジ🎈ハソノママ')
  assert.equals(src->yomigana#GetHira(), 'かんじをよみがなにへんかん。くうはく やえもじ🎈はそのまま')
  assert.equals(GotInput(), src)
}

suite.TestOperation_iw = () => {
  SetUpMeCabMock(['漢字	*,*,*,*,*,*,カンジ,*'])
  setline(1, '漢字,漢字,漢字')
  normal 04lKiw
  assert.equals(GotInput(), '漢字')
  assert.equals(getline(1), '漢字,カンジ,漢字')
}

suite.TestOperation_w = () => {
  SetUpMeCabMock(['漢字	*,*,*,*,*,*,カンジ,*'])
  setline(1, '漢字,漢字,漢字')
  normal 03lKw
  assert.equals(GotInput(), '漢字')
  assert.equals(getline(1), '漢字,カンジ,漢字')
}

suite.TestOperation_line = () => {
  const a = '漢字	*,*,*,*,*,*,カンジ,*'
  SetUpMeCabMock([a, a, a])
  setline(1, '漢字,漢字,漢字')
  normal 03lK_
  assert.equals(GotInput(), '漢字,漢字,漢字')
  assert.equals(getline(1), 'カンジ,カンジ,カンジ')
}

suite.TestGetYomiganaWithSkk = () => {
  writefile([
    '#このぎょうはこめんと /読/',
    '>よm /読/',
  ], tmp)
  g:yomigana.mode = 'skk'
  g:yomigana.skkjisyo = [tmp]
  # '仮名'は辞書にないのでそのまま
  assert.equals('読み仮名'->yomigana#GetHira(), 'よみ仮名')
}
