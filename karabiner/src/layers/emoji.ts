import { duoLayer, map, toKey, toPaste, withMapper } from 'karabiner.ts'
import { toRaycastExt$ } from './raycast'

export function emojiLayer() {
  // See https://gitmoji.dev/
  let emojiMap = {
    b: '🐛', // Fix a bug
    c: '🔧', // add or update Configuration files
    d: '📝', // add or update Documentation
    f: '🚩', // add, update, or remove Feature Flags
    h: '💯', // _hundred
    j: '😂', // _joy
    m: '🔀', // Merge branches
    n: '✨', // introduce New features
    p: '👍', // _plus_one +1
    r: '♻️', // Refactor code
    s: '😅', // _sweat_smile
    u: '⬆️', // Upgrade dependencies
    v: '🔖', // release / Version tags

    t: '🛠️', // Tools
    k: '📚', // Knowledge learnt
    o: '💭', // Opinions and thoughts
    i: '👨‍💻', // Experiences and stories
  }

  let emojiHint = Object.entries(emojiMap)
    .slice(0, 15)
    .reduce(
      (r, [k, v]) => [r[0].concat(v), r[1].concat(k.toUpperCase())],
      [[] as string[], [] as string[]],
    )
    .map((v, i) => v.join(i === 0 ? ' ' : '    '))
    .join('\n')

  return [
    duoLayer('z', 'x')
      .notification(emojiHint)
      .manipulators([
        map(';').to(
          toRaycastExt$('raycast/emoji-symbols/search-emoji-symbols'),
        ),

        withMapper(emojiMap)((k, v) => map(k).toPaste(v)),

        { 2: toPaste('⌫'), 3: toPaste('⌦'), 4: toPaste('⇥'), 5: toPaste('⎋') },
        { 6: toPaste('⌘'), 7: toPaste('⌥'), 8: toPaste('⌃'), 9: toPaste('⇧') },
        { 0: toPaste('⇪'), ',': toPaste('‹'), '.': toPaste('›') },

        withMapper(['←', '→', '↑', '↓', '␣', '⏎', '⌫', '⌦'])((k) =>
          map(k).toPaste(k),
        ),

        // Code snippets
        map('l').toTypeSequence('console.log()←'),
        map("'").toTypeSequence('⌫"'),
        map('[').toTypeSequence('[␣]␣'),
        map(']').toTypeSequence('-␣[␣]␣'),

        { "'": toKey('⌫'), '\\': toKey('⌦') },
      ]),
  ]
}
