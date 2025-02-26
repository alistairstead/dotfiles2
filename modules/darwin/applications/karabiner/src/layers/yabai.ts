import { rule, to$, withModifier } from 'karabiner.ts'

export const toYabai$ = (command: string) =>
  to$(`/etc/profiles/per-user/alistairstead/bin/yabai -m ${command}`)

export function yabaiLayer() {
  return [
    rule('Yabai select window or space').manipulators([
      withModifier('option')({
        1: toYabai$('space --focus 1'),
        2: toYabai$('space --focus 2'),
        3: toYabai$('space --focus 3'),
        4: toYabai$('space --focus 4'),
        5: toYabai$('space --focus 5'),
        6: toYabai$('space --focus 6'),
        7: toYabai$('space --focus 7'),
        8: toYabai$('space --focus 8'),
        9: toYabai$('space --focus 9'),
        0: toYabai$('space --focus 10'),
        h: toYabai$('window --focus west'),
        j: toYabai$('window --focus south'),
        k: toYabai$('window --focus north'),
        l: toYabai$('window --focus east'),
        // f: toYabai$('window --toggle zoom-fullscreen'),
        z: toYabai$('window --toggle zoom-fullscreen'),
        m: toYabai$('window --toggle zoom-fullscreen'),
        f: toYabai$('space --toggle float'),
        // choose layout
        s: toYabai$('space --layout stack'),
        d: toYabai$('space --layout bsp'),
        b: toYabai$('space --balance'),
        '=': toYabai$('space --balance'),
        // flip and rotate
        x: toYabai$('space --mirror x-axis'),
        y: toYabai$('space --mirror y-axis'),
        r: toYabai$('space --rotate 270'),
      }),
    ]),
    rule('Yabai move window or space').manipulators([
      withModifier(['option', 'shift'])({
        1: toYabai$('window --space 1'),
        2: toYabai$('window --space 2'),
        3: toYabai$('window --space 3'),
        4: toYabai$('window --space 4'),
        5: toYabai$('window --space 5'),
        6: toYabai$('window --space 6'),
        7: toYabai$('window --space 7'),
        8: toYabai$('window --space 8'),
        9: toYabai$('window --space 9'),
        0: toYabai$('window --space 10'),
        h: toYabai$('window --swap west'),
        j: toYabai$('window --swap south'),
        k: toYabai$('window --swap north'),
        l: toYabai$('window --swap east'),
        s: toYabai$('window --toggle sticky --toggle float'),
      }),
    ]),
    rule('Yabai resize window').manipulators([
      withModifier(['option', 'control'])({
        h: toYabai$('window --resize right:-100:0'),
        j: toYabai$('window --resize bottom:0:100'),
        k: toYabai$('window --resize top:0:-100'),
        l: toYabai$('window --resize right:100:0'),
      }),
    ]),
  ]
}
