# Portfolio site — context for Claude Code

Everything needed to work on and deploy **sanawarmalik.com**.
Owner: Sanawar Javaid (GitHub `@sanawarjm`, sanawar.j@gmail.com).

---

## 1. Where everything lives

| Thing | Value |
|---|---|
| Working folder | `C:\Users\Owner\OneDrive\Desktop\portfolio-site` |
| GitHub repo | `github.com/sanawarjm/portfolio` (branch `main`) |
| Vercel team | `vercel.com/sanawarjm` (Hobby plan) |
| Vercel project | `sanawarjm` → `vercel.com/sanawarjm/sanawarjm` |
| Live site | https://sanawarmalik.com (and `www.`) |
| Fallback URL | https://sanawarjm.vercel.app |
| Registrar + DNS | Cloudflare |

**Deploy chain:** push to `main` → Vercel builds automatically → live in ~30s.
There is no CI, no tests, no build step.

### Your job that nobody else can do

Claude Code runs on the local machine with real git credentials, so **you can push**.
Previous sessions (cloud-sandboxed) could not, which is why this doc exists.

After editing, do:

```
git add -A
git commit -m "<what changed>"
git push
```

Then confirm the deploy went green at
`https://vercel.com/sanawarjm/sanawarjm/deployments`.

There is also a `publish.bat` in the folder that does the same three commands.

---

## 2. What the site is

A **single static page**. No framework, no dependencies, no build step, no
`package.json`. Vercel's framework preset is deliberately set to **Other** with
no build command — it just serves the files.

```
portfolio-site/
├── index.html      ~1430 lines — ALL markup, CSS and JS in one file
├── img/            93 files (91 .jpg, 2 .mp4) ≈ 12 MB
├── README.md
├── .gitignore
└── publish.bat
```

`index.html` is the entire site. Do not split it into separate CSS/JS files
without being asked — single-file is intentional.

### Structure of index.html

1. `<title>`, Google Fonts `<link>`, then one big `<style>` block
2. `<nav>`
3. Seven view containers, one visible at a time
4. `<footer>`
5. One `<script>` with an IIFE: router + carousels

### Views and routing

Hash-based. Only one `#view-*` div is visible; the rest carry `hidden`.

```js
var views   = ['home','cleo','unlockable','audio-scale','airport','wastewater','life'];
var anchors = { intro:1, experience:1, projects:1, outside:1, contact:1 };
```

- A hash matching `views` → `setView()` swaps which container is shown, scrolls to top.
- A hash matching `anchors` → stays on home, smooth-scrolls to that section.
- Nav clicks `preventDefault()` and glide **only when already on home**; otherwise
  they fall through to normal hash navigation so the router handles the view swap.

Home sections in DOM order: hero → `#intro` → Cleo feature panel → `#projects`
(gallery) → `#experience` → `#outside` (teaser) → `#contact`.

`#view-life` is the "Outside of work" page, reached from the teaser's *See the rest* link.

### Project order — fixed, do not reorder

**Cleo → Unlockable → Audio Scale → Airport Baggage System → Wastewater Filtration.**

Applies to the gallery cards, the nav dropdown, and the `views` array. The user
asked for this explicitly.

---

## 3. Design system

Pure black, white text, **no accent colour anywhere**. Modelled on a reference
portfolio the user chose. Earlier versions used orange and bordered tables; he
rejected both.

```css
--bg:#000;  --ink:#fff;
--soft:rgba(255,255,255,.80);
--muted:rgba(255,255,255,.58);
--dim:rgba(255,255,255,.38);
--serif:"EB Garamond",Georgia,serif;   /* letterspaced caps, italic ledes */
--sans:"Jost","Helvetica Neue",Arial;  /* light geometric, body + headings */
--wrap:1240px;                          /* .wrap.narrow = 860px */
```

**Hard rules, learned from feedback:**

- No accent colour, no coloured text, no coloured backgrounds
- **No boxes, borders, cards or table borders.** Data uses `.facts` (a label/value
  grid), never a bordered table
- Eyebrow labels are uppercase + letterspaced; body copy is sentence case
- Carousel captions are sentences (`text-transform:none`), unlike `.prose figcaption`
  which is uppercase

### Image alignment — the thing he cares most about

He asked for this repeatedly. **Every image in a row must share a box of the same
shape**, so tops, bottoms and captions land on one line.

| Context | Ratio | Fit |
|---|---|---|
| `.figrow` (default) | 16/10 | `cover` |
| `.figrow figure.doc` | 16/10 | `contain` — charts/scans shown whole |
| `.figrow.four` (phone screenshots) | 9/16 | `contain` |
| `.life .life-row` (Outside of work) | 4/5 | `cover` |
| `.collage-grid` (Everything else) | 1/1 | `cover` |
| Gallery `a.gal .shot` | 16/10 | `cover` / `contain` for `.doc` |
| Carousel, non-`.tall` | 4/3 | `contain` |
| Carousel `.tall` | 3/4 | `cover` |

Letterboxing from `contain` is invisible on black, which is why boxes stay uniform
rather than cropping.

Two supporting tricks:

- `a.gal p:not(.when){flex:1 0 auto}` — gallery cards are flex columns and the
  blurb absorbs slack, so pictures start at the same height regardless of text length
- `.collage` (intro) uses `grid-template-rows:1fr 1fr; height:100%` with
  `align-items:stretch` on `.intro-grid`, so the photo block starts and ends exactly
  level with the paragraph text beside it

**If you change copy length or add images, re-check alignment.**

### Carousels

Scroll-snap, no library. `[data-carousel]` → `.track` + prev/next/counter/rail.
Non-obvious bits, each fixing a real bug — don't undo them:

- `.track{position:relative}` so `offsetLeft` measures from the track
- `off(i)` clamps to `maxScroll()` so the last slide in a peeking (`.tall`) strip
  is reachable and the strip ends **flush** with no trailing black gap
- `.carousel.tall .track > figure:last-child{scroll-snap-align:end}` — required,
  or mandatory snapping drags the last slide back
- `settleAt` timestamp lock: scroll events fire throughout a smooth scroll and
  would otherwise reset the index mid-animation
- `sync()` re-runs on `window.load`, `resize`, each late `img.load`, and a
  `ResizeObserver` — without these the Next button starts disabled

---

## 4. Image naming

| Prefix | Belongs to |
|---|---|
| `cleo-*` | Cleo (`b01`–`b10` = 72-hour build sequence, in order) |
| `ul-*` | Unlockable (`01`–`10` = demo sequence; `ul-app-*` = phone app) |
| `as-*` | Audio Scale |
| `ap-*` | Airport baggage |
| `ww-*` | Wastewater |
| `ow-*` | Outside of work, section photos |
| `cg-*` | Outside of work, bottom collage (incl. `cg-chip.mp4`, `cg-ride.mp4`) |
| `hero-`, `gallery-bg`, `feature-bg` | Backgrounds |

**No photo appears twice on the Outside of work page** — 16 in the four sections,
23 in the collage, each file used once. He asked for this specifically. If you add
or move one, keep that invariant.

---

## 5. Facts that are verified — don't "correct" them

- **Unlockable lockout is 60 seconds.** The demo photo `ul-06-locked.jpg` shows the
  LCD reading `SYSTEM LOCKED / Time: 59s`. All prose says sixty.
  ⚠️ **Known inconsistency:** the hand-drawn FSM diagram (`ul-fsm.jpg`) still reads
  "Wait 30 Seconds". The image needs redrawing, or the caption needs a note. The
  user knows and hasn't decided.
- Unlockable: six-state Mealy FSM, ESP32, 4-digit PIN, 3 attempts, 250 ms debounce,
  servo on pin 26, DFRobot RGB LCD1602 over I²C at 0x6B
- Cleo: BearHacks 2026, 72 hours, with teammate **Angelo**, Raspberry Pi,
  MobileNet SSD + Whisper running locally
- Wastewater: decision matrix coir fibre 19 / cement 10 / concrete 9;
  eco-audit transport = 94.6% of energy, 93.9% of CO₂

---

## 6. Privacy decisions — preserve these

Deliberate, not oversights:

- **Audio Scale client is never named**, and her condition is never stated. The site
  says "a client with combined vision and hearing loss" / "our client". Keep it that way.
- **Phone number is deliberately omitted** from the public site
- Student number stripped from all filenames
- A garage photo with bystanders including a child was excluded
- Teammate's username cropped out of the Inventor screenshot

---

## 7. Writing voice

First person, plain, concrete, a bit dry. The user rewrote the About section himself
— **that copy is his, verbatim; don't touch it unless asked.**

Avoid AI tells, which he has flagged twice:

- No em dashes
- No "not X but Y" constructions
- No forced triads
- No inflated significance or one-line dramatic closers
- No bold used as decoration

Captions stay short and factual. **Never invent a location, date or claim from a
photo.** Past mistakes: captioning a Peru hillside as a named valley, and asserting
he was "better at volleyball". When unsure, describe only what's visibly there.

---

## 8. Infrastructure gotchas

**Cloudflare DNS — proxy must stay OFF.** Both records are CNAMEs to
`1a543cd72fa6ada9.vercel-dns-017.com` at **DNS only** (grey cloud):

```
CNAME  @     1a543cd72fa6ada9.vercel-dns-017.com   DNS only
CNAME  www   1a543cd72fa6ada9.vercel-dns-017.com   DNS only
```

Cloudflare shows a yellow banner nudging you to enable proxying. **Ignore it.**
Turning on the orange cloud breaks Vercel's domain validation and certificate renewal.

**The apex is primary.** `sanawarmalik.com` is the canonical address, both pointing
at Production. Vercel's default is the reverse (apex redirects to www) — it was
deliberately flipped, because the bare domain reads better on a resume. If a Vercel
dialog re-checks "Redirect apex domains to www", uncheck it.

**Rollback:** every past deployment is kept. On the Deployments page, use
*Promote to Production* on the last good one.

**Branches get preview URLs.** Push a branch instead of `main` to test something
without touching the live site.

**Repo visibility:** the user wants it **private**. As of writing it is still public
— the GitHub visibility dialog was misbehaving and the adjacent buttons archive and
delete the repo, so it was left alone rather than risked. If it's still public,
flip it at `github.com/sanawarjm/portfolio/settings` → Danger Zone. Vercel keeps
deploying from private repos fine.

---

## 9. Checks worth running before pushing

There's no test suite, so verify by rendering. Playwright against a local file works well.

1. **No broken images** — `[...document.images].filter(i => !i.complete || i.naturalWidth === 0)`
2. **Row alignment** — for each `.figrow` / `.life-row`, image tops, bottoms and
   caption tops should have zero spread within a visual row
3. **Carousels reach the end** — click Next until disabled; counter should read
   `10 / 10` and `scrollLeft === maxScroll` with no trailing gap
4. **No horizontal overflow** — `document.documentElement.scrollWidth` must equal
   `clientWidth` at 390px, 900px and 1440px, on every view
5. **No console errors**
6. **Nav dropdown** — hovering Projects shows five links; it's hidden below 820px
   and on touch by design

The Google Fonts request fails offline, which shows as one console error when
testing from `file://`. That one is expected.

---

## 10. Recent history

Built over several sessions. Notable decisions already made and settled:

- Version 1–2 were rejected as "too AI" (orange scheme, bordered tables)
- Version 3 onward: black, serif/sans pairing, no boxes — approved, keep it
- Project gallery was moved above work experience
- Carousels added so build photos follow real project timelines
- "Outside of work" split into a short home teaser plus a full `#life` page
- Deployed via drag-and-drop first, then moved to Git-backed auto-deploy
- Vercel team renamed from "Subeo" to "sanawarjm" (it's his own team, not an org —
  Vercel won't let you delete your last Hobby team, so renaming was the only option)
