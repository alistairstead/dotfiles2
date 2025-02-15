import { map, simlayer } from 'karabiner.ts'
import { toSymbol } from './utils'

export function homerow() {
  return [
    simlayer('a', 'a-layer').manipulators([
      // navigation and editing
      map('u').to('⇥'),
      map('i').to('⇥'),
      map('h').to('←'),
      map('j').to('↓'),
      map('k').to('↑'),
      map('l').to('→'),
      map('n').to('⇥'),
      map('m').to('⏎'),
      map(',').to('↘︎'),
      map('.').to('↖︎'),
    ]),
    simlayer('r', 'r-layer').manipulators([
      // delete
      map('u').to('⌫'),
      map('i').to('⌦'),
      map('h').to('⌫', '⌘'),
      map('j').to('⌫', '⌥'),
      map('k').to('⌦', '⌥'),
      map('l').to('⌦', '⌘'),
    ]),
    simlayer('e', 'e-layer').manipulators([
      // move
      map('u').to('←'),
      map('i').to('→'),
      map('h').to('←', '⌘'),
      map('j').to('←', '⌥'),
      map('k').to('→', '⌥'),
      map('l').to('→', '⌘'),
    ]),
    simlayer('w', 'w-layer').manipulators([
      // select
      map('u').to('←', '⇧'),
      map('i').to('→', '⇧'),
      map('h').to('←', '⌘⇧'),
      map('j').to('←', '⌥⇧'),
      map('k').to('→', '⌥⇧'),
      map('l').to('→', '⌘⇧'),
    ]),
    simlayer('f', 'f-layer').manipulators([
      // delimiter
      map('u').to(toSymbol('{')),
      map('i').to(toSymbol('}')),
      map('o').to(toSymbol('!')),
      map('j').to(toSymbol('(')),
      map('k').to(toSymbol(')')),
      map('l').to(toSymbol('?')),
      map('m').to(toSymbol('[')),
      map(',').to(toSymbol(']')),
      map('.').to(toSymbol('$')),
    ]),
    simlayer('d', 'd-layer').manipulators([
      // arithmetic symbols
      map('u').to(toSymbol('<')),
      map('i').to(toSymbol('>')),
      map('o').to(toSymbol('#')),
      map('j').to(toSymbol('+')),
      map('k').to(toSymbol('-')),
      map('l').to(toSymbol('=')),
      map('m').to(toSymbol('*')),
      map(',').to(toSymbol('/')),
      map('.').to(toSymbol('%')),
    ]),
    simlayer('s', 's-layer').manipulators([
      // punctuation symbols
      map('u').to(toSymbol("'")),
      map('i').to(toSymbol('"')),
      map('o').to(toSymbol('`')),
      map('j').to(toSymbol(',')),
      map('k').to(toSymbol('.')),
      map('l').to(toSymbol('&')),
      map('m').to(toSymbol(';')),
      map(',').to(toSymbol(':')),
      map('.').to(toSymbol('~')),
    ]),
    simlayer('v', 's-layer').manipulators([
      // number pad
      map('y').to('⌫'),
      map('u').to(toSymbol('7')),
      map('i').to(toSymbol('8')),
      map('o').to(toSymbol('9')),
      map('p').to(toSymbol('+')),
      map('h').to(toSymbol('.')),
      map('j').to(toSymbol('4')),
      map('k').to(toSymbol('5')),
      map('l').to(toSymbol('6')),
      map(';').to(toSymbol('-')),
      map('n').to(toSymbol('0')),
      map('m').to(toSymbol('1')),
      map(',').to(toSymbol('2')),
      map('.').to(toSymbol('3')),
      map('/').to('⏎'),
    ]),
    simlayer('c', 'c-layer').manipulators([
      // remaining symbols
      map('u').to(toSymbol('^')),
      map('i').to(toSymbol('£')),
      map('j').to(toSymbol('|')),
      map('k').to(toSymbol('@')),
      map('m').to(toSymbol('\\')),
      map('n').to(toSymbol('_')),
    ]),
  ]
}
