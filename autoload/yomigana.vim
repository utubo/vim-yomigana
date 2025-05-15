vim9script

################
# ユーティリティ {{{
const hira_list = ('ぁあぃいぅうぇえぉおかがきぎくぐけげこご' ..
  'さざしじすずせぜそぞただちぢっつづてでとど' ..
  'なにぬねのはばぱひびぴふぶぷへべぺほぼぽ' ..
  'まみむめもゃやゅゆょよらりるれろゎわゐゑをんゔ')->split('.\zs')
const kata_list = ('ァアィイゥウェエォオカガキギクグケゲコゴ' ..
  'サザシジスズセゼソゾタダチヂッツヅテデトド' ..
  'ナニヌネノハバパヒビピフブプヘベペホボポ' ..
  'マミムメモャヤュユョヨラリルレロヮワヰヱヲンヴ')->split('.\zs')

def ConvChars(src: string, from_chars: list<string>, to_chars: list<string>): string
  var dest = []
  for c in src->split('.\zs')
    const p = from_chars->index(c)
    dest += [p ==# - 1 ? c : to_chars[p]]
  endfor
  return dest->join('')
enddef

def System(cmd: string, input: string, enc: string = ''): string
  if !enc || enc ==# &enc
    return system(cmd, input)
  else
    return system(cmd, input->iconv(&enc, enc))->iconv(enc, &enc)
  endif
enddef
# }}}

################
# 置換 {{{
export def GetYomigana(line: string): string
  if g:yomigana.mode ==# 'mecab'
    try
      return GetYomiganaWithMecab(line)
    catch
      # NOP
    endtry
  endif
  return GetYomiganaWithSkk(line)
enddef
# }}}

################
# 本体(mecab) {{{
def GetYomiganaWithMecab(line: string): string
  if line->trim() ==# ''
    return line
  endif
  const mecab_result = System(g:yomigana.mecab, line, g:yomigana.mecab_enc)
  if v:shell_error !=# 0
    throw $'mecabの実行に失敗しました: `{g:yomigana.mecab}`'
  endif
  # 元の文字列からmecabの結果の漢字を一つずつ検索してよみがなに置換する
  var new_line = [] # 最後にjoinで結合する
  var start = 0
  for m in mecab_result->split("\n")
    const csv = m->split(',')
    if len(csv) <= 1
      break # EOS
    endif
    const kanji = csv[0]->matchstr('^\S\+')
    const yomi = csv->get(g:yomigana.yomigana_index, '*')
    const p = line->stridx(kanji, start)
    # &enc→sjisの変換で`kanji`が'??'になることがある。
    # 要はmecab未対応なのでスキップしちゃう。
    if p ==# -1
      continue
    endif
    new_line += [line->strpart(start, p - start)]
    new_line += [yomi ==# '*' ? kanji : yomi]
    start = p + len(kanji)
  endfor
  new_line += [line->strpart(start)]
  return new_line->join('')
enddef
# }}}

################
# 本体(skk) {{{
var jisyo = {}
def GetYomiganaWithSkk(line: string): string
  if !jisyo
    ExpandSkkJisyoPath()
  endif
  var dest = ''
  var src = line
  while true
    # 漢字があるところまで進む
    const i = src->charidx(src->match('[一-龠々〆ヵヶ]'))
    if i ==# -1
      break
    endif
    if 0 < i
      dest ..= src[0 : i - 1]
      src = src[i :]
    endif
    # 漢字の終りを探して進む
    const k = src->charidx(src->match('[^一-龠々〆ヵヶ]'))
    var kanji = ''
    var okuri = ''
    if k !=# -1
      kanji = src[0 : k - 1]
      src = src[k :]
      okuri = src[0]->GetOkuri()
    else
      # 尻尾まで漢字
      kanji = src
      src = ''
    endif
    # 漢字の読みを検索する
    var yomi = ''
    while true
      for jisyo_path in g:yomigana.skkjisyo
        const j = ReadJisyo(jisyo_path)
        const needle = $'/{kanji}'->IconvTo(j.enc)
        for word in j.lines
          if word->stridx(needle) ==# -1 || word[0] ==# '#'
            continue
          endif
          const w = word->IconvFrom(j.enc)->split(' ')
          if w[1]->match($'/{kanji}[;/]') ==# -1
            continue
          endif
          const o = w[0]->matchstr('[a-z]$')
          if o !=# '' && o !=# okuri
            continue
          endif
          # '方'→'ぽう'に置換しないようにぱ行の優先度は下げておく
          if yomi !=# '' && w[0]->match('^[ぱぴぷぺぽ]') !=# -1
            continue
          endif
          if o ==# okuri
            # 送り仮名まで一致したら確定
            yomi = w[0]->substitute('[a-z]$', '', '')
            break
          else
            # 送り仮名無しの場合はまだ候補があるかもしれないのでbreakしない
            yomi = w[0]
          endif
        endfor
      endfor
      # 読みが見つかった || もう範囲を絞れない終わり
      if yomi !=# '' || kanji[2] ==# ''
        break
      endif
      # 読みが見つからなかったら置換範囲を1文字減らして再検索する
      src = kanji[-1] .. src
      kanji = kanji[0 : -2]
    endwhile
    dest ..= yomi->substitute('^>', '', '') ?? kanji
  endwhile
  return dest .. src
enddef

def GetOkuri(o: string): string
  const i = 'あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽ'
    ->split('.\zs')->index(o)
  if i ==# -1
    return ''
  else
    return 'aiueokkkkkssssstttttnnnnnhhhhhmmmmmyyyrrrrrwgggggzzzzzdddddbbbbbppppp'[i]
  endif
enddef

def ToFullPathAndEncode(path: string): list<string>
  const m = path->matchlist('\(.\+\):\([a-zA-Z0-9-]*\)$')
  return !m ? [expand(path), ''] : [expand(m[1]), m[2]]
enddef

def IconvTo(str: string, enc: string): string
  return (!str || !enc || enc ==# &enc) ? str : str->iconv(&enc, enc)
enddef

def IconvFrom(str: string, enc: string): string
  return (!str || !enc || enc ==# &enc) ? str : str->iconv(enc, &enc)
enddef

def ExpandSkkJisyoPath()
  var expanded = []
  for j in g:yomigana.skkjisyo
    const [path, enc] = ToFullPathAndEncode(j)
    for p in path->split('\n')
      expanded += [$'{p}:{enc}']
    endfor
  endfor
  g:yomigana.skkjisyo = expanded
enddef

def ReadJisyo(path: string): dict<any>
  # キャッシュ済み
  if jisyo->has_key(path)
    return jisyo[path]
  endif
  # 読み込んでスクリプトローカルにキャッシュする
  const [p, enc] = ToFullPathAndEncode(path)
  if !filereadable(p)
    # 後から辞書ファイルを置かれる可能性があるので、キャッシュしない
    return { lines: [], enc: enc }
  endif
  # iconvはWindowsですごく重いので、読み込み時には全体を変換しない
  # 検索時に検索対象の方の文字コードを辞書にあわせる
  jisyo[path] = { lines: readfile(p)->sort(), enc: enc }
  return jisyo[path]
enddef
# }}}

################
# API関数 {{{
export def GetKata(str: string): string
  return str->GetYomigana()->ConvChars(hira_list, kata_list)
enddef

export def GetHira(str: string): string
  return str->GetYomigana()->ConvChars(kata_list, hira_list)
enddef
# }}}

################
# オペレーター {{{
def Substitute(motion: string, sub: string)
  var [sy, sx] = getpos("'[")[1 : 2]
  var [ey, ex] = getpos("']")[1 : 2]
  if motion ==# 'line'
    execute $':{sy},{ey}s/.*/{sub}/'
    return
  endif
  # 終了位置を調整する(調整しないとマルチバイトの時にずれる)
  const endline = getline(ey)
  while 1 < ex && matchstr(endline, $'\%{ex}c.') ==# ''
    ex -= 1
  endwhile
  # 置換実行
  for i in range(sy, ey)
    const s = i ==# sy ? $'\%{sx}c' : ''
    const e = i ==# ey ? $'\%{ex}c.' : ''
    setline(i, getline(i)->substitute($'{s}.*{e}', sub, ''))
  endfor
enddef

export def ToKata(motion: string)
  Substitute(motion, '\=yomigana#GetKata(submatch(0))')
enddef

export def ToHira(motion: string)
  Substitute(motion, '\=yomigana#GetHira(submatch(0))')
enddef
# }}}
