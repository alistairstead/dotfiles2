import { describe, expect, test } from "bun:test";
import {
  extractQuestionText,
  extractSpokenSentences,
  normalizeSpeech,
  stripMarkdown,
  wordCount,
  inRange,
  SPOKEN_MIN_WORDS,
  SPOKEN_MAX_WORDS,
} from "./speak-notification";

describe("wordCount", () => {
  test("counts words correctly", () => {
    expect(wordCount("hello world")).toBe(2);
    expect(wordCount("  spaced   out  ")).toBe(2);
    expect(wordCount("")).toBe(0);
  });
  test("does not count pure-punctuation tokens like em dash", () => {
    expect(wordCount("silence — no hiss")).toBe(3);
  });
});

describe("inRange", () => {
  test(`returns true for ${SPOKEN_MIN_WORDS}–${SPOKEN_MAX_WORDS}`, () => {
    expect(inRange(SPOKEN_MIN_WORDS)).toBe(true);
    expect(inRange(SPOKEN_MAX_WORDS)).toBe(true);
    expect(inRange(15)).toBe(true);
  });
  test("returns false outside range", () => {
    expect(inRange(SPOKEN_MIN_WORDS - 1)).toBe(false);
    expect(inRange(SPOKEN_MAX_WORDS + 1)).toBe(false);
  });
});

describe("stripMarkdown", () => {
  test("removes bold", () => {
    expect(stripMarkdown("**bold** text")).toBe("bold text");
  });
  test("removes inline code markers but keeps content", () => {
    expect(stripMarkdown("use `foo()` here")).toBe("use foo() here");
  });
  test("removes bullet points", () => {
    expect(stripMarkdown("- item one\n- item two")).toBe("item one\nitem two");
  });
  test("removes headings", () => {
    expect(stripMarkdown("## Title")).toBe("Title");
  });
});

describe("normalizeSpeech", () => {
  test("collapses newlines to spaces", () => {
    expect(normalizeSpeech("line one\nline two")).toBe("line one line two");
  });
  test("replaces em dash with placeholder", () => {
    expect(normalizeSpeech("before—after")).toContain("EM_DASH_PAUSE");
  });
  test("strips fenced code blocks", () => {
    expect(normalizeSpeech("here:\n```js\nconst x = 1;\n```\ndone")).toBe("here: done");
  });
  test("converts #number to 'number N'", () => {
    expect(normalizeSpeech("#137 is blocked by #142")).toBe("number 137 is blocked by number 142");
  });

  test("converts number/number to 'of'", () => {
    expect(normalizeSpeech("22/22 passing")).toBe("22 of 22 passing");
    expect(normalizeSpeech("3/5 tests")).toBe("3 of 5 tests");
  });

  test("converts word/word to 'of'", () => {
    expect(normalizeSpeech("pass/fail")).toBe("pass of fail");
  });

  test("strips markdown before collapsing newlines", () => {
    const input = "- item one\n- item two\n- item three";
    const result = normalizeSpeech(input);
    expect(result).not.toContain("\n");
  });
});

describe("extractSpokenSentences — punctuation-based", () => {
  test("returns first sentence when it is in range (13–17 words)", () => {
    // 15 words
    const msg = "This is a sentence with exactly fifteen words in it to test the range. And here is a second sentence.";
    const result = extractSpokenSentences(msg);
    expect(result).toBe("This is a sentence with exactly fifteen words in it to test the range.");
  });

  test("returns two sentences when combined falls in range", () => {
    // first sentence: 4 words. second sentence: 11 words → combined 15 words
    const msg = "Short intro here. This second sentence adds enough words to reach the target range.";
    const combined = extractSpokenSentences(msg);
    const count = wordCount(combined);
    expect(count).toBeGreaterThanOrEqual(SPOKEN_MIN_WORDS);
    expect(count).toBeLessThanOrEqual(SPOKEN_MAX_WORDS);
  });

  test("falls back to first sentence when nothing is in range", () => {
    // very long first sentence > 17 words
    const msg = "This is an extremely long first sentence that has way more than seventeen words and will not fit within the range at all. Short.";
    const result = extractSpokenSentences(msg);
    expect(result).toBe("This is an extremely long first sentence that has way more than seventeen words and will not fit within the range at all.");
  });
});

describe("extractSpokenSentences — colon-intro pattern", () => {
  test("truncates at line-ending colon and appends closing phrase", () => {
    const msg = "4 issues created in dependency order:\n\n- #142 — Scorer\n- #143 — Dataset";
    const result = extractSpokenSentences(msg);
    expect(result).toBe("4 issues created in dependency order, see screen for details");
  });

  test("strips trailing colon before appending closing phrase", () => {
    const result = extractSpokenSentences("Summary:");
    expect(result).not.toContain(":");
    expect(result).toContain("see screen for details");
  });

  test("mid-line colon does not trigger truncation", () => {
    const msg = "Two options: mocked or real. Which do you prefer?";
    const result = extractSpokenSentences(msg);
    expect(result).not.toContain("see screen for details");
  });
});

describe("extractSpokenSentences — bullet list (no punctuation)", () => {
  test("colon-terminated first line triggers see-screen pattern", () => {
    const msg = "All four issues created:\n\n- #137 — utility + tests (start here)\n- #138 — HTTP client speed transformation\n- #139 — Bill credit, line rental, incentive\n- #140 — Active offer section";
    const result = extractSpokenSentences(msg);
    expect(result).toBe("All four issues created, see screen for details");
  });

  test("colon-terminated intro with following lines also triggers see-screen pattern", () => {
    const msg = "Issues created:\n#137 utility tests blocked by none start here please review\n#138 client speed";
    const result = extractSpokenSentences(msg);
    expect(result).toBe("Issues created, see screen for details");
  });
});

// Full pipeline: stripMarkdown → extractSpokenSentences → normalizeSpeech
function pipeline(msg: string): string {
  return normalizeSpeech(extractSpokenSentences(stripMarkdown(msg)));
}

describe("pipeline — decimal numbers not split as sentences", () => {
  test("period between digits is not a sentence boundary", () => {
    // From log: "giving a 0.9s pause..." was cut at "giving a 0."
    const msg = "Done, giving a 0.9s pause between segments. Ready to proceed.";
    const result = pipeline(msg);
    expect(result).not.toMatch(/giving a 0\.$/);
    expect(result).toContain("0.9");
  });

  test("version numbers are not split", () => {
    const msg = "Updated to v2.0.1. Please restart.";
    const result = pipeline(msg);
    expect(result).toContain("2.0.1");
  });
});

describe("pipeline — slash as 'of'", () => {
  test("22/22 passes as '22 of 22 passing'", () => {
    // Exact last_assistant_message that produced '2222 passing' before the fix
    const msg =
      "22/22 passing. The colon-at-end-of-line now produces e.g. `\"4 issues created in dependency order, see screen for details\"` — mid-line colons pass through untouched.";
    expect(pipeline(msg)).toBe("22 of 22 passing.");
  });

  test("fraction-style counts are preserved as 'of'", () => {
    expect(pipeline("3/5 tests passed.")).toBe("3 of 5 tests passed.");
  });

  test("mid-sentence word/word reads as 'of'", () => {
    expect(pipeline("A pass/fail result was returned.")).toBe(
      "A pass of fail result was returned.",
    );
  });
});

describe("extractQuestionText", () => {
  test("returns null when no question", () => {
    expect(extractQuestionText("Just a statement.")).toBeNull();
  });

  test("extracts question lines", () => {
    const msg = "I did some work.\n\nDoes this look right?";
    const result = extractQuestionText(msg);
    expect(result).toContain("Does this look right?");
  });

  test("includes preceding context for short questions", () => {
    const msg = "I updated the function. Should I also update the tests?";
    const result = extractQuestionText(msg);
    expect(result).toContain("Should I also update the tests?");
  });
});
