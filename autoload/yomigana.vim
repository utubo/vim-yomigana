vim9script

################
# ユーティリティ

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

################
# 本体

export def GetYomigana(line: string): string
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

################
# API関数

export def GetKata(str: string): string
  return str->GetYomigana()->ConvChars(hira_list, kata_list)
enddef

export def GetHira(str: string): string
  return str->GetYomigana()->ConvChars(kata_list, hira_list)
enddef

################
# オペレーター

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

