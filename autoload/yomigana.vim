vim9script

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

export def GetYomigana(line: string): string
  if line->trim() ==# ''
    return line
  endif
  const mecab_result = System(g:yomigana.mecab, line, g:yomigana.mecab_enc)
  if v:shell_error !=# 0
    throw $'mecabの実行に失敗しました: `{g:yomigana.mecab}`'
  endif
  var new_line = []
  var start = 0
  for m in mecab_result->split("\n")
    const csv = m->split(',')
    if len(csv) <= 1
      break # EOS
    endif
    const kanji = csv[0]->matchstr('^\S\+')
    const yomi = csv->get(g:yomigana.yomigana_index, '*')
    const p = line->stridx(kanji, start)
    if p ==# -1 # &enc→sjisの変換で'??'になると見つからない
      continue
    endif
    new_line += [line->strpart(start, p - start)]
    new_line += [yomi ==# '*' ? kanji : yomi]
    start = p + len(kanji)
  endfor
  new_line += [line->strpart(start)]
  return new_line->join('')
enddef

export def GetKata(str: string): string
  return str->GetYomigana()->ConvChars(hira_list, kata_list)
enddef

export def GetHira(str: string): string
  return str->GetYomigana()->ConvChars(kata_list, hira_list)
enddef

def ToYomigana(getYomigana: string)
  if !visualmode()
    execute "normal! V\<Esc>"
  endif
  const save_c = getpos(".")
  const save_s = getpos("'<")
  const save_e = getpos("'>")
  setpos("'<", getpos("'["))
  setpos("'>", getpos("']"))
  try
    execute $':''<,''>s/\(\(\%V.\)\+\)/\=yomigana#{getYomigana}(submatch(1))/'
  finally
    setpos("'<", save_s)
    setpos("'>", save_e)
    setpos(".", save_c)
  endtry
enddef

export def ToKata(a: any)
  ToYomigana('GetKata')
enddef

export def ToHira(a: any)
  ToYomigana('GetHira')
enddef

