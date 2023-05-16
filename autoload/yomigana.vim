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
  if !enc
    return system(cmd, input)
  else
    return system(cmd, input->iconv(&fenc, enc))->iconv(enc, &fenc)
  endif
enddef

export def GetYomigana(str: string): string
  const config = get(g:, 'yomigana', { })
  const cmd = config->get('mecab', 'mecab')
  const enc = config->get('mecab_enc', '')
  var lines = []
  for line in str->split("\n", 1)
    if line->trim() ==# ''
      lines += [line]
      continue
    endif
    const mecab_result = System(cmd, line, enc)
    if v:shell_error !=# 0
      throw $'mecabの実行に失敗しました: `{cmd}`'
    endif
    var new_line = []
    var start = 0
    for m in mecab_result->split("\n")
      const csv = m->split(',')
      if len(csv) <= 1
        break # EOS
      endif
      const kanji = csv[0]->matchstr('^\S\+')
      const yomi = csv->get(7, '*')
      const p = line->stridx(kanji, start)
      new_line += [line->strpart(start, p - start)]
      new_line += [yomi ==# '*' ? kanji : yomi]
      start = p + len(kanji)
    endfor
    new_line += [line->strpart(start)]
    lines += [new_line->join('')]
  endfor
  return lines->join("\n")
enddef

export def GetKata(str: string): string
  return str->GetYomigana()->ConvChars(hira_list, kata_list)
enddef

export def GetHira(str: string): string
  return str->GetYomigana()->ConvChars(kata_list, hira_list)
enddef

def ToYomigana(getYomigana: string)
  if !visualmode()
    execute "normal v\<Esc>"
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

