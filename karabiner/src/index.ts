import { rule, map, writeToProfile } from 'karabiner.ts'
// import { raycastLayer } from './layers/raycast'
import { yabaiLayer } from './layers/yabai'
import { hyperLayer } from './layers/hyper'
// import { openLayer } from './layers/open'
// import { emojiLayer } from './layers/emoji'
// import { appsMapping } from './apps'
// import { vimLayer } from './layers/vim'
import { homerow } from './homerow'

writeToProfile(
  'Default profile',
  [
    rule('Caps Lock → Control || Escape').manipulators([
      map('caps_lock').to('left_control').toIfAlone('escape'),
    ]),
    rule('Cmd + Caps Lock → Hyper').manipulators([
      map('caps_lock', 'command').toHyper(),
    ]),
    // rule('Spacebar → Hyper || Space').manipulators([
    //   map('spacebar')
    //     .toIfHeldDown('left_command', ['⌥', '⌃', '⇧'])
    //     .toIfAlone('spacebar'),
    // ]),
    // rule('Command → Space').manipulators([
    //   map({
    //     key_code: 'spacebar',
    //     modifiers: { mandatory: ['command'] },
    //   }).to({
    //     key_code: 'backslash',
    //     modifiers: [
    //       'left_shift',
    //       'left_control',
    //       'left_option',
    //       'left_command',
    //     ],
    //   }),
    // ]),
    // ...openLayer(),
    // ...emojiLayer(),
    // ...raycastLayer(),
    ...yabaiLayer(),
    // ...vimLayer(),
    // ...appsMapping(),
    ...homerow(),
    ...hyperLayer(),
  ],
  {
    // 'basic.to_if_alone_timeout_milliseconds': 500,
    // 'basic.to_if_held_down_threshold_milliseconds': 250,
    // 'basic.to_delayed_action_delay_milliseconds': 100,
    // 'mouse_motion_to_scroll.speed': 100,
    // 'duo_layer.threshold_milliseconds': 50,
    // 'duo_layer.notification': true,
  },
)
