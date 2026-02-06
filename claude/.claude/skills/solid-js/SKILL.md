---
name: solid-js
description: Use when writing or reviewing SolidJS components, debugging reactivity issues like stale values or components not updating, or choosing between signals, stores, memos, and effects.
---

# SolidJS Idiomatic Patterns

## Overview

Components are **setup functions that run ONCE**. All reactive work happens in primitives (`createMemo`, `createEffect`, `<Show>`, `<For>`), not the component body. Access signals only inside reactive contexts (JSX, effects, memos).

## Reactivity

**Signals** — call as functions: `count()`. Functional updates when depending on old: `setCount(prev => prev + 1)`. Keep atomic (one per value). Use `{ equals: false }` for trigger signals. `batch()` for multi-signal updates outside event handlers.

**Derivations** — `() => count() * 2` for cheap. `createMemo(() => ...)` for expensive (caches). NEVER `createEffect(() => setX(y()))` — use memo. NEVER side effects in `createMemo`.

**Effects** — `createEffect` for side effects only (DOM, localStorage). `onCleanup()` inside for subscriptions/intervals. `on(dep, fn)` for explicit deps. `untrack(() => val())` to read without subscribing.

**Stores** — `createStore` for nested objects. Path syntax: `setStore("users", 0, "name", "Jane")`. Wrap for `on()`: `on(() => store.val, fn)`. `produce(draft => { ... })` for complex mutations. Beware: `JSON.stringify(store)` in effects may not track deep paths — access each leaf explicitly.

## Props

Access via `props.x` — NEVER destructure `({ x })` (breaks reactivity). Don't mirror props into signals expecting sync — read `props.x` in JSX/effects directly. Seeding a signal from a prop for local mutation is fine. `splitProps` to separate local/pass-through. `mergeProps(defaults, props)` for defaults. `children(() => props.children)` only when transforming.

## Control Flow

`<For each={list()}>` for objects (item=value, index=signal). `<Index>` for primitives (item=signal, index=number). `<Show when={cond()} fallback={...}>` for conditionals — callback `{(v) => ...}` for type narrowing. `<Switch>/<Match>` for multi-branch. NEVER `.map()` in JSX.

**Async** — `createResource(source, fetcher)` for data. `<Suspense fallback={...}>` for loading (not `<Show when={!loading}>`). `<ErrorBoundary fallback={(err, reset) => ...}>` for render errors. Access: `data()`, `data.loading`, `data.error`, `data.latest`.

## JSX

`class` not `className`. Static `class="btn"` + reactive `classList={{ active: isActive() }}` — never mix `class={x()}` with `classList`. `onClick` delegated; `on:click` native. `style={{ "--var": val() }}`. Refs: read in `onMount`/effects, type `let el: HTMLElement | undefined`. `use:directive={accessor}` with `onCleanup` inside.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Destructuring props | `props.x` or `splitProps` |
| Mirroring props to signal for sync | Read `props.x` directly in JSX/effects |
| `createEffect` to derive state | `createMemo` or derived fn |
| `.map()` in JSX | `<For>` / `<Index>` |
| `className` | `class` |
| `<Show when={!loading}>` for async | `<Suspense>` |
| Side effects in `createMemo` | `createEffect` |
| `on(store.val, fn)` | `on(() => store.val, fn)` |
| Reading ref in component body | `onMount` or effect |
| `JSON.stringify(store)` in effect | Access each leaf explicitly |
