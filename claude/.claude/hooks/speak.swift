import AVFoundation
import Foundation

// Usage: speak [-v voice_id] [-r rate_multiplier] <text...>
// Falls back to best available neural voice if specified voice not found

var voiceId: String?
var rateMultiplier: Float = 0.95
var textParts: [String] = []

var args = Array(CommandLine.arguments.dropFirst())
var i = 0
while i < args.count {
    switch args[i] {
    case "-v" where i + 1 < args.count:
        voiceId = args[i + 1]
        i += 2
    case "-r" where i + 1 < args.count:
        rateMultiplier = Float(args[i + 1]) ?? 0.95
        i += 2
    default:
        textParts.append(args[i])
        i += 1
    }
}

let text: String
if textParts.isEmpty {
    text = (try? String(contentsOf: URL(fileURLWithPath: "/dev/stdin"), encoding: .utf8)) ?? ""
} else {
    text = textParts.joined(separator: " ")
}

guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { exit(0) }

let synth = AVSpeechSynthesizer()
let utterance = AVSpeechUtterance(string: text)

// Try requested voice, then premium/enhanced voices in preference order
var selectedVoice: AVSpeechSynthesisVoice?
let fallbackIds = [
    "com.apple.voice.premium.en-GB.Jamie",
    "com.apple.voice.premium.en-GB.Serena",
    "com.apple.voice.enhanced.en-GB.Oliver",
    "com.apple.voice.enhanced.en-GB.Kate",
]

if let id = voiceId, let v = AVSpeechSynthesisVoice(identifier: id) {
    selectedVoice = v
}
if selectedVoice == nil {
    for id in fallbackIds {
        if let v = AVSpeechSynthesisVoice(identifier: id) {
            selectedVoice = v
            break
        }
    }
}
utterance.voice = selectedVoice ?? AVSpeechSynthesisVoice(language: "en-US")

utterance.rate = AVSpeechUtteranceDefaultSpeechRate * rateMultiplier
utterance.pitchMultiplier = 1.0
utterance.volume = 0.9

class Delegate: NSObject, AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synth: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        exit(0)
    }
}

let delegate = Delegate()
synth.delegate = delegate
synth.speak(utterance)
RunLoop.main.run()
