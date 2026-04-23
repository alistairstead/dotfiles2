#!/usr/bin/env bun

import { type HookPayload } from "./hooks-shared";
import { speak } from "./speak-notification";
import { notify } from "./notification";

async function main(): Promise<void> {
  const inputData = await Bun.stdin.text();
  if (!inputData.trim()) process.exit(0);

  let payload: HookPayload;
  try {
    payload = JSON.parse(inputData);
  } catch {
    process.exit(1);
  }

  await Promise.allSettled([speak(payload), notify(payload)]);
  process.exit(0);
}

if (import.meta.main) {
  main().catch(() => process.exit(1));
}
