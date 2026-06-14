# Enhancement Plan — Source Review Findings

> Review date: 2026-06-14 · Branch: `main`
> Scope: hand-written `lib/` code. Generated files (`*.g.dart`, `*.freezed.dart`,
> `*.gen.dart`, `*_localizations*.dart`, `objectbox.g.dart`, `firebase_options.dart`)
> were excluded. Reviewed in depth: auth + networking layer, sync engine wiring,
> router/redirect, DI/app shell, the largest presentation files, and the
> bookmarks/notifications/home blocs. Whole-tree pattern scans were also run.

## Baseline health (good)

- `dart analyze` — **no errors**.
- `fvm flutter test` — **all 226 tests pass**.
- No `print(`, no deprecated `withOpacity`, no `// TODO/FIXME/HACK` in
  hand-written code, no `firstWhere` without `orElse` on synchronous lists that
  could throw.

The issues below are refinements, not a broken app. They are ordered by severity.

---

## 1. Bugs / latent bugs

### 1.1 — `[Medium]` Pull-to-refresh can throw if the list bloc closes mid-refresh
**File:** `lib/features/bookmarks/presentation/widgets/bookmarks_list_widgets.dart:48-53`

```dart
Future<void> _reload() {
  final bloc = context.read<BookmarksListBloc>();
  final completion = bloc.stream.firstWhere((state) => !state.isLoading); // ← no orElse
  bloc.add(const BookmarksListLoadRequested());
  return completion.then((_) {});
}
```

`Stream.firstWhere` completes with an error if the stream closes before a match.
If the user navigates away (or the bloc is disposed) while a refresh is in
flight, this future throws an unhandled `StateError` inside
`RefreshIndicator.onRefresh`.

The sibling notifications code already handles exactly this case:
`lib/features/notifications/presentation/widgets/notifications_lists.dart:142-145`
uses `orElse: () => bloc.state` with an explanatory comment. The bookmarks path
is missing the same guard — an inconsistency that is also the bug.

**Fix:** add `orElse: () => bloc.state` (and `mounted` guards already exist on
the callers). Better: extract one shared "await bloc settle" helper so the safe
pattern can't drift again (see 3.3).

### 1.2 — `[Medium]` Home dashboard search only searches the *recent* subset, not the library
**File:** `lib/features/home/presentation/widgets/home_widgets.dart:137-160` (`_filterItems`)

The home search box and filter chips filter `state.recentItems` — the capped
"recent" slice surfaced on the dashboard — not the full bookmark library.
Searching for a title that exists but isn't in the recent slice shows the
"No matches" empty state (`homeNoMatches`), which reads as "you have no such
bookmark." `_SuggestedBookmarksSection` then further caps the result with
`.take(3)`, so even matching items may not render in the suggested row.

**Fix (pick one):**
- Route the query into the full bookmarks list (`BookmarksListRoute` with a
  query arg) on submit, treating the home box as an entry point; **or**
- Relabel the section/empty-state so it's clear the box filters *recent* items
  only, not the whole library.

---

## 2. UI / UX enhancements

### 2.1 — `[Medium]` Dashboard re-runs all entrance animations on every keystroke
**File:** `lib/features/home/presentation/widgets/home_widgets.dart:82-85`

```dart
_SearchSection(
  controller: _searchController,
  onChanged: (_) => setState(() {}),   // ← rebuilds the whole dashboard
)
```

`onChanged` calls `setState` on `_HomeBodyState`, which rebuilds the entire
`BlocBuilder` subtree — including every section wrapped in `.animateFadeIn` /
`.animateSlideUp`. Typing re-triggers the staggered entrance animations and
does redundant filtering work per character.

**Fix:** isolate the query into a `ValueNotifier<String>` (or a small dedicated
`StatefulWidget` around the search field + results) so only the result list
rebuilds, and/or debounce input (the bookmarks list already debounces 250ms —
`bookmarks_list_widgets.dart:35-40`). Gate the entrance animations to the first
build.

### 2.2 — `[Low]` Placeholder auth features advertise actions that do nothing
**File:** `lib/features/auth/presentation/screens/login_screen.dart:45-55, 220-234`

"Forgot password", "Continue with Google", and "Continue with Apple" render as
real buttons but only show a "not available" snackbar
(`_showPasswordRecoveryUnavailable`, `_showSocialUnavailable`). Acceptable as
template stubs, but as shipped UX they invite taps that dead-end.

**Fix:** either wire them, or hide them behind a feature flag / remove until
implemented, so the starter app's default screens have no dead controls.

---

## 3. Anti-patterns / maintainability

### 3.1 — `[Medium]` Magic tab index couples the shell to destination ordering
**File:** `lib/app/widgets/app_shell.dart:70-76`

```dart
onDestinationSelected: (index) {
  if (index == 2) {                 // ← "2" silently means "Notifications"
    getIt<NotificationsBloc>().add(const NotificationsLoadRequested());
  }
  ...
}
```

The notifications-refresh-on-tap relies on the hardcoded position `2` in the
`destinations` list built a few lines above. Reordering or inserting a
destination breaks the refresh with no compile error and no test failure.

**Fix:** drive the destinations from an `enum AppTab { home, bookmarks,
notifications, profile }` (or attach an `onSelected` callback / id to each
`AppDestination`) and compare against `AppTab.notifications.index` rather than a
literal.

### 3.2 — `[Low]` `firstWhere` on a stream without `orElse` during session restore
**File:** `lib/features/auth/presentation/auth_session.dart:34-41`

Same class of issue as 1.1. Lower risk here because `AuthBloc` is an
app-lifetime singleton that reliably emits a settled state after
`AuthSessionRestoreRequested`, but it's still an unguarded
`stream.firstWhere`. Add an `orElse` for symmetry with the safe pattern.

### 3.3 — `[Low]` Duplicated, divergent "await bloc settle" helpers
**Files:** `bookmarks_list_widgets.dart:_reload` vs
`notifications_lists.dart:_refresh` vs `auth_session.dart:restore`

Three copies of "fire an event, then await the stream until it settles," with
different names (`_reload` / `_refresh` / inline) and different safety (only one
has `orElse`). This duplication is what let bug 1.1 exist. Consolidate into a
single shared extension, e.g.:

```dart
extension BlocSettle<S> on Bloc<dynamic, S> {
  Future<S> settle(bool Function(S) isSettled) =>
      stream.firstWhere(isSettled, orElse: () => state);
}
```

### 3.4 — `[Low]` Naming nit: the plan file itself is misspelled
This file is `enhancement_pant.md` — almost certainly meant to be
`enhancement_plan.md`. Rename for clarity (say the word and I'll `git mv` it).

---

## 4. Minor / edge cases

- **`[Low]` Bookmark form image handling** —
  `bookmark_form_bloc.dart:117-139`: picked images are appended with no
  de-duplication, and `_onImageRemoved` removes by path with `..remove()`, which
  drops only the first match if the same path was added twice. Consider a
  `Set`-backed merge on add so remove is unambiguous.
- **`[Info]` Home filter keyword lists are English-only** —
  `home_widgets.dart:162-188`: filter `keywords` (`'design'`, `'article'`, …)
  are hardcoded English, so the chip filters won't match Vietnamese content even
  though the app is localized (`app_localizations_vi`). Acceptable for a
  template; flag if multi-locale filtering is a goal.

---

## Suggested order of work

1. **1.1** add the `orElse` guard (one line, removes a real crash path).
2. **3.1** replace the magic tab index with an enum.
3. **1.2 / 2.1** decide home-search scope, then fix the rebuild/animation churn.
4. **3.3** extract the shared `settle` helper and route 1.1 / 3.2 through it.
5. Polish: **2.2**, **3.4**, **4**.
