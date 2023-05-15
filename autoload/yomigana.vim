vim9script

const hira_list = ('ぁあぃいぅうぇえぉおかがきぎくぐけげこご' ..
  'さざしじすずせぜそぞただちぢっつづてでとど' ..
  'なにぬねのはばぱひびぴふぶぷへべぺほぼぽ' ..
  'まみむめもゃやゅゆょよらりるれろゎわゐゑをんゔ')->split('.\zs')
const kata_list = ('ァアィイゥウェエォオカガキギクグケゲコゴ' ..
  'サザシジスズセゼソゾタダチヂッツヅテデトド' ..
  'ナニヌネノハバパヒビピフブプヘベペホボポ' ..
  'マミムメモャヤュユョヨラリルレロヮワヰヱヲンヴ')->split('.\zs')

def KataToHira(kana: string): string
  var hira = []
  for k in kana->split('.\zs')
    const p = kata_list->index(k)
    hira += [p ==# - 1 ? k : hira_list[p]]
  endfor
  return hira->join('')
enddef

export def GetKata(str: string): string
  const mecab = get(g:, 'yomigana', { })->get('mecab', 'mecab')
  var lines = []
  for line in str->split("\n", 1)
    if line->trim() ==# ''
      lines += [line]
      continue
    endif
    const cmd = $'{mecab} -E ""'
    const mecab_result = system(cmd, line)->split("\n")
    if v:shell_error !=# 0
      throw $'mecabの実行に失敗しました: `{cmd}`'
    endif
    var new_line = []
    var start = 0
    for m in mecab_result
      const yomi = get(m->split(','), 7, '*')
      if yomi !=# '*'
        const kanji = m->substitute('\s.*', '', '')
        const p = line->stridx(kanji, start)
        new_line += [line->strpart(start, p - start) .. yomi]
        start = p + len(kanji)
      endif
    endfor
    new_line += [line->strpart(start)]
    lines += [new_line->join('')]
  endfor
  return lines->join("\n")
enddef

export def GetHira(str: string): string
  return str->GetKata()->KataToHira()
enddef

