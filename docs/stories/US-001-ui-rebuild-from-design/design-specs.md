

## Onboarding · Welcome  (frame iSk1U)

**Purpose:** First screen of the onboarding flow. Introduces the app name/brand, shows three key feature highlights, and drives the user forward with a primary CTA. There is no data dependency — this screen is fully static content. It corresponds to page index 0 (id 0) in the existing OnboardingView page array, replacing the current minimal singleIconHero layout with a richer, self-contained welcome page design.

**Layout:**
Frame: 393 × 852 pt, cornerRadius 40, clip true. Background: linear gradient, rotation 205°, stops: #FBF8F0 at 0%, #EEECE6 at 55%, #DAD3C4 at 100% — no ScaffoldBackground(), no AnimatedBackground(), raw gradient fill applied directly to the outermost container.

Root container: VStack(spacing: 0), fills frame, layout vertical.

─── 1. Status Bar (qbNdR) ───
  Height: 62 pt, width: fill, padding horizontal 28.
  HStack, justifyContent: space_between, alignItems: center.
  Left: Text "9:41", .appSans(size:16, weight:.semibold), color appTextDark (#171717).
  Right: HStack(spacing: 7), three icons each 18×18 (signal, wifi) and 24×18 (battery-full), all filled #171717.
  Note: in production replace with a real iOS status bar passthrough; this node is the design stand-in.

─── 2. Content VStack (tODTi) ───
  VStack(spacing: 16), width fill, height fill_container (takes remaining space).
  Padding: top 0, trailing 20, bottom 20, leading 20.

  ── 2a. Step Row (PjwU2) ──
    HStack, width fill, justifyContent: space_between, alignItems: center.
    Left:  Text "BƯỚC 1 / 4", .appSans(size:10, weight:.heavy), color #7A7166, letterSpacing 1.5.
    Right: Text "Bỏ qua",     .appSans(size:13, weight:.bold),  color #7A7166. Tappable — skip action.

  ── 2b. Hero Section (CoHd5) ──
    VStack(spacing: 18), width fill.
    Padding: top 24, bottom 8 (leading/trailing 0).
    Alignment: center.

    [Badge (leyn4)]
      Width 96, height 96, cornerRadius 28, fill #FFE9B0.
      Border: stroke #00000010, strokeWidth 1.
      Center-aligned, contains:
        Lucide icon "car-front", 46×46, fill #7A4A00.

    [HText (KBE5a)]
      VStack(spacing: 8), width fill, layout vertical, alignment center.
      Title: Text "Ôn Thi Lái Xe 2026"
        .appSans(size:26, weight:.heavy), fill #171717 (appTextDark).
        letterSpacing -0.5, lineHeight 1.1, textAlign center, width fill.
      Sub: Text "Người bạn đồng hành giúp bạn tự tin vượt qua kỳ thi lý thuyết."
        .appSans(size:14, weight:.medium), fill #7A7166 (appTextMedium-warm).
        lineHeight 1.4, textAlign center, width fill, fixed-width growth.

  ── 2c. Features List (nDTWG) ──
    VStack(spacing: 10), width fill, layout vertical.
    Padding: top 8 (leading/trailing/bottom 0).
    Three feature row cards stacked vertically, each full-width.

    [Card 1 — yqVEl: "1.200+ câu hỏi"]
      HStack(spacing: 12), alignItems: center, width fill.
      cornerRadius 20, fill #FFFFFFCC (white 80% opacity), stroke #00000014 strokeWidth 1.
      Padding: 10 all sides.
      Left box (N3qMxS): 42×42, cornerRadius 10, fill #E9F0FA (light blue).
        Center: Lucide "book-open-text" 21×21, fill #143A75 (dark blue).
      Right text (Ttzj2): VStack(spacing: 2), layout vertical, width fill.
        Title: "1.200+ câu hỏi"  .appSans(size:14.5, weight:.heavy), fill #0F0F12.
        Desc:  "Đầy đủ bộ đề thi mới nhất 2026"  .appSans(size:11.5, weight:.semibold), fill #7A7166, lineHeight 1.3, fixed-width.

    [Card 2 — Y1Nrp: "Thi thử sát đề thật"]
      HStack(spacing: 12), alignItems: center, width fill.
      cornerRadius 20, fill #FFFFFFCC, stroke #00000014 strokeWidth 1.
      Padding: 10 all sides.
      Left box (dve6D): 42×42, cornerRadius 10, fill #FFE9B0 (light amber).
        Center: Lucide "clipboard-check" 21×21, fill #7A4A00 (dark amber).
      Right text (iyHkQ): VStack(spacing: 2), width fill.
        Title: "Thi thử sát đề thật"  .appSans(size:14.5, weight:.heavy), fill #0F0F12.
        Desc:  "Mô phỏng đúng cấu trúc 25 câu"  .appSans(size:11.5, weight:.semibold), fill #7A7166, lineHeight 1.3, fixed-width.

    [Card 3 — g2pREN: "Mô phỏng tình huống"]
      HStack(spacing: 12), alignItems: center, width fill.
      cornerRadius 20, fill #FFFFFFCC, stroke #00000014 strokeWidth 1.
      Padding: 10 all sides.
      Left box (kxF1b): 42×42, cornerRadius 10, fill #E7F5EC (light green).
        Center: Lucide "video" 21×21, fill #1E6B3A (dark green).
      Right text (zkO5B): VStack(spacing: 2), width fill.
        Title: "Mô phỏng tình huống"  .appSans(size:14.5, weight:.heavy), fill #0F0F12.
        Desc:  "120 tình huống giao thông thực tế"  .appSans(size:11.5, weight:.semibold), fill #7A7166, lineHeight 1.3, fixed-width.

  ── 2d. Spacer ──
    height: fill_container — pushes CTA to the bottom.

  ── 2e. Continue Button (NX3lP) ──
    Width fill, height 50, cornerRadius 25, fill #D4714E (appPrimary).
    HStack(spacing: 8), justifyContent: center, alignItems: center.
    Label: Text "Bắt đầu", .appSans(size:15, weight:.bold), fill white.
    Icon: Lucide "arrow-right" 16×16, fill white.
    Placed at the bottom of Content VStack; bottom padding via parent (bottom 20).

**Tokens:** Background gradient: literal stops #FBF8F0 → #EEECE6 → #DAD3C4 at 205° rotation — no app token covers this warm parchment gradient; use a local Color extension or inline LinearGradient.

App tokens used:
- appPrimary (#D4714E) — CTA button fill, ThemeStore.primaryColor
- appTextDark (#171717) — app title, status bar time
- appTextMedium (#737373) — subtitle, step label, skip label, card descriptions (note: design uses #7A7166 which is a warm-tinted medium; map to appTextMedium or define a local warmMedium token)
- cardBg (#FAF9F7) — close but card fill is #FFFFFFCC (white 80%); use Color.white.opacity(0.8) directly

Feature icon box fills (no existing token):
- Blue box:   #E9F0FA bg, #143A75 icon
- Amber box:  #FFE9B0 bg, #7A4A00 icon — same amber as badge
- Green box:  #E7F5EC bg, #1E6B3A icon

Card stroke: Color.black.opacity(0.08) — literal, no token
Badge stroke: Color.black.opacity(0.063) — literal
Step/skip color: #7A7166 — warm gray, no exact token; use appTextMedium or local constant

Fonts:
- Step label: .appSans(size: 10, weight: .heavy)  — use Font.Weight.black for "800"
- Skip label: .appSans(size: 13, weight: .bold)
- App title:  .appSans(size: 26, weight: .heavy)
- Subtitle:   .appSans(size: 14, weight: .medium)
- Card title: .appSans(size: 14.5, weight: .heavy)  — round to 14 or 15 if needed
- Card desc:  .appSans(size: 11.5, weight: .semibold) — round to 12 if needed
- CTA label:  .appSans(size: 15, weight: .bold)

Spacing tokens: 8, 10, 12, 16, 18, 20 (standard multiples)

**Reuse widgets:** AppButton(icon: "arrow.right", label: "Bắt đầu", style: .primary, height: 50) — reuse for the CTA; note AppButton uses SF Symbols while design uses Lucide arrow-right; keep SF Symbols for production, IconBox — reuse for the three feature icon boxes; set size:42, cornerRadius:10, iconFontSize:21 with appropriate color per row, AnimatedBackground — NOT used; the screen has its own explicit warm parchment gradient, do not apply ScaffoldBackground or AnimatedBackground

**New widgets:**
- OnboardingWelcomeView: View — self-contained SwiftUI view for this screen; takes onContinue: () -> Void and onSkip: () -> Void callbacks; owns no state beyond what it renders; placed as page 0 inside OnboardingView's TabView replacing the current OnboardingPageView(page: pages[0]) usage
- OnboardingFeatureRow: View — reusable row card for one feature highlight; init(boxColor: Color, iconColor: Color, iconName: String, title: String, description: String); renders HStack with an IconBox on the left and a two-line VStack on the right; cornerRadius 20, fill Color.white.opacity(0.8), stroke Color.black.opacity(0.08), padding 10, full-width; used three times inside OnboardingWelcomeView
- OnboardingAppBadge: View — the branded icon badge above the title; 96×96 rounded rect (cornerRadius 28), fill #FFE9B0, stroke Color.black.opacity(0.063); contains a Lucide/SF car icon (use SF "car.fill" at size 46) in color #7A4A00; no external params needed for page 1

**Copy:**
- 9:41
- BƯỚC 1 / 4
- Bỏ qua
- Ôn Thi Lái Xe 2026
- Người bạn đồng hành giúp bạn tự tin vượt qua kỳ thi lý thuyết.
- 1.200+ câu hỏi
- Đầy đủ bộ đề thi mới nhất 2026
- Thi thử sát đề thật
- Mô phỏng đúng cấu trúc 25 câu
- Mô phỏng tình huống
- 120 tình huống giao thông thực tế
- Bắt đầu

**States:** populated: only state — all content is static, no loading/empty/error variants. The CTA button is always enabled. The "Bỏ qua" label is always visible on this page (current page is 0, not the last page). No disabled state required for this screen in isolation. The outer OnboardingView manages currentPage state and passes callbacks; this view is purely presentational.

**Interactions:** Tap "Bỏ qua" (Skip): calls onSkip() → triggers completeOnboarding() in OnboardingView, setting hasCompletedOnboarding = true and dismissing the onboarding flow. Tap "Bắt đầu" CTA: calls onContinue() → OnboardingView advances currentPage from 0 to 1 with spring animation (.spring(duration: 0.3)). No gestures, sheets, or navigation pushes originate from this screen directly — all navigation is owned by the parent OnboardingView TabView pager. No scroll; the layout is a fixed single-screen composition.

**Notes:** Existing code file: GPLX2026/Features/Onboarding/OnboardingPageView.swift and OnboardingView.swift. The current OnboardingView already handles the 7-page TabView flow; page id 0 uses OnboardingPageView with a singleIconHero. The rebuild strategy is: (1) extract OnboardingWelcomeView as its own file at GPLX2026/Features/Onboarding/OnboardingWelcomeView.swift; (2) in OnboardingView, replace the page.id == 0 branch inside the ForEach to render OnboardingWelcomeView instead of OnboardingPageView; (3) the warm parchment gradient background must be applied per-page (not the global .glassBackground() call on OnboardingView) — either pass a background through the TabView using .containerBackground or layer the gradient inside OnboardingWelcomeView itself behind the content. The status bar node in the design (qbNdR) is a placeholder; in SwiftUI use .statusBarHidden(false) and set preferredColorScheme to determine icon tint — do not render a custom status bar. The "BƯỚC 1 / 4" step indicator and "Bỏ qua" skip row replace the existing top HStack skip button pattern in OnboardingView for this page — the step counter must be driven by currentPage + 1 and pages.count from the parent. Card fill is #FFFFFFCC (white at ~80% alpha), not the cardBg token; this gives the frosted-tile look against the warm gradient without using .glassCard(). The design uses Lucide icons; the project does not ship the Lucide font in production — map to the nearest SF Symbols: "book-open-text" → "book.fill", "clipboard-check" → "checkmark.clipboard.fill", "video" → "play.circle.fill", "arrow-right" → "arrow.right", "car-front" → "car.fill". Font weight "800" maps to Font.Weight.heavy in .appSans calls.


## Onboarding · Experience level  (frame Q60B4)

**Purpose:** Step 2 of 4 in the onboarding flow. Collects the user's current study experience level so the app can personalise content recommendations. Three mutually exclusive option cards are presented; tapping one selects it and the "Tiếp tục" button advances to step 3.

**Layout:**

Full-screen frame: 393 × 852 pt, cornerRadius 40, clipped.
Background: linear gradient (205°) — #FBF8F0 at 0% → #EEECE6 at 55% → #DAD3C4 at 100%.

VStack(spacing: 16), layout: vertical, padding: top 0 / leading 20 / bottom 20 / trailing 20, fills remaining height.

── 1. STATUS BAR (id: g3L844)
   HStack, height 62, padding horizontal 28, justifyContent: space_between.
   • Left: Text "9:41", #171717, Be Vietnam Pro 16/600.
   • Right: HStack(gap 7) — signal icon 18×18, wifi icon 18×18, battery-full icon 24×18, all #171717.

── 2. STEP ROW (id: xW0DQ)
   HStack fill_container, justifyContent: space_between.
   • Left: Text "BƯỚC 2 / 4", #7A7166, 10pt, weight 800, letterSpacing 1.5.
   • Right: Text "Bỏ qua", #7A7166, 13pt, weight 700 — tappable skip button.

── 3. HEADER VSTACK (id: s9lA2Y)
   VStack(gap 6), fill_container.
   • Title: "Bạn đã ôn tới đâu rồi?", #171717, 26pt, weight 800, letterSpacing −0.5, lineHeight 1.1, fixed-width fill.
   • Subtitle: "Chọn mức độ để chúng tôi gợi ý nội dung phù hợp với bạn.", #7A7166, 14pt, weight 500, lineHeight 1.4, fixed-width fill.

── 4. OPTIONS VSTACK (id: WrEMV)
   VStack(gap 10), fill_container, layout vertical, top padding 6.
   Contains three ExperienceLevelCard instances (see new widgets).

   4-A. Card "Mới bắt đầu" (id: qgyg5) — UNSELECTED style
        cornerRadius 20, fill #FFFFFFCC, gap 14, padding 10, stroke #00000014 1 pt.
        HStack(alignItems: center):
          • IconBox 46×46, cornerRadius 10, fill #FAF9F7: lucide "sprout" 23×23 in #7A7166.
          • VStack(gap 3):
              – Title "Mới bắt đầu", #0F0F12, 15.5pt, weight 800.
              – Description "Chưa từng ôn thi lý thuyết", #7A7166, 12pt, weight 600, lineHeight 1.3, fill width.

   4-B. Card "Đã ôn một phần" (id: IMzmd) — SELECTED/HIGHLIGHTED style
        cornerRadius 20, fill #FFE9B0 (solid warm amber), gap 14, padding 10, stroke #E8B53D 1.5 pt.
        HStack(alignItems: center):
          • IconBox 46×46, cornerRadius 10, fill #FFFFFFAA: lucide "trending-up" 23×23 in #7A4A00.
          • VStack(gap 3):
              – Title "Đã ôn một phần", #7A4A00, 15.5pt, weight 800.
              – Description "Đã nắm cơ bản, cần luyện thêm", #9A6A18, 12pt, weight 600, lineHeight 1.3, fill width.

   4-C. Card "Ôn lại trước ngày thi" (id: tXZCz) — UNSELECTED style
        cornerRadius 20, fill #FFFFFFCC, gap 14, padding 10, stroke #00000014 1 pt.
        HStack(alignItems: center):
          • IconBox 46×46, cornerRadius 10, fill #FAF9F7: lucide "target" 23×23 in #7A7166.
          • VStack(gap 3):
              – Title "Ôn lại trước ngày thi", #0F0F12, 15.5pt, weight 800.
              – Description "Đã sẵn sàng, muốn ôn cấp tốc", #7A7166, 12pt, weight 600, lineHeight 1.3, fill width.

── 5. SPACER (id: KoOYi)
   Spacer(), fill_container height and width — pushes CTA to bottom.

── 6. CONTINUE BUTTON (id: R9vDup)
   HStack, fill_container width, height 50, cornerRadius 25, fill #D4714E (appPrimary), justifyContent center, gap 8.
   • Text "Tiếp tục", #FFFFFF, 15pt, weight 700.
   • lucide "arrow-right" icon 16×16, #FFFFFF.


**Tokens:** Background gradient: literal #FBF8F0 → #EEECE6 → #DAD3C4 (no matching app token; closest is scaffoldGradientTop/Bottom but the three-stop warm gradient is unique to onboarding — use a local LinearGradient).

Step / skip label color: #7A7166 — closest is appTextMedium (#737373); use appTextMedium for code, the difference is negligible.

Title: appTextDark (#171717), .appSans(size:26, weight:.heavy).
Subtitle: #7A7166 → appTextMedium, .appSans(size:14, weight:.medium).

Unselected card fill: #FFFFFFCC (white 80% opacity) — no token; use Color.white.opacity(0.8).
Unselected card stroke: #00000014 — Color.black.opacity(0.08).
Unselected icon box fill: cardBg (#FAF9F7).
Unselected icon tint: appTextMedium (#737373 ≈ #7A7166).
Unselected card title: appTextDark (#0F0F12 ≈ #171717).
Unselected card description: appTextMedium.

Selected card fill: #FFE9B0 — no token; literal Color(hex:"FFE9B0") or Color(red:1, green:0.914, blue:0.690).
Selected card stroke: #E8B53D — appWarning (#F59E0B) is close but not exact; use literal Color(hex:"E8B53D"), strokeWidth 1.5.
Selected icon box fill: #FFFFFFAA (white 67%).
Selected icon tint: #7A4A00 — no token; literal Color(hex:"7A4A00") (dark amber).
Selected card title: #7A4A00 — same literal.
Selected card description: #9A6A18 — no token; literal Color(hex:"9A6A18").

Continue button: appPrimary (#D4714E) fill, appOnPrimary (white) label/icon, cornerRadius 25, height 50.
Fonts: .appSans throughout (never .system). Icon library: Lucide (SF-compatible substitution: sprout → "leaf.fill", trending-up → "chart.line.uptrend.xyaxis", target → "scope" or "target").


**Reuse widgets:** AppButton(icon:"arrow.right", label:"Tiếp tục", style:.primary, height:50) — use for the bottom CTA button; override fill to appPrimary and ensure HStack layout with trailing icon matches design (or compose manually as described in layout)

**New widgets:**
- ExperienceLevelCard(level: ExperienceLevel, isSelected: Bool, action: () -> Void) — self-contained tappable card that renders the icon box + title + description row; animates border and fill between unselected (#FFFFFFCC / black-8% stroke) and selected (#FFE9B0 / #E8B53D 1.5 pt stroke) states using withAnimation(.spring(response:0.3, dampingFraction:0.7)); icon, title, description, and color scheme are all driven by the ExperienceLevel enum; buttonStyle(.plain) with .contentShape(Rectangle()) for full-row tap target.
- ExperienceLevel: enum with three cases — .beginner (icon: "leaf.fill", title: "Mới bắt đầu", description: "Chưa từng ôn thi lý thuyết"), .partial (icon: "chart.line.uptrend.xyaxis", title: "Đã ôn một phần", description: "Đã nắm cơ bản, cần luyện thêm"), .cramming (icon: "scope", title: "Ôn lại trước ngày thi", description: "Đã sẵn sàng, muốn ôn cấp tốc"); persisted via @AppStorage("experienceLevel") as String rawValue.
- ExperienceLevelPage: View — the full page composing the step row, header VStack, options VStack of three ExperienceLevelCard rows, a Spacer, and the Continue button; receives currentPage: Binding<Int> and selectedLevel: Binding<ExperienceLevel>; Continue taps call Haptics.impact(.light) then increment currentPage.

**Copy:**
- BƯỚC 2 / 4
- Bỏ qua
- Bạn đã ôn tới đâu rồi?
- Chọn mức độ để chúng tôi gợi ý nội dung phù hợp với bạn.
- Mới bắt đầu
- Chưa từng ôn thi lý thuyết
- Đã ôn một phần
- Đã nắm cơ bản, cần luyện thêm
- Ôn lại trước ngày thi
- Đã sẵn sàng, muốn ôn cấp tốc
- Tiếp tục

**States:** default (no selection): all three cards render in unselected style; Continue button is still tappable (the design shows one pre-selected, so default = .partial pre-selected on first load is acceptable and matches the design snapshot).
selected: exactly one card shows selected amber styling; others revert to unselected white/translucent style.
skip tapped: calls the same completeOnboarding() path as the existing OnboardingView.completeOnboarding(), bypassing remaining steps.
continue tapped (with selection): advances currentPage binding by 1 with spring animation and fires Haptics.impact(.light).
continue tapped (no selection): same behavior — selection is a soft preference, not a hard gate (no blocking validation needed per design).

**Interactions:** Tap any ExperienceLevelCard → sets selectedLevel binding to that case, animates card fill/stroke swap with withAnimation(.spring(response:0.3, dampingFraction:0.7)); deselects previous card simultaneously.
Tap "Bỏ qua" (skip) → calls OnboardingView.completeOnboarding(), setting hasCompletedOnboarding = true and dismissing the onboarding flow entirely.
Tap "Tiếp tục" → persists selectedLevel to @AppStorage("experienceLevel"), fires Haptics.impact(.light), increments currentPage in the parent TabView-driven OnboardingView.
No swipe gestures are shown; navigation is button-only for this step.

**Notes:** Most likely implementation file: GPLX2026/Features/Onboarding/OnboardingView.swift. The current OnboardingView already has a LicensePickerPage inline struct for page index 1; this new screen maps to page index 2 in the updated design flow (design labels it "BƯỚC 2 / 4", whereas the current code has 7 pages). The engineer will need to either insert a new page case in the TabView ForEach (similar to LicensePickerPage) or replace an existing page. A new file ExperienceLevelPage.swift under GPLX2026/Features/Onboarding/ is recommended for cleanliness. The ExperienceLevel enum should live in GPLX2026/Core/Models/ alongside other value types. The selected card in the design snapshot is "Đã ôn một phần" (amber), suggesting .partial as the default pre-selected value. The background gradient is a 3-stop warm parchment gradient specific to this onboarding screen — apply it as a ZStack background behind the content VStack, not via ScaffoldBackground() or AnimatedBackground(). The icon box for unselected cards uses the same cornerRadius 10 and cardBg fill as IconBox in Core/Common; consider reusing IconBox(systemName:size:color:bgColor:) if its API supports arbitrary background colors, otherwise compose inline. Lucide icon names in the design (sprout, trending-up, target) must be mapped to available SF Symbols: "leaf.fill", "chart.line.uptrend.xyaxis", "scope" respectively — or to the project's own Lucide-compatible icon font if one is registered. The frame is 393 × 852 with cornerRadius 40 and clip — this is the device chrome frame in the design canvas, not a real view modifier; do not apply cornerRadius 40 to the SwiftUI view itself unless it is presented as a sheet.


## Onboarding · Study plan setup  (frame IU1H9)

**Purpose:** Allow the user to configure their study plan before completing onboarding: choose a driving-licence class (B1 or B2), set an expected exam date, choose a daily question quota, and opt in to daily reminder notifications. Tapping "Bắt đầu ôn thi" finishes setup and transitions into the main app.

**Layout:**
Full-screen frame 393 × 852 pt. Clipped, cornerRadius 40. Background: linear gradient 205° from #FBF8F0 (0%) → #EEECE6 (55%) → #DAD3C4 (100%) — matches scaffoldGradientTop/Bottom token pair.

Top-level layout: VStack, spacing 0, filling the full frame vertically.

1. STATUS BAR (id Zkt1x)
   - height 62, horizontal padding 28 on each side.
   - HStack space-between: "9:41" text (left) + indicator icons signal/wifi/battery-full (right, gap 7).
   - Text "9:41": .appSans(size:16, weight:.semibold), color appTextDark.
   - Icons: 18×18 signal, 18×18 wifi, 24×18 battery-full, all appTextDark fill.

2. CONTENT VStack (id g7MvW)
   - padding: top 0, leading 20, bottom 20, trailing 20.
   - gap 16 between all direct children.
   - Fills remaining height (fill_container).

   2a. STEP ROW (id vtH6c)
       - HStack space-between, width fill.
       - Left: "BƯỚC 3 / 4" — .appSans(size:10, weight:.heavy), color #7A7166, letterSpacing 1.5.
       - Right: "Bỏ qua" — .appSans(size:13, weight:.bold), color #7A7166, tappable.

   2b. HEADER (id x0smqp)
       - VStack layout, gap 6, width fill.
       - Title: "Thiết lập lộ trình ôn thi" — .appSans(size:26, weight:.heavy), color appTextDark, letterSpacing -0.5, lineHeight 1.1, fixed-width fill.
       - Subtitle: "Cá nhân hoá lịch ôn để bạn sẵn sàng đúng ngày thi." — .appSans(size:14, weight:.medium), color #7A7166, lineHeight 1.4, fixed-width fill.

   2c. LICENCE CARD (id CTwty)
       - Flat card: cornerRadius 20, fill #FFFFFFCC, stroke #00000014 width 1, padding 8, VStack gap 8, width fill.
       - Eyebrow row (EbWrap id uMxKK): padding [2,4,0,4]; text "HẠNG GIẤY PHÉP" — .appSans(size:10, weight:.heavy), color #7A7166, letterSpacing 1.2.
       - Options HStack (id Q3kOUA): gap 8, width fill. Two equal-width option tiles side-by-side.

         B1 TILE (id NeIJV) — UNSELECTED state:
           cornerRadius 12, fill cardBg (#FAF9F7), padding 12, VStack gap 3.
           Top row (HStack space-between, width fill):
             "B1" — .appSans(size:20, weight:.bold), color appTextDark (#0F0F12).
             [No checkmark icon shown in unselected state — space_between leaves right side empty.]
           Description: "Xe số tự động" — .appSans(size:11.5, weight:.semibold), color #7A7166, lineHeight 1.3, fixed-width fill.

         B2 TILE (id j64qkF) — SELECTED state:
           cornerRadius 12, fill #FFE9B0 (warm amber wash), padding 12, VStack gap 3.
           Top row (HStack space-between, width fill):
             "B2" — .appSans(size:20, weight:.bold), color #7A4A00 (dark amber).
             [Selected indicator — checkmark or highlight border, see notes.]
           Description: "Xe số sàn & dịch vụ" — .appSans(size:11.5, weight:.semibold), color #7A4A00, lineHeight 1.3, fixed-width fill.

   2d. EXAM DATE CARD (id FHZWh)
       - Flat card: cornerRadius 20, fill #FFFFFFCC, stroke #00000014 width 1, padding 8, VStack gap 8, width fill.
       - Eyebrow row (OtjaZ): padding [2,4,0,4]; text "NGÀY THI DỰ KIẾN" — .appSans(size:10, weight:.heavy), color #7A7166, letterSpacing 1.2.
       - Inner row (id Nl2Zu): HStack, alignItems center, gap 12, cornerRadius 12, fill #E9F0FA, padding 12, width fill.
         Left icon box (id CLzqP): 40×40, cornerRadius 4, fill #CFE3FF, center-justified.
           Calendar icon (lucide "calendar"): 20×20, fill #143A75.
         Mid VStack (id kdI9M): gap 2, width fill.
           Date text: "27 tháng 6, 2026" — .appSans(size:15, weight:.heavy), color #0F0F12.
           Countdown caption: "Còn 5 ngày nữa" — .appSans(size:12, weight:.semibold), color #7A7166.
       - Entire card is tappable → opens DatePicker sheet.

   2e. GOAL CARD (id ZhZQr)
       - Flat card: cornerRadius 22, fill #FFFFFFCC, stroke #00000014 width 1, padding 12, VStack gap 10, width fill.
       - Goal header row (id hIpg4): HStack space-between, padding [2,4,0,4].
         Left: "MỤC TIÊU MỖI NGÀY" — .appSans(size:10, weight:.heavy), color #7A7166, letterSpacing 1.2.
         Right: "30 câu / ngày" — .appSans(size:12, weight:.heavy), color #7A4A00. (Updates reactively with selection.)
       - Goal tiles HStack (id gnNTe): gap 8, width fill. Three equal-width tiles.

         15-CÂU TILE (id fHTgN) — UNSELECTED:
           cornerRadius 10, fill cardBg (#FAF9F7), padding [12,8], VStack alignCenter gap 5, stroke #00000010 width 1.
           Number: "15" — .appSans(size:24, weight:.bold), color appTextDark, lineHeight 1.
           Unit: "câu / ngày" — .appSans(size:10, weight:.semibold), color #7A7166.
           Label: "Nhẹ nhàng" — .appSans(size:10, weight:.bold), color #9A9389, letterSpacing 0.3.

         30-CÂUU TILE (id z1rfA) — SELECTED:
           cornerRadius 10, fill #FFE9B0, padding [12,8], VStack alignCenter gap 5, stroke #E8B53D width 1.5.
           Number: "30" — .appSans(size:24, weight:.bold), color #7A4A00, lineHeight 1.
           Unit: "câu / ngày" — .appSans(size:10, weight:.semibold), color #9A6A18.
           Label: "Vừa phải" — .appSans(size:10, weight:.bold), color #7A4A00, letterSpacing 0.3.

         50-CÂU TILE (id Wx9op) — UNSELECTED:
           cornerRadius 10, fill cardBg (#FAF9F7), padding [12,8], VStack alignCenter gap 5, stroke #00000010 width 1.
           Number: "50" — .appSans(size:24, weight:.bold), color appTextDark, lineHeight 1.
           Unit: "câu / ngày" — .appSans(size:10, weight:.semibold), color #7A7166.
           Label: "Quyết tâm" — .appSans(size:10, weight:.bold), color #9A9389, letterSpacing 0.3.

   2f. NOTIFICATION CARD (id pcZMX)
       - Flat card: cornerRadius 22, fill #FFFFFFCC, stroke #00000014 width 1, padding 12, HStack alignCenter gap 12, width fill.
       - Left icon box (id f5i4bq): 42×42, cornerRadius 10, fill #FFE9B0, center.
         Bell icon: 21×21, fill #7A4A00.
       - Middle text VStack (id hBTT7): gap 2, width fill.
         Title: "Nhắc nhở ôn tập" — .appSans(size:14.5, weight:.heavy), color #0F0F12.
         Body: "Gửi thông báo nhắc bạn ôn mỗi ngày" — .appSans(size:11.5, weight:.semibold), color #7A7166, lineHeight 1.3, fixed-width fill.
       - Right toggle (id tvyjk): custom Toggle pill — width 46, height 28, cornerRadius 14, fill #1E6B3A (on/green state). Knob: 22×22 circle, fill #FFFFFF, cornerRadius 11, positioned at trailing end (justifyContent:end) with padding 3. Tappable → toggles notification opt-in.

   2g. SPACER (id BF2PN): fills remaining vertical space (fill_container height). Pushes CTA to bottom.

   2h. CONTINUE BUTTON (id lrVIP)
       - HStack center, gap 8, height 50, width fill, cornerRadius 25, fill appPrimary (#D4714E).
       - Label: "Bắt đầu ôn thi" — .appSans(size:15, weight:.bold), color #FFFFFF.
       - Icon: arrow-right, 16×16, fill #FFFFFF.
       - No Liquid Glass treatment (solid fill); this is the primary solid button, not the glass CTA component.

**Tokens:** Background gradient: linear 205°, #FBF8F0 → #EEECE6 → #DAD3C4 (maps to scaffoldGradientTop/Bottom; use ScaffoldBackground() or AnimatedBackground()).
Card fill (semi-transparent): #FFFFFFCC — not a named token; use Color.white.opacity(0.8) or Color(hex:"FFFFFF").opacity(0.8).
Card stroke: #00000014 — Color.black.opacity(0.08).
appPrimary: #D4714E (terracotta) — CTA button fill.
appOnPrimary: #FFFFFF — CTA label + icon.
cardBg: #FAF9F7 — unselected tile fill.
appTextDark: #171717 — but design uses #0F0F12 for some labels; treat as appTextDark.
appTextMedium: #737373 — eyebrow + subtitle use #7A7166 which is slightly warmer; treat as appTextMedium or use literal.
appTextLight: #A3A3A3 — used for deemphasised unit labels (#9A9389 in design).
appWarning: #F59E0B — amber; selected state uses #FFE9B0 (light amber wash) + #7A4A00 (dark amber text) + #E8B53D stroke; no single token covers these; use literal hex values.
appSuccess: #22C55E — not directly used; toggle ON fill is #1E6B3A (dark green), use literal.
Fonts: .appSans(size:weight:) throughout — no .system calls.
Spacing tokens: content padding 20pt horizontal, 20pt bottom; card internal padding 8–12pt; gap between cards 16pt.

**Reuse widgets:** AppButton(icon:label:style:height:) — reuse for the CTA 'Bắt đầu ôn thi' with style:.primary and a trailing arrow icon, or build inline matching the solid terracotta pill shown., ScaffoldBackground() or AnimatedBackground() — for the warm linen gradient background that fills the full screen., TagPill (component/TagPill) — NOT directly reused here; licence and goal tiles are bespoke grid tiles, not pills.

**New widgets:**
- StudyPlanSetupView: top-level screen view; holds @State selectedLicense: String, @State examDate: Date, @State dailyGoal: Int (15/30/50), @State notificationsEnabled: Bool; renders the full scrollable card stack plus fixed CTA at bottom.
- LicenceOptionTile(code: String, description: String, isSelected: Bool, onTap: () -> Void): flat card tile for B1/B2; unselected=cardBg fill/no stroke, selected=#FFE9B0 fill/#E8B53D stroke 1.5; shows large bold code + small description.
- ExamDatePickerCard(date: Binding<Date>): tappable flat card showing eyebrow 'NGÀY THI DỰ KIẾN', calendar icon box, formatted date + countdown string; tap presents DatePicker in a bottom sheet.
- DailyGoalTile(count: Int, label: String, isSelected: Bool, onTap: () -> Void): equal-width tile; unselected=cardBg, selected=#FFE9B0/#E8B53D; shows large count, 'câu / ngày' unit, mood label.
- NotificationToggleCard(isEnabled: Binding<Bool>): flat HStack card with amber bell icon box, title/body text, and a custom iOS-style toggle pill (width 46×28, green when on, white knob).

**Copy:**
- 9:41
- BƯỚC 3 / 4
- Bỏ qua
- Thiết lập lộ trình ôn thi
- Cá nhân hoá lịch ôn để bạn sẵn sàng đúng ngày thi.
- HẠNG GIẤY PHÉP
- B1
- Xe số tự động
- B2
- Xe số sàn & dịch vụ
- NGÀY THI DỰ KIẾN
- 27 tháng 6, 2026
- Còn 5 ngày nữa
- MỤC TIÊU MỖI NGÀY
- 30 câu / ngày
- 15
- câu / ngày
- Nhẹ nhàng
- 30
- câu / ngày
- Vừa phải
- 50
- câu / ngày
- Quyết tâm
- Nhắc nhở ôn tập
- Gửi thông báo nhắc bạn ôn mỗi ngày
- Bắt đầu ôn thi

**States:** LICENCE SELECTION: B1 unselected (cardBg fill, appTextDark code, #7A7166 description) vs B2 selected (#FFE9B0 fill, #7A4A00 text). Both tiles always visible; only one selected at a time. Default: B2 selected (matches existing @AppStorage licenseType default "b2").

EXAM DATE: shows formatted date string "DD tháng M, YYYY" and computed countdown "Còn N ngày nữa". If exam date is in the past or not set, show placeholder "Chọn ngày thi". Countdown text changes color to appError if fewer than 3 days remain.

DAILY GOAL: three tiles 15/30/50; exactly one selected at a time, highlighted amber. Default: 30 selected. The header right-side value "30 câu / ngày" updates reactively to match selection.

NOTIFICATION TOGGLE: on (fill #1E6B3A, knob trailing) vs off (fill #D1D5DB or similar grey, knob leading). Default: ON (matching design).

CTA BUTTON: always enabled (no disabled state shown). On tap: if notificationsEnabled is true, trigger UNUserNotificationCenter authorization request before completing; then persist settings and advance the onboarding page counter.

SKIP: tapping "Bỏ qua" completes onboarding immediately using defaults without validation.

**Interactions:** Step row "Bỏ qua" tap: calls completeOnboarding() immediately (same as existing OnboardingView.completeOnboarding()).

Licence tiles (B1/B2): tap selects tile, deselects the other; haptic .light; writes to @AppStorage licenseType.

Exam date card tap: presents a sheet containing a SwiftUI DatePicker (.graphical style, minimumDate: Date.now, locale: vi_VN). Confirm button on sheet writes back; countdown label recomputes.

Daily goal tiles (15/30/50): tap selects tile; haptic .light; writes to @AppStorage or local @State; header right label updates.

Notification toggle tap: toggles Bool state; if turning ON and permission not yet granted, show system permission prompt on CTA tap (not immediately on toggle); visual toggle state follows local Bool immediately.

CTA "Bắt đầu ôn thi" button tap: if notificationsEnabled && permission not yet requested, call NotificationManager.requestAuthorization() then schedule; persist all settings (licenseType, examDate, dailyGoal, notificationsEnabled) to @AppStorage; advance onboarding page (currentPage += 1 in parent OnboardingView, or set hasCompletedOnboarding = true if this is the last step).

This screen is step 3 of 4 in the onboarding flow; it should be inserted as a new page case (e.g. page.id == 2 or a dedicated enum case) in the existing OnboardingView TabView, replacing or augmenting the existing LicensePickerPage which currently only handles licence selection.

**Notes:** Most likely file: GPLX2026/Features/Onboarding/OnboardingView.swift. This screen consolidates what is currently spread across multiple onboarding steps (license picker at page id 1, notification request at page id 5) into one single "study plan" step (shown as BƯỚC 3/4 in the design). Implementation options: (a) add a new StudyPlanPage view alongside LicensePickerPage and wire it in as page.id == 2 (or a new dedicated step index); (b) replace the existing multi-step flow with the new 4-step design from the wrapper (4 frames in L8FHi). The design frame IU1H9 is the third of four onboarding screens ("GPLX · Onboarding" — without a trailing number, others are "1", "2", "4"), confirming it maps to step 3/4.

The semi-transparent card fill #FFFFFFCC does NOT use .glassCard() — that modifier produces a flat solid-fill card per the card rule. Use .background(Color.white.opacity(0.8)).clipShape(RoundedRectangle(cornerRadius:20)) + .overlay(RoundedRectangle(cornerRadius:20).stroke(Color.black.opacity(0.08), lineWidth:1)) to achieve the frosted-card look without the glass modifier.

The B1/B2 tile "Top" row uses HStack with justifyContent:space_between but the design only shows the code text on the left (no visible checkmark icon in the data). Engineers should add a checkmark icon (system "checkmark" or a circle dot) on the right side for the selected tile to make the selection state legible — the space-between layout was reserved for it.

The toggle component (tvyjk) is a custom view, not a SwiftUI Toggle, to match the exact 46×28 amber-less pill with manual knob positioning. Use a ZStack or HStack with conditional knob alignment and animate with .animation(.spring, value: isEnabled).

All @AppStorage keys referenced: AppConstants.StorageKey.licenseType, a new key for examDate (store as TimeInterval), a new key for dailyGoal (Int), AppConstants.StorageKey.dailyReminderEnabled — match the existing keys in OnboardingView.swift exactly.

Font family in design is "Be Vietnam Pro" which maps to .appSans in the app's font system.


## Onboarding · Ready  (frame Vvu1u)

**Purpose:** The final onboarding screen. It confirms that the user's study plan is set up and shows a read-only summary of the three choices made in previous steps (license class, exam date, daily goal). A single CTA button dismisses onboarding and launches the main app.

**Layout:**

Full-screen frame: 393 × 852 pt, cornerRadius 40, clipped.
Background: linear gradient 205°, #FBF8F0 at 0% → #EEECE6 at 55% → #DAD3C4 at 100% (maps to scaffoldGradientTop / scaffoldGradientBottom; use ScaffoldBackground or a matching LinearGradient).
Root layout: VStack(spacing: 0), fills entire frame top-to-bottom:

1. STATUS BAR ROW (id: eRfCU)
   - height: 62 pt, width: fill, padding horizontal 28 pt
   - HStack, justifyContent: space-between
   - Left: Text "9:41", .appSans(size:16, weight:.semibold), fill #171717 (appTextDark)
   - Right: HStack gap 7 — signal icon 18×18, wifi icon 18×18, battery-full icon 24×18, all fill #171717

2. CONTENT VSTACK (id: WZl1d)
   - layout: vertical, gap: 16, padding: top 0 / leading 20 / bottom 20 / trailing 20
   - height: fill_container, width: fill
   - Children in order:

   2a. STEP ROW (id: k71uDW)
       - HStack, justifyContent: space-between, alignItems: center, width: fill
       - Left: Text "BƯỚC 4 / 4", .appSans(size:10, weight:.heavy), letterSpacing 1.5, color #7A7166 (appTextMedium)
       - Right: Text "" (empty — Skip is intentionally blank on the last step), .appSans(size:13, weight:.bold), color #7A7166
         → In code, render as Color.clear / hidden, or an empty Text(""), so layout is preserved.

   2b. HERO SECTION (id: wpqeA)
       - VStack(spacing:16), alignItems: center, padding: top 20 / bottom 4 (leading/trailing 0), width: fill
       - Child A — BADGE (id: sZj0G):
           Frame 96×96, cornerRadius 24, fill #E7F5EC, stroke #1E6B3A at opacity ~15% (#1E6B3A26) width 1.5
           Centers a Lucide "party-popper" icon 48×48, fill #1E6B3A
       - Child B — HText (id: Ea4vO):
           VStack(spacing:8), alignItems: center, width: fill
           - Title: Text "Tất cả đã sẵn sàng!", .appSans(size:26, weight:.heavy), letterSpacing -0.5, lineHeight 1.1, textAlign center, color appTextDark (#171717), width fill
           - Subtitle: Text "Lộ trình ôn thi của bạn đã được thiết lập. Cùng bắt đầu nào!", .appSans(size:14, weight:.medium), lineHeight 1.4, textAlign center, color #7A7166 (appTextMedium), width fill

   2c. SUMMARY CARD (id: Ngv6d)
       - VStack(spacing:8), padding all 12, cornerRadius 22
       - Background fill: #FFFFFFCC (white at ~80% opacity — frosted/translucent), stroke #00000014 width 1
       - Width: fill
       - Child A — Eyebrow wrapper (id: NFXFs):
           Frame width fill, padding top 2 / leading 4 / trailing 4 (bottom 0)
           Contains Text "LỘ TRÌNH CỦA BẠN", .appSans(size:10, weight:.heavy), letterSpacing 1.2, color #7A7166 (appTextMedium)
       - Child B — Rows inner card (id: jGLZ3):
           VStack(spacing:0), padding horizontal 12 (top/bottom 0), cornerRadius 10
           Background fill: #FAF9F7 (cardBg), stroke #00000010 width 1
           Width: fill
           Three rows separated by 1pt dividers:

           ROW 1 — "Hạng giấy phép" (id: LWYtE):
             HStack(spacing:12), alignItems: center, padding vertical 12, width fill
             - IconBox (id: x2Y788): 38×38, cornerRadius 10, fill #FFE9B0, centers Lucide "award" icon 19×19 fill #7A4A00
             - Label Text "Hạng giấy phép", .appSans(size:13, weight:.semibold), color #7A7166, width fill (flexible)
             - Value Text "B2", .appSans(size:14, weight:.heavy), color #0F0F12 (appTextDark)

           DIVIDER (id: y4wRzZ): Rectangle fill #00000010, height 1, width fill

           ROW 2 — "Ngày thi dự kiến" (id: BpNgr):
             HStack(spacing:12), alignItems: center, padding vertical 12, width fill
             - IconBox (id: MskXh): 38×38, cornerRadius 10, fill #E9F0FA, centers Lucide "calendar" icon 19×19 fill #143A75
             - Label Text "Ngày thi dự kiến", .appSans(size:13, weight:.semibold), color #7A7166, width fill
             - Value Text "27/06/2026", .appSans(size:14, weight:.heavy), color #0F0F12

           DIVIDER (id: WQjWZ): Rectangle fill #00000010, height 1, width fill

           ROW 3 — "Mục tiêu mỗi ngày" (id: kK9Eq):
             HStack(spacing:12), alignItems: center, padding vertical 12, width fill
             - IconBox (id: k8IRg): 38×38, cornerRadius 10, fill #E7F5EC, centers Lucide "target" icon 19×19 fill #1E6B3A
             - Label Text "Mục tiêu mỗi ngày", .appSans(size:13, weight:.semibold), color #7A7166, width fill
             - Value Text "30 câu", .appSans(size:14, weight:.heavy), color #0F0F12

   2d. SPACER (id: aYSCy)
       - Fills remaining vertical space (Spacer() in SwiftUI)

   2e. CTA BUTTON (id: S3JZW)
       - HStack(spacing:8), justifyContent: center, alignItems: center
       - height: 50, width: fill, cornerRadius 25
       - Background fill: #D4714E (appPrimary)
       - Left: Text "Vào ứng dụng", .appSans(size:15, weight:.bold), fill white (appOnPrimary)
       - Right: Lucide "arrow-right" icon 16×16, fill white
       - Tappable: triggers completeOnboarding() → sets hasCompletedOnboarding = true


**Tokens:** 
Background gradient: LinearGradient stops #FBF8F0 → #EEECE6 → #DAD3C4 at 205° — matches ScaffoldBackground / scaffoldGradientTop+Bottom tokens.
Status bar text / icons: appTextDark (#171717).
Step label "BƯỚC 4 / 4": #7A7166 — closest app token is appTextMedium (#737373); the design uses a warm-tinted mid-grey, use appTextMedium.
Hero title "Tất cả đã sẵn sàng!": appTextDark (#171717).
Hero subtitle: #7A7166 — appTextMedium.
Badge background: #E7F5EC — no direct token; literal hex or define as a local green-tint constant. Stroke: #1E6B3A at ~15% opacity.
Badge icon: #1E6B3A (dark green).
Summary card outer background: #FFFFFFCC (white 80%) — no named token; use Color.white.opacity(0.8).
Summary card outer stroke: #00000014 — Color.black.opacity(0.08).
Inner rows card background: #FAF9F7 — cardBg token.
Inner rows card stroke: #00000010 — Color.black.opacity(0.063).
Dividers: #00000010 — Color.black.opacity(0.063).
Eyebrow "LỘ TRÌNH CỦA BẠN": appTextMedium.
Row label texts: appTextMedium.
Row value texts: #0F0F12 — appTextDark (near-black).
IconBox license (amber): fill #FFE9B0, icon #7A4A00 — no tokens; literal hex.
IconBox exam date (blue): fill #E9F0FA, icon #143A75 — no tokens; literal hex.
IconBox goal (green): fill #E7F5EC, icon #1E6B3A — no tokens; literal hex.
CTA button: appPrimary (#D4714E) background, appOnPrimary (white) label+icon.
Font family throughout: .appSans(size:weight:) — never .system.


**Reuse widgets:** AppButton(icon:label:style:height:) — use for the CTA (style:.primary, label:"Vào ứng dụng", icon:"arrow-right" if AppButton supports trailing icons; otherwise build the inline HStack as designed)

**New widgets:**
- OnboardingReadyView — top-level View for this screen. Props: licenseDisplay: String (e.g. "B2"), examDate: String (formatted dd/MM/yyyy), dailyGoal: String (e.g. "30 câu"), onFinish: () -> Void. Renders the full 393×852 pt layout described. Injected into the existing OnboardingView page flow as the last page (replaces current page id:6 'Sẵn sàng rồi!').
- OnboardingSummaryCard — standalone View. Props: licenseDisplay: String, examDate: String, dailyGoal: String. Renders the frosted outer card (cornerRadius 22, white 80%) containing the eyebrow label and inner rows card with three IconRow entries. Internal sub-view.
- OnboardingIconRow — reusable row sub-view inside OnboardingSummaryCard. Props: iconName: String (Lucide/SF symbol name), iconBg: Color, iconFg: Color, label: String, value: String. Renders the 38×38 icon box + label + value HStack with vertical 12pt padding. No external reuse needed beyond OnboardingSummaryCard.
- OnboardingBadgeView — small View for the 96×96 circle badge. Props: iconName: String, bgColor: Color, fgColor: Color. Renders the rounded square container with centered icon. Internally used by OnboardingReadyView hero section.

**Copy:**
- 9:41
- BƯỚC 4 / 4
- Tất cả đã sẵn sàng!
- Lộ trình ôn thi của bạn đã được thiết lập. Cùng bắt đầu nào!
- LỘ TRÌNH CỦA BẠN
- Hạng giấy phép
- B2
- Ngày thi dự kiến
- 27/06/2026
- Mục tiêu mỗi ngày
- 30 câu
- Vào ứng dụng

**States:** 
populated (only state): All three summary rows always show data — this screen is reached only after steps 1–3 are completed, so licenseDisplay, examDate, and dailyGoal are always non-empty. No loading, empty, or error states exist on this screen.
skip label: The right slot of the step row is intentionally empty (empty String) on step 4/4 — render as Text("") or hidden. Do NOT show a "Bỏ qua" button.
CTA button: normal (always enabled — no disabled state). No loading spinner on tap; the tap directly calls completeOnboarding() which is synchronous (sets @AppStorage flag).


**Interactions:** 
CTA "Vào ứng dụng" button tap: calls completeOnboarding() → sets @AppStorage("hasCompletedOnboarding") = true → the app root view switches from OnboardingView to the main TabView. Add Haptics.impact(.medium) consistent with the existing completeOnboarding() implementation.
No other tappable elements on this screen.
Navigation: this screen is page index 6 (or the last page) in the existing OnboardingView TabView pager. It is swiped-to from the previous onboarding page via the page-dot TabView; the existing spring animation (.spring(duration:0.3)) applies on arrival.
No sheet, no navigation push, no back gesture expected (user has completed all steps).


**Notes:** 
Most likely existing file: /Users/maitrungkien/Desktop/project/GPLX2026/GPLX2026/Features/Onboarding/OnboardingView.swift — specifically the last page (id:6, "Sẵn sàng rồi!") in the `pages` array and the completeOnboarding() function. The new OnboardingReadyView replaces OnboardingPageView for that final slot.

Fidelity gotchas:
1. The outer summary card uses a translucent white fill (#FFFFFFCC, ~80% opacity), NOT the .glassCard() modifier. .glassCard() is a flat solid fill. Implement this card as a plain RoundedRectangle fill with Color.white.opacity(0.8) + stroke overlay.
2. The inner rows card (jGLZ3) uses cardBg (#FAF9F7) — this IS a plain flat card, matching the card rule.
3. The badge icon is Lucide "party-popper" — not available in SF Symbols. The existing project uses Lottie for animations; this icon should be sourced from the Lucide icon font/library already used in the design, or substituted with SF Symbol "party.popper" (available iOS 17+). Confirm availability with the team.
4. Row icons (award, calendar, target) are Lucide icons — substitute SF Symbols: "rosette" or "trophy" for award, "calendar" for calendar, "target" for target (all available iOS 16+).
5. The Spacer() between the summary card and the CTA button is critical — it pushes the CTA to the bottom of the screen. Do not give it a fixed height.
6. The background gradient is shared with all four onboarding screens (same gradient parameters). If ScaffoldBackground() already renders this gradient, reuse it; otherwise apply the LinearGradient directly as the .background() modifier.
7. The step label "BƯỚC 4 / 4" uses letterSpacing 1.5 — apply with .tracking(1.5) in SwiftUI.
8. The eyebrow label "LỘ TRÌNH CỦA BẠN" uses letterSpacing 1.2 — apply with .tracking(1.2).
9. The summary card corner radius is 22 (not the standard .glassCard default of 20) — pass explicitly to RoundedRectangle.
10. The frame id "Vvu1u" is the fourth child of the "Wrapper · Onboarding" (id: L8FHi) → "Screens" group, confirming it is onboarding step 4 of 4 in the design.
11. In the existing OnboardingView, page id:6 is the last page. The design calls this "BƯỚC 4 / 4", suggesting the design counts only 4 user-facing onboarding steps (not 7). The engineer should clarify whether this screen replaces the entire current last page or is inserted as an additional terminal page. Most likely: the current page-6 "Sẵn sàng rồi!" should be replaced wholesale with OnboardingReadyView, and the step numbering in the design (4/4) is independent of the code's page count.



## Home / Dashboard  (frame RAmsg)

**Purpose:** The primary "Trang chủ" tab the user lands on after onboarding. It surfaces a time-based greeting, study-streak metadata, a mock-exam result summary card, a full question-bank progress card with deep-link shortcuts, and a 2x2 quick-action grid — all inside a vertically scrolling canvas sitting on the app's warm gradient background with a frosted tab bar anchored at the bottom.

**Layout:**

OUTER FRAME — RAmsg
  Width: 393 pt, layout: vertical, cornerRadius: 40, clip: true
  Background: LinearGradient(rotation: 205°)
    stop 0%   → #FBF8F0 (scaffoldGradientTop)
    stop 55%  → #EEECE6 (scaffoldBg)
    stop 100% → #DAD3C4 (scaffoldGradientBottom)

1. STATUS BAR — SAIBb
   Height: 62 pt, horizontal layout, justifyContent: space-between, padding: [0, 28]
   Left:  Text "9:41", Be Vietnam Pro 16/600, fill #171717
   Right: HStack gap:7 — Signal icon 18×18, Wifi icon 18×18, Battery icon 24×18 (all fill #171717)
   (In production this row is replaced by the system status bar; replicate only in snapshot/preview.)

2. SCROLLVIEW CONTENT — A06zb
   Layout: vertical, gap: 18, padding: [top:0, leading:20, bottom:20, trailing:20]
   Fills full width. Contains four top-level children in order:

   2a. HEADER — o4e7I2
       Layout: vertical, gap: 8, padding: [top:8, bottom:4] (h-padding inherited from A06zb)
       Width: fill

       i.  TITLE ROW — L0aUw
           Horizontal, justifyContent: space-between, width: fill
           Left:  Text greeting "Chào buổi sáng!" — Be Vietnam Pro 32/700, fill #0F0F12,
                  letterSpacing: -0.4, lineHeight: 1.05
           Right: Settings button — 40×40 circle, fill #FFFFFFCC, stroke #0F0F1214 1pt,
                  cornerRadius: 100; contains Settings icon (lucide "settings") 20×20, fill #0F0F12

       ii. SUBTITLE
           Text "Sẵn sàng ôn tập hôm nay chưa?", Be Vietnam Pro 13.5, fill #7A7166, lineHeight: 1.4

       iii. HEADER META — NTNqd
            Horizontal, alignItems: center, gap: 8, width: fill
            Chip A (Day Chip — B9ExD):
              HStack, cornerRadius: 16, fill #FFFFFFCC, stroke #0F0F1214 1pt, gap: 8, padding: [6,12]
              • calendar icon 13×13, fill #7A4A00
              • Text "Thứ ba · 22 / 06", Be Vietnam Pro 12/600, fill #0F0F12
            Chip B (Streak Chip — zHsum):
              HStack, cornerRadius: 16, fill #FFE9B0, gap: 6, padding: [6,12]
              • flame icon 13×13, fill #7A4A00
              • Text "12 ngày liên tục", Be Vietnam Pro 12/700, fill #7A4A00

   2b. DAILY TIPS CARD ("Kết quả thi thử") — f86CGS
       Layout: vertical, gap: 10, padding: 12, cornerRadius: 22
       Fill: #FFFFFFCC (semi-transparent white), stroke: #00000014, strokeWidth: 1

       i.  HEAD ROW — zzvE8
           Horizontal, justifyContent: space-between, width: fill
           Left (kR0K0 — HStack, gap: 8):
             • Icon Box (U9GeT): 28×28, cornerRadius: 8, fill #FFE9B0
               Contains clipboard-check icon 16×16, fill #7A4A00
             • Eyebrow text "KẾT QUẢ THI THỬ", Be Vietnam Pro 10/800, fill #7A4A00, letterSpacing: 0.8
           Right Chip (a34Wya):
             HStack, cornerRadius: 100, fill #FFE9B066, gap: 5, padding: [5,12]
             • calendar-clock icon 13×13, fill #7A4A00
             • Text "Còn 5 ngày", Be Vietnam Pro 11.5/700, fill #7A4A00

       ii. HERO ROW — JOK2z
           Horizontal, justifyContent: space-between, alignItems: center
           cornerRadius: 10, fill #FFE9B0, padding: 12, width: fill
           Left (ofVpq — VStack, gap: 2):
             • Score display (n8uqw — HStack, gap: 5, alignItems: end):
               - "33", Be Vietnam Pro 34/700, fill #0F0F12, lineHeight: 1
               - "/ 35 điểm", Be Vietnam Pro 14/700, fill #7A4A00
             • "Điểm trung bình · 12 lượt thi", Be Vietnam Pro 11.5/600, fill #8A6A2A
           Right pill (n4Vfw):
             HStack, cornerRadius: 100, fill #1F5A2A, gap: 5, padding: [6,14]
             • circle-check icon 14×14, fill #FFFFFF
             • Text "Đạt", Be Vietnam Pro 13/800, fill #FFFFFF

       iii. MINI STATS ROW — gwSz4
            Horizontal, gap: 8, width: fill (three equal-width mini cards)
            Each mini card: VStack, alignItems: center, gap: 1, cornerRadius: 10,
            fill #FAF9F7, stroke #00000010 1pt, padding: [10,8], width: fill_container
            Card 1 (EkLyG):  value "35", Be Vietnam Pro 17/700, #0F0F12; label "Cao nhất", Be Vietnam Pro 10.5/600, #7A7166
            Card 2 (lUYt7):  value "75%", Be Vietnam Pro 17/700, #0F0F12; label "Tỉ lệ đạt", Be Vietnam Pro 10.5/600, #7A7166
            Card 3 (hAbeg):  value "32", Be Vietnam Pro 17/700, #0F0F12; label "Gần nhất", Be Vietnam Pro 10.5/600, #7A7166

   2c. OVERVIEW CARD ("Luyện tập / Tiến độ") — ggL0j
       Layout: vertical, gap: 10, padding: 12, cornerRadius: 22
       Fill: #FFFFFFCC, stroke: #00000014, strokeWidth: 1

       i.  PROGRESS HERO — bRLH2
           Layout: vertical, gap: 12, cornerRadius: 10, fill #FFE9B0, padding: 14, width: fill

           HEAD ROW — WOA2O
           Horizontal, justifyContent: space-between, alignItems: center, width: fill
           Left (HdOqH — VStack, gap: 3):
             • "BỘ 600 CÂU LÝ THUYẾT", Be Vietnam Pro 10/800, fill #7A4A00, letterSpacing: 1
             • Big score row (khqNu — HStack, gap: 5, alignItems: end):
               - "468", Be Vietnam Pro 34/700, fill #7A4A00, lineHeight: 1
               - "/ 600 câu đã thuộc", Be Vietnam Pro 13/600, fill #9A6A18
           Right (Z0XB8 — pill):
             cornerRadius: 100, fill #FFFFFFCC, padding: [7,13], alignItems: center
             • "78%", Be Vietnam Pro 17/700, fill #7A4A00

           PROGRESS TRACK — RhgJh
           Height: 10, cornerRadius: 5, fill #FFFFFF8C, width: fill
           • Fill bar (jcPER): height: 10, cornerRadius: 5, fill #E0922A, width: 235pt
             (represents ~78% fill; in code compute fill width from fraction * trackWidth)

           FOOTER ROW — cYRiV
           Horizontal, justifyContent: space-between, alignItems: center, width: fill
           Left: "Còn 132 câu chưa thuộc", Be Vietnam Pro 12/600, fill #8A6A2A
           Right CTA (I5NGC): cornerRadius: 100, fill #7A4A00, gap: 5, padding: [8,14]
             • "Ôn tiếp", Be Vietnam Pro 12.5/700, fill #FFFFFF
             • arrow-right icon 14×14, fill #FFFFFF

       ii. STATS LIST — WpfVL
           Layout: vertical, cornerRadius: 10, fill #FAF9F7, padding: [0,12], stroke: #00000010, strokeWidth: 1, width: fill
           Three rows separated by 1pt dividers (fill #00000010):

           Row 1 — Điểm liệt (V0XHF):
             Horizontal, gap: 12, alignItems: center, padding: [10,0], width: fill
             • IconBox 32×32, cornerRadius: 10, fill #FFE9B0
               Contains triangle-alert icon 16×16, fill #7A4A00
             • Label "Điểm liệt", Be Vietnam Pro 13.5/600, fill #0F0F12, width: fill_container
             • Value "48/50", Be Vietnam Pro 18/700, fill #7A4A00
             • chevron-right 16×16, fill #9A9389

           Divider (ScXFD): height 1, fill #00000010, width fill

           Row 2 — Câu sai cần ôn (j5e1v4):
             Horizontal, gap: 12, alignItems: center, padding: [10,0], width: fill
             • IconBox 32×32, cornerRadius: 10, fill #FFD7CF
               Contains circle-x icon 16×16, fill #8A2A1F
             • Label "Câu sai cần ôn", Be Vietnam Pro 13.5/600, fill #0F0F12, width: fill_container
             • Value "12", Be Vietnam Pro 18/700, fill #8A2A1F
             • chevron-right 16×16, fill #9A9389

           Divider (R574Br): height 1, fill #00000010, width fill

           Row 3 — Đánh dấu (bqDeq):
             Horizontal, gap: 12, alignItems: center, padding: [10,0], width: fill
             • IconBox 32×32, cornerRadius: 10, fill #CFE3FF
               Contains bookmark icon 16×16, fill #143A75
             • Label "Đánh dấu", Be Vietnam Pro 13.5/600, fill #0F0F12, width: fill_container
             • Value "24", Be Vietnam Pro 18/700, fill #143A75
             • chevron-right 16×16, fill #9A9389

   2d. QUICK ACTIONS — W8MiWR
       Layout: vertical, gap: 12, width: fill

       Section title: "Lối tắt", Be Vietnam Pro 20/700, fill #0F0F12, letterSpacing: -0.2

       Grid (u3eOYh): layout: vertical, gap: 8, width: fill
         Row 1 (kuNUd): Horizontal, gap: 8, width: fill (two equal items)
           • e9bdf — Ngẫu nhiên
           • yEyAo — Thi thử
         Row 2 (atqpH): Horizontal, gap: 8, width: fill (two equal items)
           • aedve — Mô phỏng
           • gJJSP — Tiếp tục

       Each action tile: Horizontal, alignItems: center, cornerRadius: 16, fill #FFFFFFCC,
                         gap: 10, padding: 6, width: fill_container
         Left IconBox: 38×38, cornerRadius: 10
         Right Info VStack: gap: 1, width: fill_container
           • Title (Be Vietnam Pro 13.5/700, fill #0F0F12, lineHeight: 1.15)
           • Subtitle (Be Vietnam Pro 11/600, fill #7A7166)

         Tile 1 (e9bdf) — Ngẫu nhiên:
           IconBox fill #FFE9B0, icon "shuffle" 20×20, fill #7A4A00
           Title: "Ngẫu nhiên" · Subtitle: "25 câu"
         Tile 2 (yEyAo) — Thi thử:
           IconBox fill #FFD7CF, icon "clipboard-list" 20×20, fill #8A2A1F
           Title: "Thi thử" · Subtitle: "Bộ đề mới"
         Tile 3 (aedve) — Mô phỏng:
           IconBox fill #D9F0DA, icon "clapperboard" 20×20, fill #1F5A2A
           Title: "Mô phỏng" · Subtitle: "120 tình huống"
         Tile 4 (gJJSP) — Tiếp tục:
           IconBox fill #CFE3FF, icon "rotate-ccw" 20×20, fill #143A75
           Title: "Tiếp tục" · Subtitle: "Chương 3" (dynamic: last topic name)

3. TAB BAR — RQze9 (dP4vH ref)
   Wraps WUOfv Bar: cornerRadius: 30, fill #FAF9F7B3, height: 60, padding: 6
   Background blur: radius 18, outer shadow: y+8, blur 24, #00000018
   Four tab items in HStack, justifyContent: space-between:
     • Trang chủ (ACTIVE): fill #D4714E1F background, icon+label both #D4714E — house icon 22×22
     • Luyện tập: icon "book-open" 22×22, label, both #8A847C
     • Thi thử:   icon "clipboard-list" 22×22, label, both #8A847C
     • Mô phỏng:  icon "clapperboard" 22×22, label, both #8A847C
   Each item VStack, gap: 3, cornerRadius: 24, height: fill, width: fill, justifyContent: center
   Tab label: Be Vietnam Pro 10/600 (active) or 10/500 (inactive)


**Tokens:** 
Background gradient: scaffoldGradientTop #FBF8F0 → scaffoldBg #EEECE6 → scaffoldGradientBottom #DAD3C4, rotation 205° (matches ScaffoldBackground)

Card surfaces:
  • Semi-transparent white cards (Daily Tips, Overview Card): fill #FFFFFFCC, stroke #00000014 — use a custom .homeCard() modifier (cornerRadius:22, see new widgets)
  • Opaque metric mini-cards: fill #FAF9F7 (cardBg), stroke #00000010
  • Amber hero panels: fill #FFE9B0 (literal, no app token — use Color(hex:0xFFE9B0))

Typography (all Be Vietnam Pro via .appSans):
  Greeting h1:        .appSans(size:32, weight:.bold),   letterSpacing:-0.4
  Section title:      .appSans(size:20, weight:.bold),   letterSpacing:-0.2
  Eyebrow all-caps:   .appSans(size:10, weight:.heavy),  letterSpacing:0.8–1.0
  Body/subtitle:      .appSans(size:13.5),               fill #7A7166 (appTextMedium approx)
  Tile primary label: .appSans(size:13.5, weight:.bold)
  Tile sub label:     .appSans(size:11, weight:.semibold), appTextMedium
  Chip text:          .appSans(size:12, weight:.bold/.semibold)
  Stat value large:   .appSans(size:34, weight:.bold),   lineHeight:1
  Stat value medium:  .appSans(size:17–18, weight:.bold)
  Stat label small:   .appSans(size:10.5–12, weight:.semibold)
  Progress footer:    .appSans(size:12, weight:.semibold), fill #8A6A2A

Colors (semantic mapping):
  appPrimary (terracotta):  #D4714E — tab active tint
  appTextDark:              #0F0F12 (near-black used in design, slightly warmer than #171717)
  appTextMedium:            #7A7166 (subtitle text — slightly warmer than token #737373)
  appTextLight:             #9A9389 (chevron icons)
  Amber family:             #7A4A00 (dark amber text/icons), #8A6A2A (muted amber), #9A6A18
  Amber backgrounds:        #FFE9B0 (warm amber fill), #FFE9B066 (semi-transparent chip)
  Green pass:               #1F5A2A (dark green fill for "Đạt" pill)
  Red/wrong:                #8A2A1F (dark red for wrong-answer row value)
  Blue bookmark:            #143A75 (dark blue for bookmark value)
  Progress fill:            #E0922A (orange-amber bar)
  Progress track:           #FFFFFF8C (semi-transparent white)
  Divider:                  #00000010 (very light)
  Settings button:          fill #FFFFFFCC, stroke #0F0F1214
  Tab bar:                  fill #FAF9F7B3 (frosted)

Spacing constants:
  Outer content H-padding: 20 pt
  Content gap (between cards): 18 pt
  Card internal gap: 10 pt (cards), 8 pt (mini stats), 12 pt (progress hero), 6 pt (action tiles)
  Quick actions grid row gap: 8 pt, tile padding: 6 pt


**Reuse widgets:** AppTabBar(items:selection:) — frosted 4-tab bar at bottom; set selection to .home (tab 0), ProgressBarView — reuse for the amber progress track in the Overview Card progress hero (fill color: Color(hex:0xE0922A), trackColor: Color.white.opacity(0.55), height: 10, cornerRadius: 5), MiniMetricCard — NOT reusable as-is (it includes a TopicProgressRing); instead build HomeExamMiniStats as a new widget (see newWidgets). However MiniMetricCard's StatItem label+value pattern is the same atomic pattern., StatItem — reuse for the value+label pattern inside the three mini-cards below the exam hero, StatusBadge(text:color:fontSize:) — reuse for the green 'Đạt' exam pill (text:'Đạt', color:.appSuccess), IconBox — reuse for the 32×32 icon boxes inside the Stats List rows (Điểm liệt / Câu sai / Đánh dấu), SectionTitle (or bare Text with .appSans(size:20,weight:.bold)) — for the 'Lối tắt' section header, ScaffoldBackground() + AnimatedBackground() — applied via .screenHeaderStyle() / .glassBackground() on the outer view (the gradient background is the design's scaffold gradient)

**New widgets:**
- HomeGreetingHeader(greeting:String, subtitle:String, dateString:String, streakDays:Int, onSettingsTap:()->Void) — renders Title Row + subtitle + Header Meta row (day chip + streak chip); greeting computed from current hour externally and passed in; dateString formatted as 'Thứ ba · DD / MM'
- HomeExamResultCard(lastScore:Int, totalScore:Int, avgScore:Double, attemptCount:Int, passRate:Double, highScore:Int, daysUntilExam:Int?) — the full 'KẾT QUẢ THI THỬ' card (f86CGS); amber semi-transparent container, cornerRadius:22; internally: head row with eyebrow + countdown chip, hero row with large score + Đạt pill, 3-up mini stat row. All amber styling self-contained.
- HomeProgressCard(masteredCount:Int, totalCount:Int, fraction:Double, remainingCount:Int, diemLietCorrect:Int, diemLietTotal:Int, wrongCount:Int, bookmarkCount:Int, onStudyTap:()->Void, onDiemLietTap:()->Void, onWrongTap:()->Void, onBookmarkTap:()->Void) — the 'Overview Card' (ggL0j); amber progress hero with track + CTA + three tappable stat rows; cornerRadius:22 semi-transparent white surface
- HomeQuickActionsGrid(onRandomTap:()->Void, onExamTap:()->Void, onSimTap:()->Void, lastTopicName:String, onContinueTap:()->Void) — 2×2 grid of frosted action tiles; each tile has a colored IconBox + title + subtitle; uses a 2-column LazyVGrid with spacing:8; tile cornerRadius:16, fill #FFFFFFCC
- HomeActionTile(iconName:String, iconColor:Color, boxColor:Color, title:String, subtitle:String, action:()->Void) — individual action tile inside HomeQuickActionsGrid; 38×38 colored box + VStack info; height: auto (not fixed); internal padding: 6; cornerRadius: 16; fill #FFFFFFCC

**Copy:**
- Chào buổi sáng!
- Chào buổi chiều!
- Chào buổi tối!
- Sẵn sàng ôn tập hôm nay chưa?
- Thứ ba · 22 / 06
- 12 ngày liên tục
- KẾT QUẢ THI THỬ
- Còn 5 ngày
- 33
- / 35 điểm
- Điểm trung bình · 12 lượt thi
- Đạt
- Cao nhất
- Tỉ lệ đạt
- Gần nhất
- BỘ 600 CÂU LÝ THUYẾT
- 468
- / 600 câu đã thuộc
- 78%
- Còn 132 câu chưa thuộc
- Ôn tiếp
- Điểm liệt
- 48/50
- Câu sai cần ôn
- 12
- Đánh dấu
- 24
- Lối tắt
- Ngẫu nhiên
- 25 câu
- Thi thử
- Bộ đề mới
- Mô phỏng
- 120 tình huống
- Tiếp tục
- Chương 3
- Trang chủ
- Luyện tập
- Mô phỏng

**States:** 
empty (no exam history): HomeExamResultCard shows zero/dash values for score, passRate, highScore; attempt count "0 lượt thi"; "Đạt" pill hidden; countdown chip still shows if daysUntilExam is set.

empty (no study progress): HomeProgressCard fraction = 0, masteredCount = 0, progressBar width = 0; remainingCount = totalCount (600); Stats rows show diemLietCorrect=0, wrongCount=0, bookmarkCount=0.

loading: ProgressStore data not yet available — show skeleton shimmer on HomeExamResultCard hero row and HomeProgressCard progress hero; skeleton fills amber panels with a 40% opacity overlay animated with .opacity oscillation. Quick actions grid is never loading (static routes).

populated: all values hydrated from ProgressStore; greeting text time-dependent (morning/afternoon/evening); dateString and streakDays from live data; countdownChip hidden when daysUntilExam is nil.

streak zero: Streak Chip (zHsum) hidden (HStack is conditionally rendered only when streakCount > 0).

exam passed: "Đạt" green pill shown; exam failed: replace pill with "Chưa đạt" pill (fill #8A2A1F, text white).

days-until-exam nil: the "Còn N ngày" chip in HomeExamResultCard head row is hidden.

daysUntilExam == 0: chip shows "Hôm nay thi!" instead of "Còn 0 ngày".

last-topic present: "Tiếp tục" tile subtitle shows the last topic name (dynamic); absent: subtitle shows "Bắt đầu học".

tab selection: "Trang chủ" tab active — house icon + label in appPrimary, pill background appPrimary at 12% opacity; other tabs in appTextMedium (#8A847C).


**Interactions:** 
Settings button (fuiIY, top-right 40×40 circle) → navigate to SettingsView (NavigationLink or sheet, matching existing HomeTab toolbar link).

Streak Chip — no navigation; decorative.

Day Chip — no navigation; decorative.

HomeExamResultCard (f86CGS) — entire card or a dedicated "Xem chi tiết" affordance (not in design, card is tappable in whole) → navigate to exam history list (ExamHistoryView or equivalent).

Mini stat cards (Cao nhất / Tỉ lệ đạt / Gần nhất) — tappable → same exam history destination.

HomeProgressCard "Ôn tiếp" CTA button (I5NGC) → openExam(.questionView(topicKey: lastTopicKey ?? allQuestions, startIndex: lastIndex)).

Stats List Row — Điểm liệt chevron → openExam(.questionView(topicKey: diemLietKey, startIndex:0)).
Stats List Row — Câu sai cần ôn chevron → NavigationLink to WrongAnswersView.
Stats List Row — Đánh dấu chevron → NavigationLink to BookmarksView.

Quick Actions Grid:
  Ngẫu nhiên → openExam(.questionView(topicKey: allQuestions, startIndex: randomIndex)).
  Thi thử → openExam(.mockExam()).
  Mô phỏng → openExam(.simulationExam(mode:.practice)) or navigate to simulation tab.
  Tiếp tục → openExam(.questionView(topicKey: lastTopicKey, startIndex: lastIndex)).

Tab Bar items:
  Trang chủ (index 0) → already selected, no-op or scroll-to-top.
  Luyện tập (index 1) → switch to PracticeTab.
  Thi thử (index 2) → switch to ExamTab.
  Mô phỏng (index 3) → switch to simulation/hazard tab.
  Tab switching uses AppTabBar selection binding injected from HomeView/ContentView.

ScrollView: vertical, showsIndicators: false. Content sits on top of fixed gradient background (ScaffoldBackground). Tab bar floats over content at the bottom edge (ZStack or .safeAreaInset).


**Notes:** 
PRIMARY FILE: /Users/maitrungkien/Desktop/project/GPLX2026/GPLX2026/Features/Home/HomeTab.swift

The existing HomeTab.swift already contains ProgressOverview, PrimaryActionCard, QuickActionsGrid, ShortcutsRow, and RecentResultsCard — none of which match the new design faithfully. The new design replaces all of these with the three-card layout (HomeExamResultCard, HomeProgressCard, HomeQuickActionsGrid). The old subviews should be removed and the new ones wired in.

The greeting text logic (greetingText computed var, hour-switch) already exists and can be kept verbatim.

The outer frame uses cornerRadius:40 with clip:true — this is the device chrome in the design; in production the SwiftUI view does NOT apply its own corner-radius; that clipping is provided by the device bezel. Do not add a .cornerRadius(40) wrapper in production code.

Card surface styling: the design uses fill #FFFFFFCC (80% opacity white) on both large cards. This is NOT the existing .glassCard() flat fill (which resolves to cardBg = #FAF9F7 solid). A new .homeCard(cornerRadius:22) modifier is needed: `content.background(Color.white.opacity(0.8)).clipShape(RoundedRectangle(cornerRadius:22)).overlay(RoundedRectangle(cornerRadius:22).stroke(Color.black.opacity(0.08),lineWidth:1))`. The amber mini-cards inside (#FAF9F7 solid) use the existing .glassCard(cornerRadius:10) pattern.

Action tiles (Quick Actions) also use #FFFFFFCC fill — they can use the same .homeCard() modifier with cornerRadius:16.

The "Lối tắt" 2×2 grid uses a plain VStack of two HStacks (not LazyVGrid) as both rows are always shown. However using a 2-column LazyVGrid with spacing:8 is equivalent and preferable for adaptive layout.

AppTabBar: The design's tab bar is the dP4vH component (WUOfv) with frosted glass blur. The existing AppTabBar.swift should be used as-is and matched to these 4 tabs: house (Trang chủ), book-open (Luyện tập), clipboard-list (Thi thử), clapperboard (Mô phỏng). The tab bar is rendered as a .safeAreaInset(edge:.bottom) overlay or via HomeView's ZStack to float it over scrollable content.

Font family: All text in the design uses "Be Vietnam Pro" which maps exactly to .appSans(size:weight:) — never use .system() or UIFont directly.

Dynamic data sources:
  - Greeting + date + streak → ProgressStore (streakCount, examDate)
  - Exam stats (score, avg, pass rate, high score, attempt count) → ProgressStore.examHistory
  - Progress (mastered, total, remaining) → ProgressStore.readinessStatus + QuestionStore.allQuestions
  - Điểm liệt row values → readinessStatus.diemLiet
  - Wrong count → progressStore.wrongAnswers.count
  - Bookmark count → progressStore.bookmarks.count
  - Last topic name → progressStore.lastTopicKey + QuestionStore.topic(forKey:)

The progress bar width for the amber track must be computed in a GeometryReader or via .overlay(GeometryReader) to translate fraction (e.g. 0.78) into actual points: barWidth = trackWidth * fraction.



## Practice (Luyen tap)  (frame YpM0O)

**Purpose:** The second tab of the main app. A scrollable hub that lets users pick what to study: a recommended topic hero card, a filterable list of question-bank topics with per-topic progress pills and a play button, and a hazard-situation section with chapter cards. A full-width primary button at the bottom of the question section starts an all-600-question session. The screen also owns two independent sets of filter chips — one global type filter at the top and one sub-filter for question mastery status — that scope the visible card list.

**Layout:**
Frame YpM0O: 393 pt wide, vertical layout, cornerRadius 40, clip true.
Background: linear gradient #FBF8F0 → #EEECE6 (55%) → #DAD3C4, rotation 205°.

--- 1. Status Bar (id: q00FtD) ---
Height 62 pt, horizontal, justifyContent: space-between, padding H 28.
Left: Text "9:41", .appSans(size:16, weight:.semibold), #171717.
Right: HStack gap 7 — lucide/signal 18×18 #171717, lucide/wifi 18×18 #171717, lucide/battery-full 24×18 #171717.

--- 2. ScrollView (content id: Bd2Nu) ---
Vertical layout, gap 20, padding: top 0, H 20, bottom 20.

  -- 2a. Header group (id: fQppq) --
  Vertical, gap 8, padding [8,0,4,0], fill width.
    Title: "Luyện tập", .appSans(size:32, weight:.bold), #0F0F12, letterSpacing -0.4, lineHeight 1.05.
    Subtitle: "Chọn phần để bắt đầu ôn", .appSans(size:13.5), #7A7166, lineHeight 1.4.

  -- 2b. Global Type Filter Chips (id: r7vseK) --
  Horizontal, gap 8, fill width, no wrap (horizontal scroll implied).
  Four chips: "Tất cả" | "Câu hỏi" | "Tình huống" | "Yêu thích".
  Selected chip (#0F0F12 fill, white text, weight 700, cornerRadius 18, padding [7,14]).
  Unselected chip (#FFFFFFCC fill, #0F0F12 text, weight 700, stroke #0F0F1214 1pt, cornerRadius 18, padding [7,14]).
  Font: .appSans(size:12.5, weight:.bold).
  Default selected: "Tất cả".

  -- 2c. Hero Recommendation FeatureCard (id: Tq7qD) --
  Reuses component/FeatureCard (EXgYq).
  Override on this instance:
    fill #FFFFFFCC (semi-transparent light card instead of the standard dark card).
    stroke #FFE9B0, strokeWidth 1.
    shadow disabled (effect: []).
  Content overrides:
    eyebrow / ssD3Z: "TIẾP TỤC HỌC", fill #7A4A00.
    title / z8w2Ob: "Hệ thống biển báo đường bộ", fill #0F0F12.
    Pill1 / oRqdi fill: #0F0F1212 (no label change — shows "25 câu" from base).
    Pill2 / h6tjOs fill: #0F0F1212 (shows "19 phút" from base).
    Pill3 / k0cN6P enabled: false (last gold pill hidden).
    Tag override text — pGvSD: "hôm qua", fill #7A7166; GLAer: "14 phút", fill #7A7166.
  NOTE: In SwiftUI this should be rendered as a LIGHT variant of FeatureCard (see new widget spec below).

  -- 2d. Section · Câu hỏi (id: aocYN) --
  Vertical layout, gap 14, fill width.

    2d-i. Section header row:
      Text "Câu hỏi", .appSans(size:22, weight:.bold), #0F0F12, letterSpacing -0.2.

    2d-ii. Mastery Sub-Filter Chips (id: m8ceJ):
      HStack gap 6, fill width (horizontally scrollable).
      Four chips: "Tất cả" | "Đang ôn" | "Chưa thuộc" | "Đã thuộc".
      Selected: cornerRadius 14, fill #0F0F12, text color #FFFFFF, weight 700, padding [6,12], size 12.
      Unselected: cornerRadius 14, fill #FFFFFFCC, text color #7A7166, weight 600, stroke #00000014 1pt, padding [6,12], size 12.
      Default selected: "Tất cả".

    2d-iii. Primary CTA Button (id: pvSHO):
      Full-width, height 52, cornerRadius 25, fill #FFC233, justifyContent: center.
      HStack gap 8: lucide/circle-play 16×16 fill #7A4A00 + Text "Ôn tập 600 câu · Đề tổng hợp" .appSans(size:14.5, weight:.bold) #7A4A00.
      This is NOT AppButton — it is a custom gold pill button specific to this screen.

    2d-iv. Topic cards (vertical list, gap between cards follows parent gap 14):
      Each card: HStack alignItems center, gap 12, cornerRadius 22, fill #FFFFFFCC, padding 12, fill width.
        Left: VStack gap 8, fill width.
          Title: e.g. "Khái niệm & quy tắc giao thông", .appSans(size:16, weight:.bold), #0F0F12, lineLimit 2, fixed-width text growth.
          Pills row: HStack gap 6.
            Pill A (question count): cornerRadius 14, fill #0F0F1212, text .appSans(size:11.5, weight:.semibold) #7A7166, padding [4,9]. e.g. "120 câu".
            Pill B (accuracy — shown if attempted): cornerRadius 14, fill #FFE9B0, text .appSans(size:11.5, weight:.bold) #7A4A00, padding [4,9]. e.g. "82% đúng".
            Pill B (not-attempted fallback): cornerRadius 14, fill #7373731A, text .appSans(size:12, weight:.medium) #737373, padding [5,10]. Text: "Chưa làm".
        Right: CircularActionButton — cornerRadius 22, fill #FFC233, 44×44, lucide/play 18×18 fill #7A4A00.

      Three topic cards visible:
        Card 1: "Khái niệm & quy tắc giao thông" | "120 câu" | "82% đúng"
        Card 2: "Hệ thống biển báo đường bộ" | "180 câu" | "68% đúng"
        Card 3: "Sa hình & kỹ thuật lái xe" | "90 câu" | "Chưa làm"

  -- 2e. Section · Tình huống (id: E95wfU) --
  Vertical layout, gap 14, fill width.

    2e-i. Section header row (id: K9fsld):
      Horizontal, justifyContent: space-between, fill width.
      Left: "Tình huống nguy hiểm", .appSans(size:22, weight:.bold), #0F0F12, letterSpacing -0.2.
      Right: "Xem tất cả", .appSans(size:13, weight:.bold), #7A4A00. Tappable.

    2e-ii. Hazard chapter cards (vertical list):
      Same card shell as topic cards (HStack, cornerRadius 22, fill #FFFFFFCC, padding 12).
        Left: VStack gap 8.
          Title: chapter name, .appSans(size:16, weight:.bold), #0F0F12.
          Pills row: HStack gap 4.
            Pill: chapter label, fill #0F0F1212, #7A7166, padding [4,8].
            Pill: situation count, fill #0F0F1212, #7A7166, padding [4,8].
            Pill: video download ratio — when complete: fill #D9F0DA, text #1F5A2A bold; when partial: fill #0F0F1212, text #7A7166.
        Right: CircularActionButton 44×44 fill #FFC233, lucide/play 18×18 #7A4A00.

      Two hazard cards visible:
        Card 1: "Trong khu vực đô thị" | "Chương 1" | "29 tình huống" | "29/29 video" (complete, green)
        Card 2: "Đường cao tốc" | "Chương 3" | "20 tình huống" | "12/20 video" (partial, neutral)

--- 3. Tab Bar (id: fnLZG / component dP4vH) ---
Pinned to bottom, fill width.
Outer padding: [0, 16, 14, 16].
Inner frosted bar (WUOfv): cornerRadius 30, fill #FAF9F7B3, height 60, padding 6,
  background blur radius 18, outer shadow color #00000018 y:8 blur:24.
Four tabs: Trang chủ (house) | Luyện tập (book-open, ACTIVE) | Thi thử (clipboard-list) | Mô phỏng (clapperboard).
Active tab item (Luyện tập — but NOTE: in the design snapshot the ACTIVE tab shown is "Trang chủ" with appPrimary #D4714E fill + tint pill; Luyện tập is shown INACTIVE #8A847C). This screen is the Luyện tập tab so the engineer must set tab selection = .luyen_tap, which will activate the book-open icon + label to appPrimary with tinted background pill.

**Tokens:** scaffoldBg: gradient linear #FBF8F0 → #EEECE6 (55%) → #DAD3C4 at 205° (matches ScaffoldBackground pattern; use as frame background).
cardBg flat cards: #FFFFFFCC (white 80% opacity, maps to cardBg with opacity modifier).
Card border on hero: #FFE9B0 (amber 30%, no token — literal).
appTextDark: #171717 (status bar text, section titles).
appTextMedium: #737373 (subtitle, "Chưa làm" pill text).
appTextLight / neutral: #7A7166 (subtitle "Chọn phần để bắt đầu ôn", count pills, unselected chip labels — slightly warmer than appTextMedium; no exact token, use literal #7A7166 or appTextMedium as closest).
appPrimary: #D4714E (tab bar active, FilterChip selected per existing FilterChip component — but on this screen the chips use #0F0F12 filled selected, not appPrimary; use custom chip not FilterChip).
CTA button fill: #FFC233 (gold — appWarning #F59E0B is close but design uses #FFC233; use literal).
CTA icon/text: #7A4A00 (dark amber — no token; use literal).
Hero FeatureCard light variant border: #FFE9B0 (literal).
Green download-complete pill: fill #D9F0DA, text #1F5A2A (no token; literal).
Mastery sub-filter selected: fill #0F0F12, text #FFFFFF.
Mastery sub-filter unselected: fill #FFFFFFCC, text #7A7166, stroke #00000014.
Global type chip selected: fill #0F0F12, text #FFFFFF.
Global type chip unselected: fill #FFFFFFCC, text #0F0F12, stroke #0F0F1214.
Font: .appSans throughout. No .appSerif or .appMono on this screen.
cornerRadius cards: 22. cornerRadius chips: 14–18. cornerRadius CTA: 25.

**Reuse widgets:** FeatureCard(eyebrow,title,tags,highlightLastTag,icon,action) — used for the hero recommendation, but with a LIGHT variant override (see new widget LightFeatureCard), TagPill(text,color?) — used inside topic and hazard chapter cards for count/accuracy/download-status pills, CircularActionButton(icon,size,subtle) — the gold play button on every topic/hazard card (44×44), SectionTitle(title) or inline Text at appSans 22 bold for section headings, SectionHeader — for the Tình huống header row with 'Xem tất cả' trailing link, AppTabBar(items,selection) — bottom tab bar (existing component/TabBar dP4vH), AdaptiveGrid — optionally for the card list if the designer intends a grid; the design shows a single-column list so use LazyVStack/VStack directly, ProgressBarView — for the hazard download bar if retained from current PracticeTab implementation

**New widgets:**
- PracticeTypeFilterBar(selected: Binding<PracticeTypeFilter>, options: [PracticeTypeFilter]) — horizontal scrollable row of dark-on-light toggle chips (cornerRadius 18, selected fill #0F0F12 white text, unselected fill #FFFFFFCC dark text + stroke #0F0F1214); PracticeTypeFilter enum cases: tatCa, cauHoi, tinhHuong, yeuThich. Replaces the existing FilterChip which uses appPrimary for selected.
- MasteryFilterBar(selected: Binding<MasteryFilter>, options: [MasteryFilter]) — identical chip shell to PracticeTypeFilterBar but smaller (cornerRadius 14, size 12, padding [6,12]); MasteryFilter enum cases: tatCa, dangOn, chuaThuoc, daThuoc. Sits inside the Câu hỏi section.
- GoldCTAButton(icon: String, label: String, action: () -> Void) — full-width height-52 pill button, fill #FFC233, cornerRadius 25, HStack gap 8: Lucide icon (16×16, fill #7A4A00) + Text appSans(14.5, bold) #7A4A00. Used for 'Ôn tập 600 câu · Đề tổng hợp' and could be reused for any gold primary CTA.
- TopicRowCard(title: String, questionCount: Int, accuracy: Double?, action: () -> Void) -> View — flat card (fill #FFFFFFCC, cornerRadius 22, padding 12): HStack with title + pills on left and CircularActionButton(icon:'play.fill') 44×44 on right. Accuracy nil → shows 'Chưa làm' neutral pill; accuracy present → shows gold accuracy pill (#FFE9B0 fill, #7A4A00 text).
- HazardChapterRowCard(title: String, chapterLabel: String, situationCount: Int, cachedVideos: Int, totalVideos: Int, action: () -> Void) -> View — same flat card shell as TopicRowCard; pills show chapter label, situation count, and download ratio; download pill turns green (#D9F0DA / #1F5A2A) when cachedVideos == totalVideos.
- LightFeatureCard(eyebrow: String, title: String, tags: [String], icon: String, action: () -> Void) -> View — a variant of FeatureCard with fill #FFFFFFCC (light semi-transparent), border #FFE9B0 strokeWidth 1, no shadow, dark text (#0F0F12) for title, #7A4A00 for eyebrow, and dark-fill (#0F0F1212) semi-transparent pills instead of white-opacity pills. Play button retains gold fill #FFC233 with #7A4A00 icon. Used only for the hero recommendation card on this screen.

**Copy:**
- Luyện tập
- Chọn phần để bắt đầu ôn
- Tất cả
- Câu hỏi
- Tình huống
- Yêu thích
- TIẾP TỤC HỌC
- Hệ thống biển báo đường bộ
- hôm qua
- 14 phút
- Câu hỏi
- Tất cả
- Đang ôn
- Chưa thuộc
- Đã thuộc
- Ôn tập 600 câu · Đề tổng hợp
- Khái niệm & quy tắc giao thông
- 120 câu
- 82% đúng
- Hệ thống biển báo đường bộ
- 180 câu
- 68% đúng
- Sa hình & kỹ thuật lái xe
- 90 câu
- Chưa làm
- Tình huống nguy hiểm
- Xem tất cả
- Trong khu vực đô thị
- Chương 1
- 29 tình huống
- 29/29 video
- Đường cao tốc
- Chương 3
- 20 tình huống
- 12/20 video
- Trang chủ
- Luyện tập
- Thi thử
- Mô phỏng

**States:** empty (no topics loaded — show EmptyState placeholder in the question section list; should not occur in practice since questionStore always has data after load);
loading (questionStore loading — show skeleton shimmer rows in place of topic cards and hazard cards);
populated / default (main state as designed — all sections visible);
filtered-cauHoi (global type chip = 'Câu hỏi' — hide Section·Tình huống, show only Section·Câu hỏi + hero);
filtered-tinhHuong (global type chip = 'Tình huống' — hide Section·Câu hỏi, show only Section·Tình huống + hero);
filtered-yeuThich (global type chip = 'Yêu thích' — show only bookmarked topics/situations; show EmptyState if none bookmarked);
mastery-sub-filter (any of 'Đang ôn' / 'Chưa thuộc' / 'Đã thuộc' — filters topic card list by mastery tier; if result is empty show EmptyState inside the section);
hero-no-resume (no recent study session — hero eyebrow changes to 'BẮT ĐẦU NGAY', title shows a default recommended topic, time pill hidden);
video-pill-complete (cachedVideos == totalVideos — pill fill #D9F0DA text #1F5A2A);
video-pill-partial (0 < cached < total — pill fill #0F0F1212 text #7A7166 showing 'X/Y video')

**Interactions:** Global type filter chips (r7vseK): tap any chip → update selectedTypeFilter state, animate section visibility; only one chip selected at a time.
Mastery sub-filter chips (m8ceJ): tap any chip → filter topic card list by mastery; only one selected.
Hero LightFeatureCard play button: navigates to openExam(.questionView(topicKey: recommendedTopic.key, startIndex: 0)) or resumes last session.
GoldCTAButton "Ôn tập 600 câu": navigates to openExam(.questionView(topicKey: AppConstants.TopicKey.allQuestions, startIndex: 0)).
Topic row card (any area, contentShape Rectangle): navigates to openExam(.questionView(topicKey: topic.key, startIndex: 0)).
Hazard chapter card: navigates to openExam(.hazardTest(mode: .chapter(chapter.id))).
"Xem tất cả" link in Tình huống header: pushes to a full hazard chapter list view (TopicsView or a dedicated HazardChaptersView).
Tab bar tabs: switching tabs via AppTabBar selection binding (managed by HomeView parent).
Haptic: .impact(.light) on chip selection, .impact(.medium) on CTA taps.

**Notes:** Most likely existing file: GPLX2026/Features/Home/PracticeTab.swift — this IS the current implementation of this screen. The design introduces these notable DIVERGENCES from the current code:
1. The current PracticeTab uses AdaptiveGrid (2-column) for topics; the new design uses a single-column vertical list of TopicRowCards.
2. A global type filter bar (Tất cả / Câu hỏi / Tình huống / Yêu thích) is new — the current file has no such filter.
3. A mastery sub-filter bar inside the question section is new — current file has no such filter.
4. The LightFeatureCard hero recommendation is new — current file has no such hero.
5. The GoldCTAButton primary action button replaces the current AppButton(.primary) styled button; the gold fill #FFC233 and dark amber text #7A4A00 are not tied to appPrimary/appOnPrimary tokens so a custom component is warranted.
6. The current hazard section retains a download-status bar and per-chapter download buttons; the design does NOT show a top-level download bar — video download status is encoded directly in the per-card pills. The chapterDownloadButton helper should be refactored into the HazardChapterRowCard widget.
7. The FilterChip component uses appPrimary for selected state, but this screen's chips use #0F0F12 (near-black); a new PracticeTypeFilterBar / MasteryFilterBar is required rather than reusing FilterChip.
8. Tab bar: the design renders this screen as INACTIVE for the Luyện tập tab (showing Trang chủ as active), which is an artifact of the design snapshot frame. In code the Luyện tập tab (book-open icon) must be the active tab when this view is presented; AppTabBar will handle highlighting via its selection binding.
9. The scroll content sits directly in a ScrollView with no .screenHeader modifier visible in the frame; the title "Luyện tập" is a large in-content header (32pt bold), not a navigation bar title — do NOT use .screenHeader("Luyện tập") modifier; remove it from PracticeTab.


## Exam (Thi thu)  (frame qQxJ1)

**Purpose:** Central landing screen for the "Thi thử" (Mock Exam) tab. Lets the user launch a random exam or a fixed numbered exam set, see personal stats at a glance, and filter/browse the history of past attempts and upcoming fixed exams. It is the entry point for all exam-flow navigation.

**Layout:**
Frame: width 393 pt, vertical layout, clip=true, cornerRadius=40. Background: linear gradient from #FBF8F0 (0%) → #EEECE6 (55%) → #DAD3C4 (100%) at 205°.

LAYER STACK (top to bottom):

1. STATUS BAR — "Z1Xmzi"
   - Height 62 pt, horizontal layout, justifyContent=space_between, padding=[0,28] (0 top/bottom, 28 left/right).
   - Left: Text "9:41", font Be Vietnam Pro 16/600, color #171717.
   - Right: HStack gap=7 — Signal icon 18×18 #171717, Wifi icon 18×18 #171717, Battery icon 24×18 #171717.

2. SCROLLABLE CONTENT AREA — "kJzHp"
   - Fills remaining height, vertical scroll (ScrollView).
   - Outer VStack, vertical layout, gap=18, padding=[0,20,20,20] (top 0, horizontal 20, bottom 20).
   - Contains 5 sub-sections in order:

   2a. PAGE HEADER — "ndjGX"
       - VStack, gap=8, padding=[8,0,4,0] (top 8, right/left 0, bottom 4), fill-container width.
       - Title: Text "Thi thử", font Be Vietnam Pro 32/700, color #0F0F12, letterSpacing=-0.4, lineHeight=1.05.
       - Subtitle: Text "Kiểm tra kiến thức tổng hợp", font Be Vietnam Pro 13.5/400, color #7A7166, lineHeight=1.4.

   2b. FEATURE CARD — "K1hON" (ref → EXgYq / FeatureCard component)
       - Fill-container width, zero additional gap (covered by outer gap=18).
       - Dark near-black card (#0F0F12), cornerRadius=22, padding=12, HStack gap=14.
       - Left VStack gap=12 (fill width):
         · Eyebrow: "BẮT ĐẦU NGAY" (uppercased already in design), font 10/800, tracking 1.2, color #FFC233 (appWarning/gold).
         · Title: "Đề thi mẫu", font Be Vietnam Pro 20/700, color #FFFFFF, letterSpacing=-0.2, fixed-width fill.
         · Pills HStack gap=6:
           – Pill 1: "25 câu" — fill #FFFFFF1F (white 12%), text #FFFFFF, font 11.5/700, padding [4,10], cornerRadius 14.
           – Pill 2: "19 phút" — fill #FFFFFF1F, text #FFFFFF, font 11.5/700, padding [4,10], cornerRadius 14.
           – Pill 3: "Đạt 21/25" — fill #FFC233 (gold), text #7A4A00, font 11.5/700, padding [4,10], cornerRadius 14. (highlighted last tag)
       - Right: circular play button 52×52, cornerRadius=26, fill=#FFC233, play icon 20×20 #7A4A00. Tappable → start random exam.
       - Drop shadow: color #0F0F1240, blur 20, offset y=8.

   2c. STATS CARD — "hXKyx"
       - Outer frame: cornerRadius=22, fill=#FFFFFFCC (white 80%), stroke=#00000014 (1 pt), padding=12, VStack gap=10, fill-container width.
       - Sub-section header "Y7vYP": HStack justifyContent=space_between, padding=[2,4,0,4]:
         · Left: Text "THỐNG KÊ CỦA BẠN", font 10/800, color #7A4A00, letterSpacing=1.2.
         · Right: Text "30 đề · 12 lượt", font 11/600, color #7A7166.
       - Average Hero "NZYV5": cornerRadius=10, fill=#FFE9B0, padding=12, HStack justifyContent=space_between, alignItems=center:
         · Left VStack gap=2 (r79ob):
           – Score row (jfytl): HStack alignItems=end, gap=5:
             · Large number Text "22", font 34/700, color #0F0F12, lineHeight=1.
             · Fraction Text "/ 25 câu", font 14/700, color #7A4A00.
           – Caption Text "Điểm trung bình · Kỷ lục 25/25", font 11.5/600, color #8A6A2A.
         · Right Pill "tyCDf": HStack gap=5, cornerRadius=100, fill=#1F5A2A, padding=[6,14]:
           – circle-check icon 14×14 #FFFFFF.
           – Text "Đạt", font 13/800, color #FFFFFF.
       - Stat Tiles container "TKmtj": cornerRadius=10, fill=#FAF9F7, stroke=#00000010 (1 pt), padding=[4,12], VStack gap=0:
         Row 1 "Đề đã thi" (o10dB): HStack alignItems=center, gap=12, padding=[10,0]:
           · Icon box 32×32, cornerRadius=10, fill=#FFE9B0: clipboard-list icon 16×16 #7A4A00.
           · Text "Đề đã thi", font 13.5/600, color #0F0F12, fill-container width.
           · Value Text "8/30", font 18/700, color #7A4A00.
           · chevron-right icon 16×16 #9A9389.
         Divider: rectangle height=1, fill=#00000010, fill-container width.
         Row 2 "Số lần đạt" (EyT9L): HStack alignItems=center, gap=12, padding=[10,0]:
           · Icon box 32×32, cornerRadius=10, fill=#D9F0DA: circle-check icon 16×16 #1F5A2A.
           · Text "Số lần đạt", font 13.5/600, color #0F0F12, fill-container width.
           · Value Text "6/12", font 18/700, color #1F5A2A.
           · chevron-right icon 16×16 #9A9389.
         Divider: rectangle height=1, fill=#00000010, fill-container width.
         Row 3 "Tổng lượt thi" (IueTS): HStack alignItems=center, gap=12, padding=[10,0]:
           · Icon box 32×32, cornerRadius=10, fill=#CFE3FF: history icon 16×16 #143A75.
           · Text "Tổng lượt thi", font 13.5/600, color #0F0F12, fill-container width.
           · Value Text "12", font 18/700, color #143A75.
           · chevron-right icon 16×16 #9A9389.

   2d. FILTER BAR — "rsKX6"
       - HStack gap=8, no outer padding (comes from parent's horizontal padding=20).
       - Three filter chips:
         · Chip 1 "Tất cả" — SELECTED: fill=#0F0F12, cornerRadius=14, padding=[6,12], label font 12.5/700 color #FFFFFF.
         · Chip 2 "Đã thi" — UNSELECTED: fill=#FFFFFFCC, cornerRadius=14, padding=[6,12], stroke=#00000014, label font 12.5/600 color #7A7166.
         · Chip 3 "Chưa thi" — UNSELECTED: fill=#FFFFFFCC, cornerRadius=14, padding=[6,12], stroke=#00000014, label font 12.5/600 color #7A7166.

   2e. EXAM LIST SECTION — "MFUk9"
       - VStack gap=12, fill-container width.
       - Section header "nHXlT": HStack justifyContent=space_between, fill-container width:
         · Left: Text "Lịch sử & đề cố định", font 22/700, color #0F0F12, letterSpacing=-0.2.
         · Right: Text "6 đề", font 12/600, color #7A7166.
       - Exam list card "Q8hWLC": cornerRadius=20, fill=#FFFFFFCC, clip=true, VStack gap=0, fill-container width.
         Six exam rows separated by 1 pt dividers (fill=#0000000D):

         ROW PATTERN — two visual states:
         STATE A — Attempted & passed (Đề 1, Đề 2): green accent (#D9F0DA).
           HStack alignItems=center, gap=12, padding=[8,16]:
           · Name Text "Đề N", font 14.5/700, color #0F0F12.
           · Spacer (fill-width height=1 invisible frame).
           · Score pill: cornerRadius=14, fill=#D9F0DA, padding=[5,10]: Text "NN/35", font 12/700, color #1F5A2A.
           · Action circle 34×34, cornerRadius=17, fill=#D9F0DA: check icon 15×15 #1F5A2A.

         STATE B — Attempted & failed (Đề 3): red accent (#FFD7CF).
           Same structure; Score pill fill=#FFD7CF, text color #8A2A1F; Action circle fill=#FFD7CF, check icon #8A2A1F.

         STATE C — Not yet attempted (Đề 4, Đề 5, Đề 6): gold accent (#FFC233). No score pill shown.
           HStack alignItems=center, gap=12, padding=[8,16]:
           · Name Text "Đề N", font 14.5/600, color #0F0F12 (weight drops to 600 vs 700 for attempted).
           · Spacer.
           · Action circle 34×34, cornerRadius=17, fill=#FFC233: play icon 15×15 #7A4A00.

         Observed data: Đề 1 → 34/35 pass, Đề 2 → 33/35 pass, Đề 3 → 19/25 fail, Đề 4/5/6 → not attempted.

3. TAB BAR — "E7muV" / "WUOfv" (ref → dP4vH)
   - Frame: fill-container width, padding=[0,16,14,16].
   - Inner bar: height=60, cornerRadius=30, fill=#FAF9F7B3 (white 70%), HStack justifyContent=space_between, padding=6.
   - Background blur radius=18, outer shadow color=#00000018 blur=24 offset y=8.
   - Four tab items in equal-width fill columns, each a VStack gap=3 cornerRadius=24 justifyContent=center height=fill:
     · "Trang chủ" — house icon 22×22, label font 10/600; ACTIVE state: fill=#D4714E1F, icon+label color=#D4714E.
     · "Luyện tập" — book-open icon 22×22, label font 10/500; INACTIVE: no fill, icon+label color=#8A847C.
     · "Thi thử" — clipboard-list icon 22×22, label font 10/500; INACTIVE per design data (active tab shown is "Trang chủ" in the component, but THIS screen is "Thi thử" so implement with "Thi thử" tab as active).
     · "Mô phỏng" — clapperboard icon 22×22, label font 10/500; INACTIVE: no fill, icon+label color=#8A847C.

**Tokens:** Background gradient: linear 205° — #FBF8F0 → #EEECE6 → #DAD3C4 (no app token; implement as custom gradient matching ScaffoldBackground pattern or add new gradient definition). 

Status bar text/icons: #171717 → appTextDark.

Page title: #0F0F12 → appTextDark (slightly richer black, literal hex).
Page subtitle: #7A7166 → appTextMedium (close enough; literal is #7A7166, not a token match — use literal).

FeatureCard: cardBg=none; uses hardcoded #0F0F12 near-black fill, gold=#FFC233=appWarning. Tags pills with white 12% = Color.white.opacity(0.12). Last/highlighted tag fill=appWarning, text=#7A4A00 (literal, no token).

Stats card outer: fill=#FFFFFFCC (white 80%) = Color.white.opacity(0.8), stroke=#00000014 (black 8%). cornerRadius=22.

Average hero: fill=#FFE9B0 (warm amber, no token; literal). Large score number: appTextDark. Fraction color=#7A4A00 (no token; literal dark amber). Caption color=#8A6A2A (no token; literal). Pass pill fill=#1F5A2A (dark green, no token; literal).

Stat tile container: fill=cardBg (#FAF9F7), stroke=#00000010.
Icon box fills: #FFE9B0 (amber), #D9F0DA (green tint), #CFE3FF (blue tint) — all literal, no tokens.
Icon colors: #7A4A00 (amber dark), #1F5A2A (dark green), #143A75 (dark blue) — literal.
Stat value colors: same as icon colors respectively.
Chevron: #9A9389 (literal muted gray).

Filter chips SELECTED: fill=#0F0F12 (appTextDark near-black), label=white.
Filter chips UNSELECTED: fill=#FFFFFFCC, stroke=#00000014, label=#7A7166 (appTextMedium-ish, use literal).

Section title: #0F0F12 = appTextDark. Count label: #7A7166 = appTextMedium.

Exam list card: fill=#FFFFFFCC, cornerRadius=20.
Dividers inside list: fill=#0000000D (black 5%).
Row dividers: fill=#0000000D.
Exam name text: appTextDark (#0F0F12).
Pass score pill fill: #D9F0DA, text #1F5A2A.
Fail score pill fill: #FFD7CF, text #8A2A1F.
Not-attempted action fill: #FFC233 = appWarning, icon #7A4A00 (literal).
Pass action fill: #D9F0DA, icon #1F5A2A. Fail action fill: #FFD7CF, icon #8A2A1F.

Tab bar inner: fill=#FAF9F7B3 ≈ cardBg at 70%.
Active tab: fill tint=#D4714E1F (appPrimary 12%), icon+label appPrimary.
Inactive tab: no fill, color=#8A847C (literal muted warm gray).

Fonts: .appSans only throughout (Be Vietnam Pro). No .appSerif or .appMono on this screen (FeatureCard title uses .appSerif per existing FeatureCard.swift implementation — keep that).

Spacing tokens: outer horizontal padding 20 pt, section gap 18 pt, card inner padding 12 pt, stats tile row vertical padding 10 pt, tab bar bottom padding 14 pt.

**Reuse widgets:** FeatureCard(eyebrow:title:tags:highlightLastTag:icon:action:) — reuse directly for the 'Đề thi mẫu' hero CTA card (section 2b). Pass eyebrow='BẮT ĐẦU NGAY', title='Đề thi mẫu', tags=['25 câu','19 phút','Đạt 21/25'], highlightLastTag=true, icon='play.fill'., AppTabBar(items:selection:) — reuse for the bottom 4-tab frosted bar. Active tab is index 2 ('Thi thử', systemImage: 'clipboard-list')., FilterChip(label:isSelected:action:) — reuse for the 3-chip filter bar (Tất cả / Đã thi / Chưa thi). Note: the existing FilterChip uses larger vertical padding (12 pt) and a Capsule shape; the design shows cornerRadius=14 pill with padding=[6,12] — acceptable match, or wrap with smaller padding override., SectionHeader — inspect existing SectionHeader.swift; the design's section header (Lịch sử & đề cố định / 6 đề) matches a title+count HStack. Reuse if API matches, otherwise build inline., ScaffoldBackground() or AnimatedBackground() — the gradient background matches the scaffold gradient; verify tokens match #FBF8F0→#DAD3C4 before reusing.

**New widgets:**
- ExamStatsCard — VStack(spacing:10), outer cornerRadius=22, fill=white.opacity(0.8), stroke 1pt black.opacity(0.08). Sub-components: (1) a header HStack with eyebrow label + caption string; (2) ExamAverageHero (see below); (3) ExamStatTileList (see below). API: ExamStatsCard(examCount:Int, attemptCount:Int, averageScore:Int, maxScore:Int, recordScore:Int, passRate:Int, attemptPassCount:Int, totalAttempts:Int, onTapExamsDone:(()->Void)?, onTapPasses:(()->Void)?, onTapTotal:(()->Void)?)
- ExamAverageHero — HStack(spacing:0) justifyContent=spaceBetween, alignItems=center, fill=#FFE9B0, cornerRadius=10, padding=12. Left: VStack(spacing:2) with score row (large number + '/N câu' fraction baseline-aligned) and caption string. Right: status pill (pass/fail). API: ExamAverageHero(averageScore:Int, totalQuestions:Int, recordScore:Int, isPassing:Bool)
- ExamStatTileRow — single tappable row: HStack(spacing:12), padding=[10,0]. Icon box 32×32 cornerRadius=10. Label text fill-width. Value text. Chevron. API: ExamStatTileRow(iconName:String, iconBoxColor:Color, iconColor:Color, label:String, value:String, valueColor:Color, onTap:(()->Void)?). Used three times inside ExamStatTileList.
- ExamListRow — single exam row inside the list card. HStack(spacing:12), padding=[8,16]. Displays exam name, optional score pill, and a circular action button. Three states driven by ExamListRowState enum: .passed(score:String), .failed(score:String), .notAttempted. API: ExamListRow(examName:String, state:ExamListRowState, onTap:()->Void). ExamListRowState: enum with cases passed(score:String), failed(score:String), notAttempted.
- ExamFilterBar — HStack(spacing:8) wrapping three ExamFilterChip items (or reused FilterChip). Manages single-selection state. API: ExamFilterBar(selection:Binding<ExamFilter>) where ExamFilter: enum { case all, attempted, notAttempted }.

**Copy:**
- Thi thử
- Kiểm tra kiến thức tổng hợp
- BẮT ĐẦU NGAY
- Đề thi mẫu
- 25 câu
- 19 phút
- Đạt 21/25
- THỐNG KÊ CỦA BẠN
- 30 đề · 12 lượt
- / 25 câu
- Điểm trung bình · Kỷ lục 25/25
- Đạt
- Đề đã thi
- 8/30
- Số lần đạt
- 6/12
- Tổng lượt thi
- 12
- Tất cả
- Đã thi
- Chưa thi
- Lịch sử & đề cố định
- 6 đề
- Đề 1
- Đề 2
- Đề 3
- Đề 4
- Đề 5
- Đề 6
- 34/35
- 33/35
- 19/25
- Trang chủ
- Luyện tập
- Mô phỏng

**States:** EMPTY (no attempts yet): Stats card hero shows "0/25 câu", no pass pill visible (or show a neutral "Chưa thi" pill in gray). All three stat rows show 0 values. ExamListSection shows rows for all 6 fixed sets in .notAttempted state only. The 'Đã thi' and 'Chưa thi' filter chips, when selected, show respective empty-state or full list.

LOADING: QuestionStore or ExamResultStore is loading results — show shimmer/skeleton on the stats card hero and the stat tile rows. FeatureCard is static and always shown.

POPULATED (normal, shown in design): Stats card fully filled, exam list has mixed pass/fail/not-attempted rows as described.

FILTER — 'Tất cả' (default): Show all 6 exam rows.
FILTER — 'Đã thi': Show only rows with .passed or .failed state.
FILTER — 'Chưa thi': Show only rows with .notAttempted state.

EXAM ROW — passed: green pill + check action button.
EXAM ROW — failed: red/coral pill + check action button.
EXAM ROW — not attempted: no score pill, gold play action button.

LAST TAG IN FEATURE CARD — dynamic: the third pill "Đạt 21/25" should reflect actual last attempt score on the random exam if available; falls back to a static prompt like "Thử ngay!" if no history.

TAB BAR: "Thi thử" tab is active (clipboard-list icon, appPrimary color, appPrimary 12% tint background pill).

**Interactions:** 1. FeatureCard play button tap → launch random/shuffled mock exam: present MockExamView(examSetId: nil) full-screen (modal or navigation push depending on existing ExamFlow navigation).

2. Stats tile row "Đề đã thi" chevron tap → navigate to a filtered exam history list showing only attempted exams (ExamHistoryDetailView or similar).

3. Stats tile row "Số lần đạt" chevron tap → navigate to exam history filtered by passed attempts.

4. Stats tile row "Tổng lượt thi" chevron tap → navigate to full exam attempt history (ExamHistoryDetailView).

5. Filter chips (Tất cả / Đã thi / Chưa thi) tap → update local @State filter selection; re-filter the exam list below. Single-select: tapping a chip deselects the currently active one and selects the tapped one. Visual: selected chip gets fill=#0F0F12 label=white; unselected gets semi-transparent fill with border.

6. Exam list row action button tap (play icon, gold) → launch that specific fixed exam: present MockExamView(examSetId: examIndex) full-screen.

7. Exam list row action button tap (check icon, green/red) → navigate to the exam result / history detail for that attempt: present ExamHistoryDetailView for the associated result.

8. Tab bar items tap → switch tabs (handled by AppTabBar / parent TabView). This screen corresponds to tab index 2 ("Thi thử").

9. Scrolling: the entire content area (everything between status bar and tab bar) is scrollable; ScrollView(.vertical, showsIndicators: false). The tab bar and status bar are fixed (not inside scroll).

**Notes:** Most likely existing file: GPLX2026/Features/Exam/MockExamView.swift is the in-exam view (it delegates to BaseExamView). The "Thi thử" hub screen shown in this design does NOT yet have a corresponding file — it needs to be created as a new file, most likely named ExamHubView.swift (or MockExamHubView.swift / ExamLandingView.swift) inside GPLX2026/Features/Exam/.

Key fidelity notes:
- The Stats Card outer container uses fill=#FFFFFFCC (80% white), NOT cardBg (which is opaque #FAF9F7). Keep the translucency — this card sits on the gradient background and the semi-transparency is intentional.
- The inner tile container (TKmtj) uses opaque cardBg #FAF9F7. Do not confuse the two layers.
- The three filter chips in the design use cornerRadius=14 (pill-like but not fully capsule at small size). Existing FilterChip uses Capsule(). Either override the clip shape or create ExamFilterBar with its own chip style. The padding difference (design: [6,12] vs FilterChip: [12,16]) is significant — the design chips are more compact.
- ExamListRow score pill uses cornerRadius=14 with padding=[5,10] — very similar to TagPill; consider reusing TagPill(text:color:) for the score display.
- ExamListRow action circle is 34×34 with cornerRadius=17 — essentially a circle. This is close to CircularActionButton(icon:size:subtle:); check if size=34 and the required fill colors are supportable before reusing.
- The FeatureCard in this screen uses eyebrow in all-caps with gold color and sets title font to 20pt/700 in the design, but the existing FeatureCard.swift uses .appSerif for the title. Keep that serif font per implementation.
- FeatureCard's 'tags' third pill "Đạt 21/25" acts as the highlighted pill (highlightLastTag=true) — it shows in gold fill with dark amber text. Wire this to the actual last best score from ExamResult history.
- "Kỷ lục 25/25" in the subtitle caption means "Record 25/25" — this is the best score ever achieved, stored in ProgressStore. The average score "22/25" is the computed average across all attempts.
- The design shows "Trang chủ" tab as active in the TabBar component definition, but this screen is the "Thi thử" tab — pass selection=2 (0-indexed: Trang chủ=0, Luyện tập=1, Thi thử=2, Mô phỏng=3).
- The background gradient (#FBF8F0 → #EEECE6 → #DAD3C4 at 205°) closely matches the existing scaffold gradient; verify ScaffoldBackground() uses the same stops. If not, use AnimatedBackground() or a custom ZStack with a LinearGradient defined inline.
- The ExamListSection only shows 6 fixed exam sets (Đề 1–6) in the design. In production this list should be dynamic, derived from the question bank's defined exam sets. The count label "6 đề" should be computed dynamically.
- Swift 6 / strict concurrency: all store access from @Observable stores must be on MainActor; history loading and score computation should happen in a Task on appear and stored in @State.


## Question / Exam taking  (frame CPkIw)

**Purpose:** The primary in-exam question screen for the mock exam (and simulation) flow. Displays one question at a time with its answer options, an optional memory-tip teaser, a countdown timer capsule, bookmark toggle, and prev/next navigation. A full-screen overlay sheet (Question Jump Overlay) lets users jump to any question by tapping a grid cell. The design uses a warm off-white gradient scaffold (no tab bar), a custom inline exam bar above the content, and Liquid-Glass buttons throughout.

**Layout:**
The frame is 393 pt wide, cornerRadius 40, clip = true. Background is a linear gradient at 205 deg: #FBF8F0 → #EEECE6 (55%) → #DAD3C4. Layout is vertical (VStack), no gap between the three top-level children: Status Bar, Exam Bar, and scrollable Content area.

1. STATUS BAR (id: jRd0l)
   - height: 62, width: fill, horizontal padding 28
   - HStack justifyContent: space_between
   - Leading: "9:41" text, .appSans size 16 weight 600, fill #171717 (appTextDark)
   - Trailing: HStack gap 7 — signal icon 18×18, wifi icon 18×18, battery-full icon 24×18, all fill #171717

2. EXAM BAR (id: RqBOV)
   - width: fill, padding [top 0, trailing 20, bottom 12, leading 20]
   - HStack justifyContent: space_between, alignItems: center
   - Leading: CLOSE button (id: urQmE) — circle 36×36, cornerRadius 18, fill #FFFFFFCC, stroke #00000014 1pt, contains X icon 18×18 fill #0F0F12
   - Center: COUNTER GROUP (id: vnHJk) — HStack gap 4, alignItems: end
       • "Câu 12" text, .appSans size 18 weight 700, fill #0F0F12, letterSpacing -0.2
       • "/ 35" text, .appSans size 13 weight 600, fill #7A7166
   - Trailing: ACTIONS HStack gap 8
       • BOOKMARK button (id: Z6Nmu) — circle 36×36, cornerRadius 18, fill #FFFFFFCC, stroke #00000014 1pt, bookmark icon 16×16 fill #7A7166 (unfilled state shown)
       • TIMER CAPSULE (id: lkKOV) — HStack gap 6, padding [6, 12], cornerRadius 18, fill #0F0F12
           - timer icon 14×14 fill #FFE9B0
           - "18:24" text, .appSans size 15 weight 700, fill #FFFFFF

3. SCROLLABLE CONTENT (id: E8yWH)
   - VStack gap 16, padding [top 16, trailing 20, bottom 20, leading 20]
   - Fills remaining vertical space with a ScrollView

   3a. BADGES ROW (id: ZXDNm) — HStack gap 6
       • TagPill "Câu 12" — default neutral style (no custom color)
       • TagPill "Điểm liệt" — fill background #EF44441F, text fill #EF4444 (appError)

   3b. META ROW (id: LUMj9) — HStack gap 10, alignItems: center, padding bottom 2
       • book-open icon 14×14 fill #7A7166
       • "Khái niệm & quy tắc" .appSans size 12 weight 600, fill #7A7166
       • "·" separator .appSans size 12 weight 700, fill #7A7166
       • "Chương 1" .appSans size 12 weight 600, fill #7A7166

   3c. QUESTION TEXT (id: LajAJ)
       • Full-width fixed-width Text
       • "Khi điều khiển xe trên đường có hiệu lệnh của người điều khiển giao thông, người lái xe phải xử lý như thế nào?"
       • .appSans size 19 weight 700, fill #0F0F12, letterSpacing -0.3, lineHeight 1.3

   3d. OPTIONS LIST (id: jMLtM) — VStack gap 10, width: fill
       Each option row: HStack gap 12, alignItems: center, cornerRadius 16, padding 14 all sides, width: fill
       DEFAULT (unselected) state:
         - fill #FFFFFFCC, stroke #0F0F1214 width 1
         - LETTER BADGE: 28×28, cornerRadius 14, fill #0F0F1212
             • Letter text .appSans size 13 weight 700, fill #7A7166
         - OPTION TEXT: .appSans size 13.5 weight 500, fill #0F0F12, lineHeight 1.35, width: fill
       SELECTED/CORRECT state (Option C shown as example):
         - fill gradient: [#FFFFFF, #FFC23326] (white + amber 15% wash)
         - stroke #FFC233 width 1
         - LETTER BADGE: fill #FFC233 (solid amber), letter text fill #7A4A00 (dark amber)
         - OPTION TEXT: weight 600, fill #0F0F12
       Four options: A, B, C, D with their respective answer texts (see copy section)

   3e. MEMORY TIP TEASER (id: gqVbB) — HStack gap 10, alignItems: center, cornerRadius 18, fill #FFE9B0, stroke #FFE9B0 width 1, padding 8, width: fill
       • LEFT: lightbulb-icon box (id: QXoct) — 36×36, cornerRadius 10, fill #FFFFFFB3, contains lightbulb icon 18×18 fill #7A4A00
       • RIGHT: VStack gap 2, width: fill
           - "MẸO GHI NHỚ" eyebrow — .appSans size 10 weight 800, fill #7A4A00, letterSpacing 0.8
           - tip body text — .appSans size 13 weight 600, fill #5C3700, lineHeight 1.3, width: fill

   3f. FOOTER BUTTON ROW (id: Sc3wa) — HStack gap 12, padding top 8, width: fill
       • PREV button (id: m8W8T): fixed width 120, height 50, cornerRadius 25, fill #FFFFFFCC, stroke #0F0F1233 width 1.5
           - HStack gap 6, justifyContent: center, alignItems: center
           - circle-chevron-left icon 16×16 fill #7A4A00
           - "Câu trước" .appSans size 15 weight 700, fill #0F0F12
       • CONFIRM/NEXT button (id: m5RTpD): fill_container, height 50, cornerRadius 25, fill #FFC233
           - HStack gap 6, justifyContent: center, alignItems: center
           - "Xác nhận đáp án" .appSans size 15 weight 700, fill #7A4A00
           - circle-check icon 16×16 fill #7A4A00

4. QUESTION JUMP OVERLAY (id: GOqIh) — absolute positioned, 393×735, z-order: above content
   - fill #0F0F12B3 (dark scrim 70% opacity)
   - VStack justifyContent: end — sheet slides up from bottom
   - SHEET (id: z8LCc): width fill, cornerRadius [28, 28, 0, 0] (top corners only), fill #FFFFFF, padding [12, 20, 24, 20], VStack gap 14
       a. GRABBER (id: HSxRp): full width, padding bottom 4, justifyContent: center
          • 40×4 rectangle, cornerRadius 2, fill #00000022
       b. HEADER (id: ARTxh): HStack justifyContent: space_between, alignItems: center, width: fill
          • Title group VStack gap 2:
              - "Chọn câu hỏi" .appSans size 17 weight 800, fill #0F0F12, letterSpacing -0.2
              - "Đề số 04 · 12/35 đã làm" .appSans size 12 weight 600, fill #7A7166
          • Close button (id: z8wNI): 36×36, cornerRadius 18, fill #F0EEE9, X icon 18×18 fill #0F0F12
       c. LEGEND ROW (id: cGcgt): HStack gap 14, justifyContent: center, width: fill
          Four legend items each: HStack gap 5, alignItems: center
          • 10×10 rectangle cornerRadius 3 + label text .appSans size 11 weight 600 fill #5A544C
          - Đúng: dot fill #30D158
          - Sai: dot fill #FF3B30
          - Đánh dấu: dot fill #FFC233
          - Chưa làm: dot fill #D8D3CA
       d. QUESTION GRID (id: z3jwN9): VStack gap 8, width: fill
          6 rows × 6 columns (35 cells + 1 spacer), LazyVGrid 6-column
          Each cell: 44 pt tall, fill_container width, cornerRadius 10, alignItems: center, justifyContent: center
          Number label: .appSans size 15 weight 700, fill #FFFFFF (colored states) or #0F0F12 (unanswered)
          Cell state colors:
          - Correct (answered right): fill #30D158
          - Wrong (answered wrong): fill #FF3B30
          - Flagged/Bookmarked: fill #FFC233
          - Unanswered: fill #FFFFFFCC, stroke #00000014 width 1 (semi-transparent white)
       e. CTA BUTTON (id: C8pvFN): width fill, height 50, cornerRadius 25, fill #D4714E (appPrimary)
          • "Tiếp tục làm bài" .appSans size 15 weight 700, fill #FFFFFF

**Tokens:** Background gradient: linear 205 deg #FBF8F0 → #EEECE6 → #DAD3C4 (scaffoldBg warm variant, no existing token — use literal Color(hex:"FBF8F0") to Color(hex:"DAD3C4"))
appTextDark: #0F0F12 (slightly darker than standard #171717 — use literal or extend token)
appTextMedium: #7A7166 (warm-brown mid tone, maps conceptually to appTextMedium but warmer — use literal)
Amber accent: #FFC233 (appWarning adjacent; no exact token — use literal or create local constant)
Amber dark text: #7A4A00 (on-amber dark text, no token — literal)
Amber light text: #5C3700 (tip body, no token — literal)
Memory tip bg: #FFE9B0 (amber/cream, no token — literal)
Timer capsule bg: #0F0F12 (near-black, reuse as Color(hex:"0F0F12"))
Close button: #FFFFFFCC (white 80% alpha glass)
Sheet close: #F0EEE9 (light warm gray, no token — literal)
Sheet bg: #FFFFFF (pure white)
Scrim: #0F0F12B3 (70% black)
Grid cell correct: #30D158 (appSuccess approximate)
Grid cell wrong: #FF3B30 (appError approximate, slightly different from #EF4444)
Grid cell flagged: #FFC233 (amber)
Grid cell unanswered: #FFFFFFCC stroke #00000014
Legend correct dot: #30D158
Legend wrong dot: #FF3B30
Legend flagged dot: #FFC233
Legend undone dot: #D8D3CA
cardBg: #FAF9F7 (existing token for card surfaces)
Corner radii: sheet 28 (top), option card 16, letter badge 14, timer capsule 18, prev/next buttons 25, grid cell 10
Spacing: content padding 20H, section gap 16, option gap 10, footer gap 12, overlay sheet gap 14, grid row gap 8, grid cell gap 8

**Reuse widgets:** TagPill(text:color?) — reuse for 'Câu 12' (neutral) and 'Điểm liệt' (color: .appError), ExamTimerCapsule(text:isUrgent:) — the timer capsule in the exam bar, note the DESIGN shows dark (#0F0F12) background with white text always; consider adding a dark variant parameter or override the capsule background locally, ExamBottomBar(currentIndex:totalCount:answeredIndices:nextLabel:prevLabel:isNextDisabled:showPrev:onPrev:onNext:onSelectIndex:) — maps to the footer row with Prev + Confirm/Next + grid ring, ExamQuestionGridSheet(totalQuestions:answeredIndices:currentIndex:onSelect:) — the question jump sheet grid; existing sheet tracks answered vs. unanswered but needs bookmarked/wrong state extensions (see notes), QuestionGridButton — the progress ring that triggers ExamQuestionGridSheet as a sheet, AnswerOptionCard(letter:text:isSelected:isConfirmed:isCorrect:) — each answer option row A/B/C/D, ExplanationBox(content:) — can be adapted for the memory tip teaser, though design uses a distinct amber card style (see new widget below)

**New widgets:**
- ExamTopBar: View — custom inline bar replacing the standard NavigationBar; API: ExamTopBar(currentQuestion: Int, totalQuestions: Int, timerText: String, isUrgent: Bool, isBookmarked: Bool, onClose: () -> Void, onToggleBookmark: () -> Void). Renders the Close glass-circle button (left), counter group center, bookmark glass-circle + dark timer capsule (right). Height driven by content + 12 pt bottom padding. Note: this replaces ExamToolbar modifier for screens that embed their own non-NavigationStack chrome.
- MemoryTipTeaser: View — amber card for the in-question mnemonic teaser; API: MemoryTipTeaser(eyebrow: String = 'MẸO GHI NHỚ', tip: String). Renders the amber HStack with lightbulb icon box + eyebrow + tip body. Fill #FFE9B0, cornerRadius 18, padding 8. Separate from ExplanationBox (which is for revealed full explanation, different style).
- ExamQuestionJumpOverlay: View — the dark-scrim + bottom sheet overlay for question jumping; API: ExamQuestionJumpOverlay(isPresented: Binding<Bool>, totalQuestions: Int, currentIndex: Int, answeredIndices: Set<Int>, wrongIndices: Set<Int>, flaggedIndices: Set<Int>, examSetLabel: String, onSelect: (Int) -> Void, onContinue: () -> Void). Renders full-screen scrim + sheet with grabber, header, 4-item legend (Đúng/Sai/Đánh dấu/Chưa làm), 6-col grid with 4-state coloring, and 'Tiếp tục làm bài' CTA. This is distinct from ExamQuestionGridSheet which lacks the wrong/flagged states and the sheet chrome shown in design.
- QuestionMetaRow: View — small metadata row below badges; API: QuestionMetaRow(category: String, chapter: String). Renders book-open icon + category + dot separator + chapter, all in #7A7166, .appSans size 12 weight 600, gap 10.

**Copy:**
- 9:41
- Câu 12
- / 35
- 18:24
- Câu 12
- Điểm liệt
- Khái niệm & quy tắc
- ·
- Chương 1
- Khi điều khiển xe trên đường có hiệu lệnh của người điều khiển giao thông, người lái xe phải xử lý như thế nào?
- A
- Tuân thủ hiệu lệnh của người điều khiển giao thông
- B
- Tuân thủ theo tín hiệu đèn giao thông
- C
- Tuân thủ hiệu lệnh của người điều khiển giao thông, kể cả khi khác với đèn tín hiệu
- D
- Đi theo biển báo hiệu đường bộ
- MẸO GHI NHỚ
- Người điều khiển giao thông luôn được ưu tiên trên mọi tín hiệu khác.
- Câu trước
- Xác nhận đáp án
- Chọn câu hỏi
- Đề số 04 · 12/35 đã làm
- Đúng
- Sai
- Đánh dấu
- Chưa làm
- Tiếp tục làm bài
- Thoát bài thi?
- Tiếp tục
- Thoát
- Bài thi sẽ không được lưu.
- Nộp bài?
- Quay lại
- Nộp bài
- Đã trả lời:

**States:** OPTION STATES (AnswerOptionCard):
- Unanswered/idle: fill #FFFFFFCC, stroke #0F0F1214, letter badge fill #0F0F1212, letter color #7A7166, text weight 500
- Selected (pre-confirm): fill gradient [#FFFFFF, #FFC23326], stroke #FFC233, letter badge fill #FFC233, letter color #7A4A00, text weight 600
- Correct (after confirm): fill green wash (#30D158 ~10%), letter badge fill #30D158, letter #FFFFFF, checkmark icon trailing
- Wrong selected (after confirm): fill red wash, letter badge fill #FF3B30, letter #FFFFFF, xmark icon trailing
- Correct but not selected (after confirm): highlighted green, no icon

TIMER CAPSULE STATES:
- Normal: dark pill fill #0F0F12, timer icon fill #FFE9B0, text #FFFFFF
- Urgent (≤ N seconds): background stays dark but icon may pulse; if reusing ExamTimerCapsule, add .dark variant that ignores isUrgent color change and stays white/dark always

BOOKMARK BUTTON:
- Unfilled: bookmark icon lucide outline, fill #7A7166
- Bookmarked: bookmark.fill system icon, fill appPrimary (#D4714E)

PREV BUTTON:
- Active: fill #FFFFFFCC, stroke #0F0F1233 1.5pt, text fill #0F0F12
- Disabled (first question): opacity 0.4

CONFIRM/NEXT BUTTON:
- "Xác nhận đáp án" (no answer selected, simulation mode): disabled, opacity reduced
- "Xác nhận đáp án" (answer selected): enabled, fill #FFC233
- After confirmation: label changes to "Câu tiếp" or "Nộp bài" (last question), fill stays #FFC233 or switches to appPrimary for submit

MEMORY TIP TEASER:
- Visible: animates in with .opacity + .move(edge: .bottom) transition after question loads
- Hidden: collapsed when question has no tip

LOADING STATE:
- Show ExamLoadingView() skeleton while questions array is empty

QUESTION JUMP OVERLAY:
- Closed: overlay not present (not in hierarchy or opacity 0)
- Open: full-screen scrim + sheet visible, triggered by tapping progress ring or counter group
- Grid cell states: correct (#30D158 fill, white number), wrong (#FF3B30 fill, white number), flagged (#FFC233 fill, white number), unanswered (glass-white fill + border, dark number), current (appPrimary fill, white number)

EXAM BAR counter group: updates live as currentIndex changes

**Interactions:** CLOSE button (X circle, top-left of exam bar): shows confirmation alert "Thoát bài thi?" with "Tiếp tục" (cancel) and "Thoát" (destructive → dismiss screen).

BOOKMARK button (top-right of exam bar): toggles bookmark via progressStore.toggleBookmark; icon swaps between outline and fill; haptic .light.

COUNTER GROUP tap (center of exam bar): optional — can open the Question Jump Overlay as an alternative entry point.

OPTION ROW tap: selects that answer; in mock-exam mode records selection immediately; in simulation mode stores selectedAnswerId; triggers selection haptic. Only one option can be selected at a time.

PREV button ("Câu trước"): navigates to currentIndex - 1 with .easeOut(0.25) animation; disabled at index 0.

CONFIRM/NEXT button:
- Simulation mode, no answer: disabled (button shows reduced opacity, "Xác nhận đáp án")
- Simulation mode, answer selected: confirms answer, reveals correctness, shows tip, changes button to "Câu tiếp"
- Simulation mode, revealed, not last: advances to next question
- Simulation mode, revealed, last: navigates to result screen
- Mock exam mode: changes label to "Câu tiếp" always; on last question becomes "Nộp bài" → triggers submit alert

PROGRESS RING (QuestionGridButton): taps open ExamQuestionGridSheet or ExamQuestionJumpOverlay as a sheet (.presentationDetents [.medium, .large]). Selecting a cell navigates directly to that question index.

QUESTION JUMP OVERLAY dismiss: tap outside sheet area (scrim) or tap close button (X in sheet header) or tap "Tiếp tục làm bài" CTA — all dismiss overlay.

QUESTION JUMP OVERLAY cell tap: navigates directly to tapped question index, closes overlay.

SWIPE navigation: horizontal swipe gesture (trailing = next, leading = prev) with spring animation — standard for exam flow.

Question change animation: .easeOut(duration: 0.25) transition on currentIndex change; ScrollView resets to top via .id(currentIndex).

**Notes:** Primary implementation file: GPLX2026/Features/Exam/BaseExamView.swift. This screen IS BaseExamView in iPhone portrait mode (.else branch inside examContent), with changes needed:

1. NAVIGATION CHROME: The design does NOT use a NavigationBar/toolbar approach. It shows a bespoke ExamTopBar component embedded directly in the VStack above the scroll content. The existing ExamToolbar modifier attaches to NavigationStack toolbars. The rebuild should either: (a) introduce ExamTopBar as a plain View and remove .navigationBarHidden(true) / the examToolbar modifier for this screen, or (b) retain the NavigationBar approach but style it to match the design. Option (a) is the faithful match to the design spec.

2. TIMER CAPSULE STYLE: The design shows the timer capsule as a dark pill (#0F0F12 fill, white text, amber icon) — always dark regardless of urgency, unlike ExamTimerCapsule which goes red on urgency. The ExamTopBar widget should render its own inline timer (not ExamTimerCapsule) or accept a style param.

3. EXAM BAR POSITION: The exam bar sits BETWEEN the status bar and the scroll content — not in safeAreaInset(.top). It is part of the main VStack flow, below the OS status bar.

4. MEMORY TIP vs EXPLANATION: The design shows the amber "MẸO GHI NHỚ" teaser in the pre-confirm state (tip is always visible after question renders). The existing ExplanationBox is shown post-confirm in simulation mode. These are two distinct widgets: MemoryTipTeaser (always visible if question.tip exists) and ExplanationBox (revealed after confirm in simulation mode). Currently BaseExamView only shows ExplanationBox after isRevealed = true. The design implies the tip teaser is always shown — verify with product owner whether this is a learning-mode vs exam-mode distinction.

5. QUESTION JUMP OVERLAY vs ExamQuestionGridSheet: The design's overlay has 4 status states (Đúng/Sai/Đánh dấu/Chưa làm) vs the existing ExamQuestionGridSheet which only tracks answered/unanswered/current. The new ExamQuestionJumpOverlay widget needs a wrongIndices + flaggedIndices parameter. The existing ExamQuestionGridSheet can be preserved for simpler use-cases.

6. FOOTER BUTTON WIDTHS: Prev is fixed 120 pt; Confirm fills remaining space. This is different from ExamBottomBar which distributes widths more evenly. The existing ExamBottomBar should be parameterized or a new layout used.

7. GRADIENT BACKGROUND: The warm gradient background is NOT the standard ScaffoldBackground(). The screen should use a ZStack with a LinearGradient(colors: [...], startPoint: .bottomTrailing, endPoint: .topLeading) filling the safe area, behind the VStack content. The existing AnimatedBackground() is not used here.

8. DIEMLET BADGE: The "Điểm liệt" TagPill uses fill #EF44441F (appError at ~12% opacity) as background and #EF4444 for text — exactly what TagPill(text:"Điểm liệt", color:.appError) produces via the 0.10 opacity formula. Acceptable reuse.

9. QUESTION TEXT SIZE: The design uses fontSize 19 for the question text, which is larger than what QuestionCard typically uses. The question text is rendered INLINE in the content VStack, NOT via QuestionCard wrapper. The question image (if any) would need QuestionImage component rendered between MetaRow and question text.

10. ANSWER OPTIONS: The design uses a custom option row, not AnswerOptionCard. The amber selected state (#FFC233 gold border + gradient fill) is distinct from AnswerOptionCard's appPrimary (#D4714E) selected state. Either extend AnswerOptionCard with a .gold selection style or build inline. Recommend adding a `selectionColor: Color = .appPrimary` parameter to AnswerOptionCard.

11. EXISTING EXAM COMMON WIDGETS: Core/Common/Exam/ already has ExamToolbar, ExamBottomBar, ExamQuestionGridSheet, ExamTimerCapsule, ExamStatsRow, ExamLoadingView — reuse where possible, extend rather than replace.

12. ACCESSIBILITY: All answer options should have accessibilityLabel combining letter + text + state (already implemented in AnswerOptionCard). The timer should have .accessibilityLabel("Thời gian còn lại: \(timerText)").

13. SWIFT CONCURRENCY: Any timer ticks must be dispatched via Task { @MainActor in ... } as per existing pattern. No per-render DateFormatter — precompute timerText as a computed property from remainingSeconds.


## Exam Result  (frame VVIdQ)

**Purpose:** Full-screen post-exam result summary shown immediately after a mock exam completes. Displays pass/fail hero with score, a collapsible "Tổng quan" stat grid (correct count, wrong count, điểm liệt status, elapsed time), a collapsible per-topic breakdown accordion, two primary CTA buttons (review answers, retry exam), and a ghost home link at the bottom.

**Layout:**

SCREEN ROOT (frame VVIdQ)
• Width: 393 pt, corner radius 40, clip = true
• Background: linear gradient top→bottom: #DFF1E6 (0%) → #EBECEF (55%) → #E6E4DF (100%) — maps to the "passed" warm-green-to-neutral scaffold; use a LinearGradient ignoring safe area. When isPassed=false substitute a red-tinted gradient: #F8E6E6 → #EBECEF → #E6E4DF.
• Root VStack: layout = vertical, gap = 16, padding = [top:12, leading:20, bottom:20, trailing:20]

──── 1. STATUS BAR (acmXr) ────
HStack justifyContent: space_between, height 62, horizontal padding 28
  Left: Text "9:41" — appSans 16/600, appTextDark
  Right: HStack gap 7 — signal icon 18×18, wifi icon 18×18, battery-full icon 24×18 (all appTextDark)

──── 2. HEADER META + TITLE (inside Content VStack, zpw9I) ────
Content VStack: layout vertical, gap 16, padding [top:12, leading:20, bottom:20, trailing:20], width fill

  2a. Meta row (LCuY4):
  HStack justifyContent: center, gap 8, width fill
    • Text "22 thg 11" — appSans 11.5/600, color #7A7166 (maps to appTextMedium tinted warm)
    • Ellipse 3×3 fill #00000026
    • Text "14:20" — same style
    • Ellipse 3×3
    • Text "Đề số 04" — same style
  All three text items are dynamic data (date, time, exam set number).

  2b. Title text (l7czOV):
  Text "Kết quả thi thử" — appSans 22/800, appTextDark, letterSpacing -0.5, NO navigation bar — title is rendered inline in content scroll.

──── 3. RESULT HERO CARD (mf33p → ref Bs1tH) ────
Reuse: ResultHero(isPassed:, score:, total:, subtitle:)
Corner radius: 22 (override the component's default 20 → pass cornerRadius:22 to .glassCard on the hero)
Background fill in design: #E7F5EC (the existing appSuccess tint wash). Map: .glassCard(cornerRadius:22, tint:.appSuccess) for passed state; .glassCard(cornerRadius:22, tint:.appError) for failed.

ResultHero internal layout (component/ResultHero Bs1tH — redesigned vs current code):
  The DESIGN uses a HORIZONTAL two-column layout (not the circular ring in current code):
  HStack justifyContent: space_between, width fill
    Left column (yND7L) VStack gap 8:
      • Badge capsule: HStack cornerRadius 100, fill #22C55E, padding [5,12,5,10], gap 5
          – check icon 14×14 white
          – Text "ĐẠT" appSans 12/800 white letterSpacing 1
        (Failed variant: fill appError, text "TRƯỢT")
      • Heading VStack gap 2:
          – Text "Chúc mừng!" appSans 24/800 appTextDark letterSpacing -0.5
          – Text "Bạn đã vượt qua bài thi thử" appSans 12.5/500 color #5E7A66 (success-muted green)
        (Failed variant heading: "Cố lên!" / "Hãy ôn tập thêm và thử lại nhé")
    Right column (QTOV2) VStack alignItems end:
      • Text "91%" appSans 48/700 color #1E9E50 lineHeight 1 (maps to a darker appSuccess shade; use appSuccess for token)
      • Text "32/35 câu đúng" appSans 12/500 appTextMedium
  Card container: cornerRadius 22, fill #E7F5EC, padding 16, gap 14, layout vertical (wrapping the Top HStack)

  NOTE: The existing ResultHero Swift code uses a circular ring layout. This design uses the horizontal card layout described above. The ResultHero component needs to be updated or a variant added. See "newWidgets" for the proposed ResultHeroCard replacement.

──── 4. STATS CARD — "Tổng quan" (Op58q) ────
Glass card: cornerRadius 22, fill #FFFFFF80 (80% white), background blur radius 20, stroke #FFFFFFB3 1pt, padding 14, VStack gap 12, width fill.
Map to: .glassCard(cornerRadius:22) with a custom frosted overlay (see notes on glass treatment).

  4a. Header row (z9r6G): HStack justifyContent: space_between, width fill
    • Text "Tổng quan" appSans 14/800 appTextDark letterSpacing -0.2
    • chevron-up icon 20×20 color #7A7166 (appTextMedium warm) — indicates section is EXPANDED

  4b. Body VStack (aSE5L): layout vertical, gap 10, width fill
    Four stat rows, each: HStack alignItems center, cornerRadius 10, fill #FFFFFF66, blur 18, stroke #FFFFFFA6 1pt, padding [12,14], gap 12, width fill.
    Each row = [IconBox 32×32] [Label fill] [Value]

    Row 1 — Câu đúng (o4jD5h):
      IconBox: cornerRadius 10, fill #E7F5EC, 32×32, icon circle-check lucide 18×18 fill #1F7A3D
      Label: "Câu đúng" appSans 13.5/600 appTextDark, textGrowth fixed-width, fill_container
      Value: "32" appSans 18/700 appTextDark

    Row 2 — Câu sai (Ue2yj):
      IconBox: cornerRadius 10, fill #FCE4E2, 32×32, icon circle-x lucide 18×18 fill #B3261E
      Label: "Câu sai" appSans 13.5/600 appTextDark, fill_container
      Value: "3" appSans 18/700 appTextDark

    Row 3 — Điểm liệt (YJ845):
      IconBox: cornerRadius 10, fill #E7F5EC, 32×32, icon shield-check lucide 18×18 fill #1F7A3D (passed) / fill #FCE4E2 icon color #B3261E (failed)
      Label: "Điểm liệt" appSans 13.5/600 appTextDark, fill_container
      Value: "Đạt" appSans 18/700 color #1F5A2A (dark green — use Color(hex:0x1F5A2A) as no token) / "Không đạt" appError (failed)

    Row 4 — Thời gian (qqEll):
      IconBox: cornerRadius 10, fill #F0EEE9 (statsBg), 32×32, icon timer lucide 18×18 fill #6B6B6B
      Label: "Thời gian" appSans 13.5/600 appTextDark, fill_container
      Value: "14:20" appSans 18/700 appTextDark (format MM:SS)

──── 5. TOPIC BREAKDOWN CARD — "Theo chủ đề" (V3qj4J) ────
Same glass card shell as #4: cornerRadius 22, fill #FFFFFF80, blur 20, stroke #FFFFFFB3 1pt, padding 14, VStack gap 12, width fill.

  5a. Header row (kvNbf): HStack justifyContent: space_between, width fill
    • Text "Theo chủ đề" appSans 14/800 appTextDark letterSpacing -0.2
    • chevron-down icon 20×20 color #7A7166 — indicates section is COLLAPSED (body hidden by default)

  5b. Body VStack (CQHBJ): layout vertical, gap 10, width fill — HIDDEN when collapsed (enabled:false in design)
    Four topic rows, each: HStack alignItems center, cornerRadius 10, fill #FFFFFF66, blur 18, stroke #FFFFFFA6 1pt, padding [12,14], gap 12, width fill.
    Each row = [IconBox 30×30] [Mid VStack fill] [Score]

    Row 1 — Khái niệm & quy tắc (ZxRFb): ✅ excellent
      IconBox: cornerRadius 10, fill #D9F0DA, 30×30, icon check-check lucide 16×16 fill #1F5A2A
      Mid VStack gap 1: label "Khái niệm & quy tắc" appSans 13/700 #0F0F12; status "Vững vàng" appSans 10.5/600 #1F5A2A
      Score: "9/9" appSans 16/700 #1F5A2A

    Row 2 — Văn hoá & đạo đức (BuSUA): ✅ good
      IconBox: cornerRadius 10, fill #D9F0DA, 30×30, icon check lucide 16×16 fill #1F5A2A
      Mid VStack gap 1: label "Văn hoá & đạo đức" appSans 13/700 #0F0F12; status "Tốt" appSans 10.5/600 #1F5A2A
      Score: "7/8" appSans 16/700 #1F5A2A

    Row 3 — Kỹ thuật lái xe (YulwV): ⚠️ fair
      IconBox: cornerRadius 10, fill #FFE9B0, 30×30, icon trending-up lucide 16×16 fill #7A4A00
      Mid VStack gap 1: label "Kỹ thuật lái xe" appSans 13/700 #0F0F12; status "Khá — nên ôn thêm" appSans 10.5/600 #7A4A00
      Score: "5/7" appSans 16/700 #7A4A00

    Row 4 — Biển báo & xử lý (N3aRC): ❌ poor
      IconBox: cornerRadius 10, fill #FFD7CF, 30×30, icon triangle-alert lucide 16×16 fill #8A2A1F
      Mid VStack gap 1: label "Biển báo & xử lý" appSans 13/700 #0F0F12; status "Cần ôn ngay" appSans 10.5/600 #8A2A1F
      Score: "3/6" appSans 16/700 #8A2A1F

  Topic status thresholds (compute from per-topic correct/total):
    100%: icon check-check, fill #D9F0DA, color #1F5A2A, label "Vững vàng"
    ≥80%: icon check, fill #D9F0DA, color #1F5A2A, label "Tốt"
    ≥60%: icon trending-up, fill #FFE9B0, color #7A4A00, label "Khá — nên ôn thêm"
    <60%: icon triangle-alert, fill #FFD7CF, color #8A2A1F, label "Cần ôn ngay"

──── 6. ACTION BUTTONS (U0ipqi) ────
VStack gap 12, padding [top:6, leading:0, bottom:0, trailing:0], width fill

  Button 1 — "Xem lại bài" (sNuBS): secondary/outline style
    HStack justifyContent center, gap 6, cornerRadius 25, height 50, width fill
    stroke #D4714E (appPrimary) strokeWidth 1.5, NO fill background
    • circle-check-big icon 16×16 fill appPrimary
    • Text "Xem lại bài" appSans 15/700 appPrimary

  Button 2 — "Thi lại" (oq8Ms): primary filled style
    HStack justifyContent center, gap 6, cornerRadius 25, fill appPrimary, height 50, width fill
    • circle-play icon 16×16 fill white
    • Text "Thi lại" appSans 15/700 white

  Reuse: AppButton(icon:, label:, style:.primary/.secondary, height:50) for both buttons.

──── 7. GHOST HOME LINK (NoelD) ────
HStack justifyContent center, gap 6, height 44, width fill, NO background/border
  • house icon 16×16 fill #7A7166 (appTextMedium warm)
  • Text "Về trang chủ" appSans 14/600 color #7A7166

END ROOT


**Tokens:** Background gradient (passed): #DFF1E6 → #EBECEF → #E6E4DF (no token; use literal hex in LinearGradient)
Background gradient (failed): #F8E6E6 → #EBECEF → #E6E4DF (no token; use literal hex)
appPrimary: #D4714E (terracotta) — button fill, button stroke, button icon+label
appTextDark: #171717 — screen title, stat labels, stat values
appTextMedium (#737373): exam meta line, chevron icons, ghost home text
Warm muted text #7A7166: meta dots, chevron icons (no token; use Color(hex:0x7A7166))
appSuccess: #22C55E — badge fill (ĐẠT), score ring
appError: #EF4444 — badge fill (TRƯỢT), wrong icon color
Hero score percentage color: #1E9E50 (dark success — no token; use Color(hex:0x1E9E50) or .appSuccess.opacity variant)
Hero subtitle color (passed): #5E7A66 (muted green — no token; use Color(hex:0x5E7A66))
Deep green text: #1F5A2A — điểm liệt "Đạt", topic scores (no token; Color(hex:0x1F5A2A))
Darkest label text: #0F0F12 — topic row names (slightly deeper than appTextDark; Color(hex:0x0F0F12))
Glass card bg: #FFFFFF80 (50% white) — Tổng quan / Theo chủ đề card shells
Stat row bg: #FFFFFF66 (40% white) — individual stat rows inside cards
Stat row stroke: #FFFFFFA6 (65% white)
IconBox fills:
  Correct/good: #E7F5EC (appSuccess 12% wash), #D9F0DA (darker green wash)
  Error: #FCE4E2, #FFD7CF
  Warning: #FFE9B0
  Neutral: #F0EEE9 (statsBg)
Icon colors:
  Correct: #1F7A3D, #1F5A2A
  Error: #B3261E, #8A2A1F
  Warning: #7A4A00
  Neutral: #6B6B6B
ResultHero card bg (passed): #E7F5EC → .glassCard(cornerRadius:22, tint:.appSuccess)
ResultHero card bg (failed): → .glassCard(cornerRadius:22, tint:.appError)
Fonts: .appSans only — all sizes mapped above. Screen uses no serif/mono.
Spacing tokens: gap 16 (main VStack), gap 12 (action buttons), gap 10 (stat body), gap 8 (meta row), gap 6 (button label+icon)
Corner radii: screen 40, cards 22, stat rows 10, icon boxes 10, badge 100, action buttons 25

**Reuse widgets:** ResultHero(isPassed:score:total:subtitle:) — reuse but needs layout variant (horizontal card, not ring — see newWidgets), AppButton(icon:label:style:height:) — for 'Xem lại bài' (.secondary) and 'Thi lại' (.primary), ScaffoldBackground() — NOT used directly; screen has its own gradient bg (passed/failed tinted linear gradient), AnimatedBackground() — applied as normal via .screenHeaderStyle, .glassCard(cornerRadius:tint:) — applied to ResultHero card with tint (.appSuccess or .appError), StatusBadge(text:color:fontSize:) — could back the ĐẠT/TRƯỢT badge if extracted, but design builds it inline as HStack in the hero card

**New widgets:**
- ResultHeroCard(isPassed: Bool, percentage: Int, score: Int, total: Int, examTitle: String, subtitle: String) — horizontal two-column card replacing the ring-based ResultHero for this screen: left col = status badge + heading VStack, right col = percentage + fraction label; cornerRadius 22; tinted glass card bg; API should accept an optional cornerRadius override. Existing ResultHero (ring design) is kept for ExamHistoryDetailView.
- ExamStatRow(iconName: String, iconColor: Color, iconBoxFill: Color, label: String, value: String, valueColor: Color) — single horizontal stat row: 32×32 icon box (cornerRadius 10) + fill label + right-aligned value; frosted bg #FFFFFF66 blur 18; padding [12,14]; cornerRadius 10. Used in Tổng quan and can be reused in history detail.
- TopicBreakdownRow(topicName: String, correct: Int, total: Int) — topic performance row: 30×30 icon box (status-colored), mid VStack (topic name appSans 13/700 + status label appSans 10.5/600), right score appSans 16/700; status and colors computed from correct/total ratio via a TopicPerformanceLevel enum (excellent ≥100%, good ≥80%, fair ≥60%, poor <60%); frosted bg same as ExamStatRow.
- CollapsibleSectionCard(title: String, isExpanded: Binding<Bool>, content: () -> some View) — white-frosted glass card shell (cornerRadius 22, fill #FFFFFF80, blur 20, stroke #FFFFFFB3) with a header HStack (title + chevron toggling isExpanded) and collapsible body VStack with .animation(.spring()); wraps ExamStatRow list or TopicBreakdownRow list.
- ExamMetaLine(dateString: String, timeString: String, examSetLabel: String) — centered HStack with three text segments separated by 3×3 filled ellipses (#00000026); appSans 11.5/600 color #7A7166; not a card — plain inline view.

**Copy:**
- Kết quả thi thử
- 22 thg 11
- 14:20
- Đề số 04
- ĐẠT
- TRƯỢT
- Chúc mừng!
- Bạn đã vượt qua bài thi thử
- Cố lên!
- Hãy ôn tập thêm và thử lại nhé
- 91%
- 32/35 câu đúng
- Tổng quan
- Câu đúng
- Câu sai
- Điểm liệt
- Thời gian
- Đạt
- Không đạt
- Theo chủ đề
- Khái niệm & quy tắc
- Vững vàng
- Văn hoá & đạo đức
- Tốt
- Kỹ thuật lái xe
- Khá — nên ôn thêm
- Biển báo & xử lý
- Cần ôn ngay
- Xem lại bài
- Thi lại
- Về trang chủ

**States:** passed state: gradient bg green-tinted (#DFF1E6→#EBECEF→#E6E4DF), hero card tint appSuccess, badge "ĐẠT" fill #22C55E, heading "Chúc mừng!", điểm liệt row shows "Đạt" in #1F5A2A with shield-check icon in green box.
failed state: gradient bg red-tinted (#F8E6E6→#EBECEF→#E6E4DF), hero card tint appError, badge "TRƯỢT" fill appError, heading "Cố lên!", subtitle "Hãy ôn tập thêm và thử lại nhé", điểm liệt row shows "Không đạt" in appError with circle-x icon in red box.
Tổng quan expanded (default): chevron-up, body rows visible with animation.
Tổng quan collapsed: chevron-down, body hidden; tap header toggles.
Theo chủ đề collapsed (default): chevron-down, body hidden. Tap header expands, chevron flips to up.
Theo chủ đề expanded: body rows animate in with .spring() transition.
Topic rows: each topic independently shows excellent/good/fair/poor state based on computed ratio (icon, box fill, label, value color all change).
isFromHistory = true: hides "Thi lại" and "Xem lại bài" action buttons and home ghost link, screen title changes to "Chi tiết bài thi" (matches existing ExamResultView logic).
Loading/empty: not applicable — data arrives synchronously from completed exam session.

**Interactions:** Tap "Thi lại" button: calls openExam(.mockExam(examSetId: examResult.examSetId)) — restarts the same exam set.
Tap "Xem lại bài" button: navigates to question review (push ExamResultReviewView or triggers openExam(.questionView) over wrong answers); maps to existing ExamResultView scrolling answer section — consider NavigationLink push to a dedicated review screen.
Tap "Về trang chủ" ghost link: calls popToRoot() — dismisses back to the main tab root.
Tap "Tổng quan" section header: toggles isOverviewExpanded Bool with .spring(response:0.35, dampingFraction:0.8) animation; chevron rotates 180°.
Tap "Theo chủ đề" section header: toggles isTopicExpanded Bool with same spring animation.
Swipe back: system interactive pop gesture (UINavigationController hook already in AppTheme); available when isFromHistory=true (back button shown); for fresh result (hideBackButton:true) swipe is blocked per existing behavior.
No tab bar shown on this screen — it is a pushed navigation destination within the exam flow, not a tab root.

**Notes:** Most likely existing file: /Users/maitrungkien/Desktop/project/GPLX2026/GPLX2026/Features/Exam/ExamResultView.swift — this is the direct rebuild target.

Key divergence from current code: The current ExamResultView uses a circular ProgressRing-based ResultHero and a plain ScoreRow list wrapped in .glassCard(). The design replaces this with: (1) a horizontal ResultHeroCard, (2) frosted glass CollapsibleSectionCard shells for both Tổng quan and Theo chủ đề, and (3) redesigned stat rows with icon boxes. The existing ResultHero (ring) should be preserved as-is for ExamHistoryDetailView.

Glass treatment note: The stat-card shells (#FFFFFF80 + blur 20) and inner rows (#FFFFFF66 + blur 18) appear to use system background blur (UIBlurEffect). In SwiftUI use .background(.ultraThinMaterial) or .background(.regularMaterial) clipped to RoundedRectangle(cornerRadius:) rather than a literal Color fill, to achieve the frosted look. The .glassCard() modifier is FLAT (no blur) — do NOT use it for these frosted shells; build them with .background(.ultraThinMaterial).

The screen background is NOT ScaffoldBackground — it is a bespoke three-stop linear gradient tied to pass/fail state. The gradient should be applied as a ZStack background ignoring safe area, replacing the normal .screenHeaderStyle background injection.

The status bar area (acmXr height 62) is a design decoration; in production SwiftUI the real system status bar renders on top — do not re-implement it. The content scroll starts below the system safe area inset.

Topic data: the "Theo chủ đề" breakdown requires per-topic correct/total counts. The model ExamResult may need a topicBreakdown: [String: (correct: Int, total: Int)] property if not already present. Check GPLX2026/Core/Models/ExamResult.swift before implementing.

The screen title "Kết quả thi thử" is rendered INLINE in the scroll content (not as a navigation large title), preceded by the meta line. Use .screenHeader with titleDisplayMode:.inline and a custom inline title rendered in the content VStack — consistent with the design's embedded title pattern.

Lucide icons referenced: circle-check, circle-x, shield-check, timer, check-check, check, trending-up, triangle-alert, circle-check-big, circle-play, house. Map to SF Symbols or a Lucide icon font that is already used in the project (the design uses library:"lucide" — verify icon mapping in GPLX2026/Core/Theme or the existing icon usage patterns).


## Answer Review  (frame dX3Sb)

**Purpose:** Post-exam answer review screen that lets the user page through each question one at a time, see which answer they chose, which answer is correct, and read the explanation. A filter segment bar at the top lets them jump between "all questions", "wrong answers", and "critical-failure (điểm liệt) questions".

**Layout:**
Frame: 393 x 852 pt, cornerRadius 40, clip true.
Background: linear gradient, 205-degree rotation, #FBF8F0 at 0% → #EEECE6 at 55% → #DAD3C4 at 100% (no token; closest semantic is scaffoldBg but this is a custom warm cream gradient — use a private LinearGradient).

The frame uses a VStack (layout: vertical) with gap 14 between the four top-level children:

────────────────────────────────────────────────
1. STATUS BAR  (id: Lhq2u)
   HStack, fill_container width, height 62, padding [top 0, leading 28, bottom 0, trailing 28], justifyContent: space_between.
   • Left: Text "9:41", fontFamily Be Vietnam Pro 16/600, fill #171717 (appTextDark).
   • Right: HStack gap 7 — signal icon 18×18 #171717, wifi icon 18×18 #171717, battery-full icon 24×18 #171717.
   (Use system status bar overlay in production; this is just the mock chrome.)

────────────────────────────────────────────────
2. NAV BAR  (id: p4HfI)
   HStack, fill_container, padding [top 0, leading 20, bottom 8, trailing 20], justifyContent: space_between, alignItems: center.
   • Left — Back button (id: y1ejy): frosted capsule 38×38, fill #FFFFFF CC (semi-transparent white), cornerRadius 100, stroke #00000014 1pt. Contains chevron-left icon 20×20 #0F0F12.
   • Center — Title text (id: dw5li): "Xem lại", Be Vietnam Pro 17/800 (ExtraBold), fill #0F0F12.
   • Right — Counter pill (id: zpRSM): fill #FFFFFFCC, cornerRadius 100, padding [top 6, leading 12, bottom 6, trailing 12], stroke #00000014 1pt. Contains text "Câu 3/35", Be Vietnam Pro 12/700, fill #0F0F12.

────────────────────────────────────────────────
3. CONTENT AREA  (id: TOFlb)
   VStack (layout: vertical), fill_container width, fill_container height, gap 14, padding [top 0, leading 20, bottom 20, trailing 20].

   3a. SEGMENT BAR  (id: LKoQE)
       HStack, fill_container width, gap 8. Three filter chips side-by-side (left-aligned, NOT equal-width — each is hug-width):

       Chip 1 — "Tất cả"  (id: Gziff) — INACTIVE state:
         Fill #FFFFFFCC, cornerRadius 100, padding [top 7, leading 14, bottom 7, trailing 14], stroke #00000014 1pt.
         Inner text "Tất cả", Be Vietnam Pro 12.5/700, fill #7A7166 (appTextMedium-ish).

       Chip 2 — "Câu sai"  (id: atx89) — ACTIVE (selected) state:
         Fill #0F0F12 (near-black = active indicator color), cornerRadius 100, padding [top 7, leading 14, bottom 7, trailing 14], NO visible stroke.
         Inner text "Câu sai", Be Vietnam Pro 12.5/700, fill #FFFFFF.

       Chip 3 — "Điểm liệt"  (id: rHJt5) — INACTIVE state:
         Fill #FFFFFFCC, cornerRadius 100, padding [top 7, leading 14, bottom 7, trailing 14], stroke #00000014 1pt.
         Inner text "Điểm liệt", Be Vietnam Pro 12.5/700, fill #7A7166.

   3b. QUESTION CARD  (id: jpds9)
       VStack (layout: vertical), fill_container width, cornerRadius 20, fill #FFFFFFCC (frosted white), padding 8 uniform, gap 12, stroke #00000014 1pt.

       3b-i. QUESTION HEADER  (id: prqGf)
             VStack, fill_container width, layout vertical, gap 10, padding [top 8, leading 8, bottom 0, trailing 8].

             Row 1 — Tags row  (id: rJQXQ):
               HStack, gap 6.
               Tag A (id: Cwpkk): cornerRadius 100, fill #0F0F1210 (very light dark), padding [top 4, leading 10, bottom 4, trailing 10].
                 Inner text "Câu 3", Be Vietnam Pro 11/700, fill #0F0F12 (appTextDark).
               Tag B (id: SfCnC): cornerRadius 100, fill #FFD7CF (light coral), padding [top 4, leading 10, bottom 4, trailing 10].
                 Inner text "Điểm liệt", Be Vietnam Pro 11/700, fill #8A2A1F (dark red).

             Row 2 — Question text  (id: d2Q2Br):
               Text "Khi gặp biển báo cấm, người lái xe phải xử lý như thế nào?"
               Be Vietnam Pro 18/700, fill #0F0F12, lineHeight 1.3, fill_container width, textGrowth fixed-width, multiline.

       3b-ii. ANSWER OPTIONS  (id: L9jDe)
              VStack, layout vertical, fill_container width, gap 8.
              Four option rows (A, B, C, D). Each is an HStack, fill_container width, alignItems center, cornerRadius 12, padding 8 uniform, gap 10.

              Option A  (id: K5bAen) — NEUTRAL (not selected, not correct):
                Fill #FAF9F7 (cardBg).
                Badge (id: aemgt): 26×26, cornerRadius 4, fill #FFFFFFAA (semi-transparent white), center-aligned.
                  Inner text "A", Be Vietnam Pro 13/800, fill #0F0F12.
                Answer text "Dừng lại hẳn rồi quay đầu xe", Be Vietnam Pro 13/500, fill #0F0F12, lineHeight 1.25, fill_container width.

              Option B  (id: JA3Rz) — WRONG SELECTION (user chose this, it is wrong):
                Fill #FFD7CF (light coral error tint).
                Badge (id: N2dKW): 26×26, cornerRadius 4, fill #FFFFFFAA.
                  Inner text "B", Be Vietnam Pro 13/800, fill #8A2A1F (dark red).
                Answer text "Tiếp tục đi với tốc độ chậm", Be Vietnam Pro 13/700 (bold = emphasis for selected wrong), fill #8A2A1F.

              Option C  (id: U76wmg) — CORRECT ANSWER:
                Fill #D9F0DA (light green success tint).
                Badge (id: xKW2D): 26×26, cornerRadius 4, fill #FFFFFFAA.
                  Inner text "C", Be Vietnam Pro 13/800, fill #1F5A2A (dark green).
                Answer text "Không được đi vào khu vực có biển báo cấm", Be Vietnam Pro 13/700, fill #1F5A2A.

              Option D  (id: Ozmry) — NEUTRAL:
                Fill #FAF9F7 (cardBg).
                Badge (id: kqnCx): 26×26, cornerRadius 4, fill #FFFFFFAA.
                  Inner text "D", Be Vietnam Pro 13/800, fill #0F0F12.
                Answer text "Giảm tốc độ và bấm còi báo hiệu", Be Vietnam Pro 13/500, fill #0F0F12, lineHeight 1.25, fill_container width.

   3c. EXPLANATION BOX  (id: clYnu)
       HStack, fill_container width, cornerRadius 18, fill #FFE9B0 (warm amber/golden), padding 8 uniform, gap 10.

       Left — Icon box  (id: VGAZW): 36×36, cornerRadius 10, fill #FFFFFFB3, center-aligned.
         lightbulb icon 18×18, fill #7A4A00 (dark amber).

       Right — Text block  (id: FxNWu): VStack, fill_container width, layout vertical, gap 2.
         Label text "Giải thích", Be Vietnam Pro 12/800, fill #7A4A00, letterSpacing 0.2.
         Body text "Biển báo cấm yêu cầu người lái xe tuyệt đối không đi vào khu vực hoặc thực hiện hành vi bị cấm. Đây là nhóm câu điểm liệt — sai là trượt.", Be Vietnam Pro 12/500, fill #5C3700, lineHeight 1.35, fill_container width, multiline.

   3d. SPACER  (id: H1dgk): fill_container width and height (flex grows to push actions to bottom).

   3e. ACTIONS BAR  (id: Bn7bO)
       HStack, fill_container width, gap 10.

       Left — Prev button (id: c0RxvP): fixed width 120, height 50, cornerRadius 25, fill #FFFFFFCC (frosted), stroke #0F0F1233 1.5pt. Centered HStack gap 6:
         chevron-left icon 16×16 #0F0F12.
         Text "Câu trước", Be Vietnam Pro 15/700, fill #0F0F12.

       Right — Next button (id: iFT0V): fill_container width, height 50, cornerRadius 25, fill #D4714E (appPrimary). Centered HStack gap 6:
         Text "Câu tiếp theo", Be Vietnam Pro 15/700, fill #FFFFFF.
         chevron-right icon 16×16 #FFFFFF.

────────────────────────────────────────────────
TOTAL STRUCTURAL HIERARCHY (top to bottom, inside the frame):
  Status Bar
  Nav Bar (Back | "Xem lại" | Counter pill)
  Content VStack:
    Segment bar (Tất cả | Câu sai | Điểm liệt)
    Question Card:
      Question Header (Tags row + Question text)
      Options list (A neutral / B wrong-selected / C correct / D neutral)
    Explanation Box (amber, icon + label + body)
    Spacer (flex)
    Actions (Câu trước | Câu tiếp theo)

**Tokens:** Background gradient: linear 205°, #FBF8F0 → #EEECE6 → #DAD3C4 (no single token; define as private let reviewBg). 
Question card fill: #FFFFFFCC → Color.white.opacity(0.8) (frosted; nearest .glassCard tint but card is explicitly semi-transparent; use RoundedRectangle fill directly, not .glassCard).
Nav back/counter pill fill: #FFFFFFCC (same frosted white as question card).
Segment inactive fill: #FFFFFFCC.
Segment active fill: #0F0F12 → Color(hex:"#0F0F12"), approximately appTextDark.
Option neutral fill: #FAF9F7 → Color.cardBg.
Option wrong-selected fill: #FFD7CF → Color.appError.opacity(0.18) approx (no direct token; literal #FFD7CF).
Option correct fill: #D9F0DA → Color.appSuccess.opacity(0.18) approx (no direct token; literal #D9F0DA).
Explanation box fill: #FFE9B0 → Color.appWarning.opacity(0.35) approx (no direct token; literal #FFE9B0).
Explanation icon fill: #7A4A00 (dark amber; no token).
Explanation text fill: #5C3700 (darker amber; no token).
Explanation label fill: #7A4A00.
Tag "Câu N" fill: #0F0F1210 → appTextDark.opacity(0.063).
Tag "Điểm liệt" fill: #FFD7CF (same as wrong option tint).
Tag "Điểm liệt" text: #8A2A1F → appError darkened (no token; literal).
Wrong-option text: #8A2A1F.
Correct-option text: #1F5A2A → appSuccess darkened (no token; literal).
Badge letter background: #FFFFFFAA → Color.white.opacity(0.67).
Fonts: .appSans(size:weight:) throughout. Sizes: 17/ExtraBold (nav title), 15/Bold (buttons), 13/Medium or Bold (option text), 12.5/Bold (segment chips), 12/ExtraBold (explanation label), 12/Medium (explanation body, tag text), 11/Bold (question number tag), 18/Bold (question text).
Spacing tokens: 14 (main VStack gap), 12 (question card gap), 10 (explanation HStack gap, actions HStack gap), 8 (options gap, segment gap), 6 (nav HStack gap for back button icon+chevron, next button label+icon).
Corner radii: 40 (screen), 25 (action buttons), 20 (question card), 18 (explanation box), 12 (option rows), 10 (explanation icon box), 100 (nav pills, segment chips, tags), 4 (letter badges).

**Reuse widgets:** ExplanationBox — reuse for the amber explanation section (matches the design's structure: lightbulb icon + 'Giải thích' label + body text); the existing component uses .glassCard wrapper, but in this screen the box has its own distinct #FFE9B0 fill — pass the content and override background by wrapping in a custom container, OR accept the ExplanationBox visual if it is close enough after theming., TagPill — for the 'Câu N' and 'Điểm liệt' tags inside the question header (cornerRadius 100, text 11pt, tinted fill)., FilterChip — for the three segment filter chips (Tất cả / Câu sai / Điểm liệt); the existing FilterChip uses appPrimary for selected state — the design uses #0F0F12 (near-black). Either pass a custom color parameter or build a local ReviewSegmentChip; see notes., AppButton — for the 'Câu tiếp theo' (primary/fill) and 'Câu trước' (secondary/ghost) bottom actions if their heights/radii match (design uses height 50, cornerRadius 25 — verify AppButton height param accepts 50)., ScaffoldBackground — if it provides the warm cream gradient; otherwise define inline LinearGradient.

**New widgets:**
- ReviewAnswerOptionRow — HStack(spacing:10), params: letter:String, text:String, state:ReviewOptionState (enum: .neutral, .wrongSelected, .correct). Fills: neutral→#FAF9F7, wrongSelected→#FFD7CF, correct→#D9F0DA. Letter badge: 26×26 RoundedRectangle(cornerRadius:4) fill #FFFFFFAA; text color follows state: neutral→appTextDark, wrongSelected→#8A2A1F, correct→#1F5A2A. Answer text: .appSans(size:13, weight: state==neutral ? .medium : .bold), color matches state. Padding 8, cornerRadius 12, fill_container width.
- ReviewSegmentBar — HStack(spacing:8), left-aligned. Params: selection:Binding<ReviewFilter> (enum: .all, .wrong, .critical). Each chip: frosted white pill when inactive, #0F0F12 fill + white text when active. Font .appSans(size:12.5, weight:.bold). Padding [7,14]. CornerRadius 100. Stroke #00000014 1pt when inactive.
- AnswerReviewView — top-level screen view. Params: questions:[Question], answers:[Int:Int] (questionIndex→selectedAnswerId). State: @State currentIndex:Int, @State filter:ReviewFilter. Computed: filteredIndices:[Int] derived from filter applied to questions+answers array. Displays StatusBar chrome, NavBar (back action + title 'Xem lại' + counter 'Câu N/Total'), ReviewSegmentBar, ReviewQuestionCard (question+options+explanation), spacer, bottom Actions row. Navigation: previous/next buttons step through filteredIndices; back button dismisses.

**Copy:**
- Xem lại
- Câu 3/35
- Tất cả
- Câu sai
- Điểm liệt
- Câu 3
- Khi gặp biển báo cấm, người lái xe phải xử lý như thế nào?
- A
- Dừng lại hẳn rồi quay đầu xe
- B
- Tiếp tục đi với tốc độ chậm
- C
- Không được đi vào khu vực có biển báo cấm
- D
- Giảm tốc độ và bấm còi báo hiệu
- Giải thích
- Biển báo cấm yêu cầu người lái xe tuyệt đối không đi vào khu vực hoặc thực hiện hành vi bị cấm. Đây là nhóm câu điểm liệt — sai là trượt.
- Câu trước
- Câu tiếp theo

**States:** populated (default — question + answers + explanation visible):
  - Option states: neutral (not selected, not correct), wrongSelected (user picked it but it is wrong), correct (right answer). These three can co-exist: user-wrong selection shows wrongSelected tint, correct answer always shows correct tint, remaining options are neutral.
  - Explanation always visible in this screen (always-on after result).
  - Segment bar: exactly one chip active at a time; default shown is "Câu sai" active (as designed).

empty (no questions match the filter):
  - When filter=.wrong and user got everything right, or filter=.critical and no điểm liệt questions exist: show EmptyState widget ("Không có câu nào" message) in place of the question card + explanation.

first question (prev button disabled):
  - "Câu trước" button: visually dimmed (opacity 0.4) and non-interactive when currentIndex == first in filteredIndices.

last question (next button label changes):
  - On last question of the filtered list, "Câu tiếp theo" changes to "Hoàn thành" (or dismiss action).

loading:
  - Not applicable; questions are already in memory from exam result. No async fetch needed.

**Interactions:** Back button (id: y1ejy): dismiss/pop the navigation stack back to ExamResultView or ExamHistoryDetailView.

Segment chips (Tất cả / Câu sai / Điểm liệt): tap any chip → update ReviewFilter selection → recompute filteredIndices → reset currentIndex to 0 (or first in filtered list). Active chip animates fill from #FFFFFFCC to #0F0F12 with .animation(.spring).

"Câu trước" prev button (id: c0RxvP): tap → decrement currentIndex within filteredIndices. Disabled and dimmed at index 0.

"Câu tiếp theo" next button (id: iFT0V): tap → increment currentIndex within filteredIndices. On last question, either dismiss or become "Hoàn thành" and pop.

Counter pill (id: zpRSM): read-only display "Câu N/Total", updates as currentIndex changes. The N displayed is the human-readable question number (position in the full question list, not filtered position).

Question card: no tap interaction — all answer options are read-only (review mode, not interactive selection). No option selection gesture.

Navigation gesture: horizontal swipe (TabView paging or manual DragGesture) can be added as an enhancement to step between questions — not shown in design but natural for this card-paging paradigm.

**Notes:** Most likely existing file: GPLX2026/Features/Exam/ExamResultView.swift already contains a "Xem lại đáp án" section via QuestionReviewRow/AdaptiveGrid layout (list-style overview), but that is a grid summary — NOT this one-at-a-time paged review. This design is a NEW dedicated paged review screen that should live at GPLX2026/Features/Exam/AnswerReviewView.swift (or ExamAnswerReviewView.swift). It is navigated to from ExamResultView when the user taps "Xem lại đáp án" or a specific QuestionReviewRow.

FilterChip fidelity: the existing FilterChip in Core/Common uses appPrimary (terracotta) for selected fill. The design uses #0F0F12 (near-black) for the active chip. Create ReviewSegmentBar as a new widget with the correct active-fill color rather than patching FilterChip.

ExplanationBox fidelity: the existing ExplanationBox applies .glassCard(interactive:false), giving it a neutral card background. In this design the explanation box uses a warm amber #FFE9B0 fill. Build the explanation section inline inside ReviewQuestionCard with its own amber background, or add a custom background color parameter to ExplanationBox.

AnswerOptionCard vs ReviewAnswerOptionRow: AnswerOptionCard (isConfirmed: true) already supports the three visual states (neutral/wrong/correct) but its sizing, badge style (36–44pt, cornerRadius 8), and card wrapping (.glassCard()) differ from the design (26pt badge, cornerRadius 4, flat fills without .glassCard). Build ReviewAnswerOptionRow as a new widget matching the design exactly rather than stretching AnswerOptionCard.

The screen frame has cornerRadius 40 on the outer container — in SwiftUI this is set on the root ZStack/ScrollView with .clipShape and should only apply if the screen is presented as a sheet/modal. If pushed in a NavigationStack, omit the corner clip.

The spacer (id: H1dgk, fill_container height) must be implemented as Spacer() inside a VStack so the Actions row is pinned to the bottom of the screen regardless of content height. Use a ScrollView only for the question card + explanation area, with the actions pinned via .safeAreaInset(edge:.bottom) or a fixed-bottom VStack outside the scroll.

Be Vietnam Pro maps to .appSans (the project's sans-serif); never use Font.custom("Be Vietnam Pro", …) directly — always use .appSans(size:weight:).


## Settings  (frame SVK1N)

**Purpose:** The Settings screen lets users personalise their study session: choose their driving-licence class and exam date, switch appearance (theme mode, font size, accent colour), toggle haptic feedback and study reminders, manage offline video storage, and view the app version. It is a scrollable preferences sheet accessible from the main tab bar.

**Layout:**

OVERALL SHELL
- Frame size: 393 × 852 pt, cornerRadius 40, clip true.
- Background: linear gradient (205°) from #FBF8F0 (pos 0) → #EEECE6 (pos 0.55) → #DAD3C4 (pos 1). Maps to ScaffoldBackground / scaffoldGradientTop/Bottom tokens.
- Root layout: vertical VStack, children flow top-to-bottom.

1. STATUS BAR (id: aKavQ)
   - height 62, full-width, horizontal padding 28.
   - justifyContent: space_between (HStack).
   - Left: "9:41" — .appSans(16, .semiBold), fill appTextDark.
   - Right: HStack gap 7 — signal icon 18×18, wifi icon 18×18, battery-full icon 24×18, all fill appTextDark.

2. NAV BAR (id: DgIPD)
   - Full-width, padding [top 0, trailing 20, bottom 8, leading 20].
   - justifyContent: space_between (HStack), alignItems: center.
   - Left: Back button (id: ulT04) — circle 38×38, fill #FFFFFFCC, stroke #00000014 1pt, cornerRadius 100. Contains chevron-left icon 20×20 fill #0F0F12. Tapping navigates back (this screen is pushed, not a root tab).
   - Center: "Cài đặt" — .appSans(17, .extraBold / weight 800), fill #0F0F12.
   - Right: Invisible spacer 38×38 (balances center title).

3. SCROLLABLE CONTENT (id: y5eMJv)
   - Vertical VStack, gap 14, padding [top 0, trailing 20, bottom 20, leading 20], fill_container width, fill_container height.
   - Contains 4 section groups + 1 version text at the bottom.

--- SECTION: TÀI KHOẢN (id: fOEaM) ---
Section gap 6, layout vertical, full-width.

3a. Section eyebrow label (id: NQgQh)
    - Frame padding [0, 4] horizontal.
    - Text "TÀI KHOẢN" — .appSans(10, .extraBold), fill #7A7166, letterSpacing 1.2.

3b. Card (id: FBNVf)
    - cornerRadius 20, fill #FFFFFFCC, stroke #00000014 1pt.
    - Vertical layout, padding [top 2, horizontal 12, bottom 2].
    - Two rows separated by a 1pt divider (fill #00000010, full-width).

    Row 1 — Hạng giấy phép (id: p2DfC)
    - HStack, alignItems center, gap 12, padding [vertical 10].
    - Icon box 32×32, cornerRadius 8, fill #CFE3FF: id-card icon 18×18 fill #143A75.
    - Label "Hạng giấy phép" — .appSans(14, .semiBold), fill #0F0F12, fill_container width (fixed-width growth).
    - Value "B2" — .appSans(13, .bold), fill #7A7166.
    - chevron-right icon 18×18 fill #7A7166.
    - Tapping opens a picker/sheet to change licence class.

    Divider — rectangle 1pt fill #00000010, fill-width.

    Row 2 — Ngày thi (id: mJFGA)
    - HStack, alignItems center, gap 12, padding [vertical 10].
    - Icon box 32×32, cornerRadius 8, fill #FFE9B0: calendar icon 18×18 fill #7A4A00.
    - Label "Ngày thi" — .appSans(14, .semiBold), fill #0F0F12, fill_container width.
    - Value "27/06/2026" — .appSans(13, .bold), fill #7A7166.
    - chevron-right icon 18×18 fill #7A7166.
    - Tapping opens a DatePicker sheet.

--- SECTION: GIAO DIỆN (id: rfSKg) ---
Section gap 6.

4a. Eyebrow (id: SveDr)
    - Text "GIAO DIỆN" — .appSans(10, .extraBold), fill #7A7166, letterSpacing 1.2, padding [0, 4] horizontal.

4b. Card (id: VfJ4X)
    - cornerRadius 20, fill #FFFFFFCC, stroke #00000014 1pt, padding [top 2, horizontal 12, bottom 2].
    - Vertical layout, three rows separated by 1pt dividers.

    Row 1 — Giao diện (id: k39LB)
    - HStack, alignItems center, gap 12, padding [vertical 10].
    - Label "Giao diện" — .appSans(14, .semiBold), fill #0F0F12, fill_container.
    - Segmented control (id: jszRt): cornerRadius 100, fill #0F0F1210, padding 3, gap 6.
      Three segments: "Sáng" / "Tối" / "Tự động"
      Active pill: fill #0F0F12, text white .appSans(12, .bold), cornerRadius 100, padding [6, 12].
      Inactive pill: fill transparent, text #7A7166 .appSans(12, .bold), cornerRadius 100, padding [6, 12].
      Design shows "Sáng" as active segment.

    Divider 1pt #00000010.

    Row 2 — Cỡ chữ (id: PkzoI)
    - HStack, alignItems center, gap 12, padding [vertical 10].
    - Label "Cỡ chữ" — .appSans(14, .semiBold), fill #0F0F12, fill_container.
    - Segmented control (id: NVHGM): same pill container style.
      Three segments: "A" (small) / "A" (medium) / "A" (large) — visually differentiated by font size.
      Design shows middle "A" as active (medium), fill #0F0F12, others transparent #7A7166.

    Divider 1pt #00000010.

    Row 3 — Màu nhấn (id: VctgQ)
    - HStack, alignItems center, gap 12, padding [vertical 10].
    - Label "Màu nhấn" — .appSans(14, .semiBold), fill #0F0F12, fill_container.
    - Swatch row (id: FC4k0): cornerRadius 100, fill #0F0F1210, padding [6, 8], gap 8, alignItems center.
      4 colour swatches, each 24×24 circle (cornerRadius 100):
        1. #D4714E — appPrimary terracotta — SELECTED (stroke #0F0F12 2pt, no fill inside icon)
        2. #FFC233 — amber/gold
        3. #43A047 — green
        4. #3D7BE0 — blue
      Unselected swatches have transparent stroke (strokeWidth 0 / no stroke shown).
      Tapping a swatch sets it as the active primary colour.

--- SECTION: ỨNG DỤNG (id: R0bXm) ---
Section gap 6.

5a. Eyebrow (id: RJ8N4)
    - Text "ỨNG DỤNG" — .appSans(10, .extraBold), fill #7A7166, letterSpacing 1.2, padding [0, 4] horizontal.

5b. Card (id: uFMx7)
    - cornerRadius 20, fill #FFFFFFCC, stroke #00000014 1pt, padding [top 2, horizontal 12, bottom 2].
    - Vertical layout, three rows separated by 1pt dividers.

    Row 1 — Rung phản hồi (id: JAYqq)
    - HStack, alignItems center, gap 12, padding [vertical 10].
    - Icon box 32×32, cornerRadius 8, fill #FFE9B0: vibrate icon 18×18 fill #7A4A00.
    - Label "Rung phản hồi" — .appSans(14, .semiBold), fill #0F0F12, fill_container.
    - Toggle (id: xi6pV): ON state shown. 44×26, cornerRadius 100, fill appPrimary (#D4714E), justifyContent: end, padding 3. White knob ellipse 20×20. SwiftUI Toggle .tint(appPrimary).

    Divider 1pt #00000010.

    Row 2 — Nhắc nhở học tập (id: L9y2o)
    - HStack, alignItems center, gap 12, padding [vertical 10].
    - Icon box 32×32, cornerRadius 8, fill #FFE9B0: bell icon 18×18 fill #7A4A00.
    - Label "Nhắc nhở học tập" — .appSans(14, .semiBold), fill #0F0F12, fill_container.
    - Toggle (id: GAV7P): ON state shown. Same 44×26 appPrimary toggle.

    Divider 1pt #00000010.

    Row 3 — Quản lý tải offline (id: Sriuz)
    - HStack, alignItems center, gap 12, padding [vertical 10].
    - Icon box 32×32, cornerRadius 8, fill #FFE9B0: download icon 18×18 fill #7A4A00.
    - Label "Quản lý tải offline" — .appSans(14, .semiBold), fill #0F0F12, fill_container.
    - Value "1.2 GB" — .appSans(13, .bold), fill #7A7166.
    - chevron-right icon 18×18 fill #7A7166.
    - Tapping pushes/presents the offline video management sheet (VideoOfflineCard).

--- VERSION FOOTER (id: qJXQb) ---
- Text "Phiên bản 1.0.0" — .appSans(11.5, .medium), fill #7A7166, textAlign center, fill-width.
- Sits at the bottom of the scrollable content VStack with 14pt gap above.


**Tokens:** Background gradient: linear 205° #FBF8F0 → #EEECE6 → #DAD3C4 (maps to ScaffoldBackground / scaffoldGradientTop + scaffoldGradientBottom tokens).
Card fill: #FFFFFFCC (semi-transparent white — no direct token; use Color.white.opacity(0.8) or cardBg at reduced opacity; the design uses the frosted-white pattern).
Card stroke: #00000014 (Color.black.opacity(0.08)).
Divider: #00000010 → appDivider.
Eyebrow text: #7A7166 → closest to appTextMedium (#737373); use that token.
Primary label fill: #0F0F12 → appTextDark (#171717 token; #0F0F12 is the design's near-black — use appTextDark).
Value / trailing text: #7A7166 → appTextMedium.
Icon box blue: fill #CFE3FF, icon #143A75 (no token — literal hex).
Icon box amber: fill #FFE9B0, icon #7A4A00 (no token — literal hex).
Segmented control background: #0F0F1210 (Color(hex: "#0F0F12").opacity(0.063) — no token; use Color.appTextDark.opacity(0.063)).
Segmented active pill: #0F0F12 → appTextDark.
Accent / toggle ON / swatch 1: #D4714E → appPrimary.
Swatch 2 (amber): #FFC233 → appWarning (#F59E0B is token; design uses #FFC233 — literal hex, close enough to use appWarning or literal).
Swatch 3 (green): #43A047 → appSuccess (#22C55E token is brighter; use literal #43A047).
Swatch 4 (blue): #3D7BE0 (no token — literal hex).
Nav title / back icon: #0F0F12 → appTextDark.
Back button fill: #FFFFFFCC — Liquid Glass style (same as CTA Glass Secondary container).
Version text: #7A7166 → appTextMedium.
Fonts: all .appSans(size:weight:) — Be Vietnam Pro family. No .system() calls.
Spacing tokens: section gap 14, card row gap 12, swatch gap 8, eyebrow-to-card gap 6.
Card corner radius: 20. Nav back button corner radius: 100. Toggle corner radius: 100. Swatch corner radius: 100. Icon box corner radius: 8.


**Reuse widgets:** ScaffoldBackground() — wraps the screen gradient background, AppButton — used inside VideoOfflineCard for Tải tất cả / Xoá actions, ProgressBarView — used inside VideoOfflineCard for download progress, AppTabBar — the 4-tab frosted bar at the bottom (Settings is one of its tabs), .glassCard(cornerRadius:tint:) — NOT used for the white cards in this design; the white semi-transparent cards use a custom flat fill #FFFFFFCC with stroke #00000014 (see SettingsCard new widget below), .screenHeader(title:) — existing modifier if used in non-push contexts; here the design has an explicit custom NavBar row so a custom NavBar is preferred

**New widgets:**
- SettingsCard — flat white card container: `SettingsCard(@ViewBuilder content: () -> Content)`. Applies cornerRadius 20, fill Color.white.opacity(0.8), stroke Color.black.opacity(0.08) width 1, vertical layout padding [top 2, horizontal 12, bottom 2]. Does NOT use .glassCard(). Replaces the current .glassCard() applied to section cards since the design shows a solid semi-transparent white fill, not the glassCard frosted look.
- SettingsRowDivider — thin 1pt divider: `SettingsRowDivider()`. Rectangle 1pt height, fill Color.black.opacity(0.063), frame(.maxWidth: .infinity).
- SettingsEyebrow(title: String) — all-caps section label: `.appSans(10, .heavy)`, fill appTextMedium (#7A7166), letterSpacing 1.2, horizontal padding 4.
- SettingsIconBox(fill: Color, iconColor: Color, icon: String, library: String = "lucide") — 32×32 rounded-rect icon container: cornerRadius 8, specified fill, icon 18×18 in specified iconColor. Used for all coloured icon boxes in the three sections.
- SettingsChevronRow(iconBox: SettingsIconBox, label: String, value: String?, onTap: () -> Void) — tappable row with icon box, label, optional trailing value string, and chevron-right 18×18. HStack gap 12, vertical padding 10. Used for Hạng giấy phép, Ngày thi, Quản lý tải offline rows.
- SettingsToggleRow(iconBox: SettingsIconBox, label: String, isOn: Binding<Bool>) — row with icon box, label, and SwiftUI Toggle tinted appPrimary. HStack gap 12, vertical padding 10. Toggle 44×26 matches design spec.
- SettingsSegmentedControl(options: [String], selected: Binding<Int>) — pill-style segmented picker: outer capsule fill Color.appTextDark.opacity(0.063) cornerRadius 100 padding 3 gap 6; active segment pill fill appTextDark text white; inactive transparent text appTextMedium; all text .appSans(12, .bold) cornerRadius 100 padding [6,12].
- AccentColorSwatches(colors: [Color], selected: Binding<Color>, onSelect: (Color) -> Void) — horizontal swatch row: outer capsule fill Color.appTextDark.opacity(0.063) cornerRadius 100 padding [6,8] gap 8; each swatch 24×24 circle; selected swatch gets stroke appTextDark 2pt; unselected no stroke.

**Copy:**
- 9:41
- Cài đặt
- TÀI KHOẢN
- Hạng giấy phép
- B2
- Ngày thi
- 27/06/2026
- GIAO DIỆN
- Giao diện
- Sáng
- Tối
- Tự động
- Cỡ chữ
- A
- A
- A
- Màu nhấn
- ỨNG DỤNG
- Rung phản hồi
- Nhắc nhở học tập
- Quản lý tải offline
- 1.2 GB
- Phiên bản 1.0.0

**States:** NORMAL (populated): All rows show current persisted values. Toggles reflect @AppStorage state. Selected swatch has a 2pt border. Active theme-mode segment is highlighted. Active font-size segment is highlighted. Offline storage shows cached size (e.g. "1.2 GB").

TOGGLE OFF: Toggle fill changes from appPrimary to a neutral grey (#E5E5E5 or system); knob slides to leading side (justifyContent: start). Haptics row: icon changes to a muted colour. Reminder row: icon changes to muted colour.

LICENCE PICKER OPEN: Tapping "Hạng giấy phép" row presents a modal sheet or inline picker to choose A1/A2/B1/B2/C/D/E etc. Current value updates in the trailing "B2" label.

EXAM DATE PICKER OPEN: Tapping "Ngày thi" row presents a DatePicker sheet. The selected date populates the trailing value label (formatted dd/MM/yyyy).

OFFLINE SHEET OPEN: Tapping "Quản lý tải offline" row pushes/presents the VideoOfflineCard sheet showing per-chapter download progress, Tải tất cả / Xoá buttons.

LOADING: Not applicable — settings are synchronous @AppStorage reads; no loading spinner needed.

SCROLL: Content scrolls vertically; status bar and nav bar are fixed (non-scrolling) above the ScrollView.

NOTIFICATION PERMISSION DENIED: When "Nhắc nhở học tập" is toggled ON but notification permission is denied, toggle snaps back to OFF and an alert "Cần quyền thông báo" / "Bật thông báo trong Cài đặt để nhận nhắc nhở ôn tập." is presented with "Mở Cài đặt" / "Để sau" actions.


**Interactions:** BACK button (ulT04) → dismiss/pop the Settings screen (navigates back to the previous screen or tab).
Tap "Hạng giấy phép" row → present licence-type picker sheet; on confirm, write @AppStorage licenseType and refresh trailing label.
Tap "Ngày thi" row → present DatePicker sheet; on confirm, call progressStore.setExamDate(_:), refresh trailing label.
Tap theme-mode segment ("Sáng"/"Tối"/"Tự động") → update @AppStorage themeMode; active pill animates highlight.
Tap font-size segment (small A / medium A / large A) → update @AppStorage fontSize; active pill animates; trigger Haptics.selection().
Tap accent colour swatch → update ThemeStore primaryColor; selected swatch gains 2pt #0F0F12 border.
Toggle "Rung phản hồi" → toggle @AppStorage hapticsEnabled; trigger Haptics.impact(.light) on change.
Toggle "Nhắc nhở học tập" → call handleReminderChange(turnedOn:); if permission denied show alert; if granted, call syncReminders().
Tap "Quản lý tải offline" row → navigate to / present VideoOfflineCard (already implemented); trailing "1.2 GB" shows videoCache.cacheSizeMB formatted.
Version footer "Phiên bản 1.0.0" → no action (static display; value read from Bundle).


**Notes:** Most likely existing file: GPLX2026/Features/Settings/SettingsView.swift. The current SettingsView.swift is substantially richer than the design frame (it also includes data-reset rows, about info, exam countdown toggle, daily-goal stepper, reminder-hour picker, and FontSizeSlider) — those are correct product features not shown in this narrower design frame. The rebuild delta is:

1. The design's white card style (fill #FFFFFFCC, stroke #00000014, cornerRadius 20) differs from the current .glassCard() modifier being applied to section cards. Replace card containers with the new SettingsCard widget — flat semi-transparent white, no shadow/blur.

2. The design uses a pill SettingsSegmentedControl for both theme mode (Sáng/Tối/Tự động) and font size (three A segments), replacing the current ThemeModePicker (which may use a Picker(.segmented)) and FontSizeSlider. The new SettingsSegmentedControl widget needs to be built.

3. Accent colour selection uses AccentColorSwatches (four 24×24 circles in a capsule container), not a colour-picker sheet. The existing PrimaryColorPicker.swift should be replaced or adapted.

4. The "ỨNG DỤNG" section collapses Rung phản hồi, Nhắc nhở học tập, and Quản lý tải offline into a single card — matching the design. In the current code these are spread across different sections.

5. The icon boxes use a coloured rounded-rect (SettingsIconBox) pattern rather than bare SF Symbols. The amber boxes use #FFE9B0 fill with #7A4A00 icon; the blue box uses #CFE3FF fill with #143A75 icon.

6. The section eyebrow labels in the design are all-caps small text (.appSans 10 weight 800, letterSpacing 1.2, fill #7A7166) placed outside and above the card with 6pt gap — matches current settingsSection() helper pattern but the exact font/tracking values must be updated.

7. The nav bar is custom (not .screenHeader) because this screen is pushed (has a back button). Use a custom HStack nav row instead of the .screenHeader modifier.

8. The SettingsView already has @AppStorage hapticsEnabled, themeMode, fontSize, licenseType, dailyReminderEnabled — these bindings are correct and should be preserved.

9. ThemeModePicker.swift and BackgroundAnimationPicker.swift exist but should be superseded by the inline SettingsSegmentedControl for theme and accent swatches respectively.

10. The "Quản lý tải offline" trailing value "1.2 GB" should be computed from videoCache.cacheSizeMB (already available on HazardVideoCache as a published property).



## Offline download manager  (frame mfexH)

**Purpose:** Full-screen sheet (pushed via NavigationStack) that lets the user download all hazard-perception video chapters for offline playback. Shows storage consumption, a global "Tải tất cả" CTA, a per-chapter list with per-chapter download/pause/queued/done state, and a "Chỉ tải qua Wi-Fi" toggle. Backed by HazardVideoCache (@Observable, injected via environment).

**Layout:**
Frame: 393 × 852 pt, cornerRadius 40, vertical VStack with clip.
Background: 3-stop linear gradient at 205°: #FBF8F0 → #EEECE6 (55%) → #DAD3C4 (= scaffoldGradientTop → scaffoldBg → scaffoldGradientBottom tokens). Use ScaffoldBackground() or replicate with the same gradient stops.

── 1. STATUS BAR (id Lal72) ──
  Height 62, horizontalPadding 28. HStack justifyContent space-between.
  Leading: "9:41" text, 16pt semibold, appTextDark.
  Trailing: HStack gap 7 — signal icon 18×18, wifi icon 18×18, battery-full icon 24×18; all appTextDark.
  (Standard iOS status bar — let system status bar render; do not hand-build unless mocking.)

── 2. NAV BAR (id EIewx) ──
  HStack, padding [top:0, trailing:20, bottom:8, leading:20], justifyContent space-between, alignItems center.
  Leading: circular back button 38×38, cornerRadius 100, fill #FFFFFFCC, stroke #00000014 1pt.
    Inside: chevron-left icon 20×20, fill #0F0F12.
    Tap: dismisses the screen (NavigationStack pop or sheet dismiss).
  Center: "Tải offline" title, 17pt weight 800, #0F0F12.
  Trailing: spacer frame 38×38 (balances layout; invisible).

── 3. SCROLLABLE CONTENT (id hi1Eq) ──
  ScrollView vertical. VStack gap 14, padding [top:0, trailing:20, bottom:20, leading:20], fill width/height.

  3-A. STORAGE CARD (id UobnF)  ← outermost card
    Outer container: cornerRadius 20, fill #FFFFFFCC, stroke #00000014 1pt, padding 8, fill width.
    Inner card (id NsZrP): cornerRadius 12, fill #FAF9F7 (= cardBg), gap 6, padding 12, fill width, layout vertical.
      Row "Top" (id LaYuw): HStack space-between.
        Leading: "BỘ NHỚ ĐÃ DÙNG" eyebrow text, 10pt weight 800, tracking 1.2, color #7A7166.
        Trailing: "Clear" HStack gap 4, alignItems center:
          trash-2 icon 13×13, fill #8A2A1F (dark red).
          "Xóa tất cả" text 12pt weight 700, fill #8A2A1F.
          Tap: calls hazardVideoCache.clearCache() with a confirmation alert before executing.
      Row "Num" (id OKflR): HStack space-between, alignItems end, gap 6.
        Leading: "1.2 GB" text 30pt weight 700 lineHeight 1, fill #0F0F12.
          (Bind to String(format: "%.1f GB", hazardVideoCache.cacheSizeMB / 1024) dynamically.)
        Trailing: "còn trống 8.4 GB" text 12.5pt weight 600, fill #7A7166.
          (Bind to remaining device free space dynamically; format "còn trống X GB".)

  3-B. DOWNLOAD ALL BUTTON (id iKHQB)
    HStack, cornerRadius 25, fill appPrimary (#D4714E), height 50, justifyContent center, gap 8, fill width.
    download icon 17×17, fill white.
    "Tải tất cả · 120 video (480 MB)" text 14.5pt weight 700, fill white.
    States:
      - Idle (none cached): shows above. Tap: calls hazardVideoCache.downloadAll() in a Task.
      - Downloading (isDownloadingAll == true): label becomes "Dừng tải · X MB/s", icon becomes pause icon; fill stays appPrimary. Tap: calls hazardVideoCache.pauseAll().
      - All downloaded (isCached == true): label "Đã tải xong · X video", icon becomes check; fill becomes appSuccess tinted background, or keep primary (design shows primary; use primary).
    Note: The design shows AppButton-style but with a custom terracotta solid fill (not Liquid Glass) at cornerRadius 25 and height 50 — render as a plain Button with that exact HStack content, NOT via AppButton which uses Liquid Glass.

  3-C. SECTION LABEL "THEO CHƯƠNG" (id HFFMz)
    Padding [top:2, leading:4, bottom:0, trailing:4], fill width.
    Text "THEO CHƯƠNG", 10pt weight 800, tracking 1.2, color #7A7166.
    (Reuse SectionTitle but override font weight/tracking/color or render inline; the existing SectionTitle uses appSerif 13pt medium — render this as a custom Text to match the design exactly.)

  3-D. CHAPTERS CARD (id cNB9E)
    Outer card: cornerRadius 20, fill #FFFFFFCC, stroke #00000014 1pt, padding [top:2, bottom:2, leading:12, trailing:12], fill width, layout vertical.
    Contains 4 chapter rows separated by 1pt dividers (fill #00000010 = black 6% opacity).

    Each chapter row (padding [top:10, bottom:10, leading:0, trailing:0], HStack gap 12, alignItems center):
      1. ICON BOX (id *IB): 36×36 frame, cornerRadius 8.
         Each chapter has a distinct background color and icon color:
           - "Phanh chủ động đô thị": bg #FFE9B0, icon building-2 18×18 fill #7A4A00.
           - "Đường cao tốc & quốc lộ": bg #CFE3FF, icon route 18×18 fill #143A75.
           - "Tình huống ban đêm": bg #D9F0DA, icon moon 18×18 fill #1F5A2A.
           - "Đường nông thôn & đèo": bg #FFD7CF, icon mountain 18×18 fill #8A2A1F.
      2. MID column (VStack gap 2, fill width):
           Title: 13.5pt weight 700, fill #0F0F12 (= appTextDark).
           Subtitle: 11.5pt weight 500, fill #7A7166 (= appTextMedium). Dynamic content per state (see States section).
      3. STATE BUTTON (36×36, cornerRadius 100, alignItems center, justifyContent center):
           - Downloaded: bg #D9F0DA, check icon 18×18 fill #1F5A2A. Non-interactive.
           - Downloading/paused: bg #D4714E1F (appPrimary 12% opacity), pause icon 18×18 fill appPrimary. Tap: pause this chapter.
           - Not downloaded (idle): bg appPrimary (#D4714E), download icon 18×18 fill white. Tap: start chapter download.
           - Queued: bg #0F0F1210 (black 6% opacity), timer icon 18×18 fill #7A7166. Non-interactive (or tap to cancel from queue).

    Dividers: Rectangle height 1, fill #00000010, fillWidth. Placed between rows (not after last row).

  3-E. SPACER (id TFmey)
    Flexible spacer (frame maxHeight fill) — pushes Wi-Fi toggle to bottom.

  3-F. WI-FI TOGGLE ROW (id nvjV7)
    HStack gap 12, padding [top:12, bottom:12, leading:14, trailing:14], cornerRadius 16, fill #FFFFFFCC, stroke #00000014 1pt, fill width.
    wifi icon 18×18, fill #0F0F12.
    "Chỉ tải qua Wi-Fi" text 14pt weight 600, fill #0F0F12, fill width (textGrowth fixed-width).
    Toggle visual (custom, not SwiftUI Toggle):
      Outer capsule: 44×26, cornerRadius 100, fill appPrimary (shown ON), padding 3.
        Inner knob: Circle 20×20, fill white, aligned trailing (justifyContent end).
      OFF state: fill appDivider, knob aligned leading.
    Bind to @AppStorage("wifiOnlyDownload") Bool, default true.
    Tap the row (or just the capsule) to toggle.

OVERALL VERTICAL ORDER (top → bottom within ScrollView content):
  StorageCard → DownloadAllButton → SectionLabel → ChaptersCard → Spacer → WifiToggleRow

**Tokens:** Background gradient: scaffoldGradientTop (#FBF8F0) → scaffoldBg (#EEECE6 at 55%) → scaffoldGradientBottom (#DAD3C4), 205° linear.
Nav back button: fill #FFFFFFCC (white 80% opacity), stroke #00000014 (black 8%), icon #0F0F12.
Title: #0F0F12 (near-black, appTextDark equivalent for this screen's dark text).
Storage outer card: fill #FFFFFFCC, stroke #00000014 1pt, cornerRadius 20.
Storage inner card: fill #FAF9F7 (= cardBg token), cornerRadius 12.
Eyebrow / subtitle text: #7A7166 (≈ appTextMedium but slightly warmer; use appTextMedium Color.appTextMedium).
Clear button: #8A2A1F (dark terracotta red — no token; literal hex).
Storage value text: #0F0F12 (appTextDark).
Download All button: appPrimary (#D4714E), icon+label appOnPrimary (white), cornerRadius 25, height 50.
Section label text: #7A7166 (appTextMedium).
Chapters card: fill #FFFFFFCC, stroke #00000014, cornerRadius 20.
Chapter icon box bg colors (no tokens): amber #FFE9B0, blue #CFE3FF, green #D9F0DA, red-light #FFD7CF.
Chapter icon fill colors (no tokens): amber-dark #7A4A00, blue-dark #143A75, green-dark #1F5A2A, red-dark #8A2A1F.
Chapter title: appTextDark (#0F0F12/171717).
Chapter subtitle: appTextMedium (#7A7166).
State button — downloaded: bg #D9F0DA, icon #1F5A2A.
State button — downloading: bg appPrimary.opacity(0.12) (#D4714E1F), icon appPrimary.
State button — idle/download: bg appPrimary (#D4714E), icon white.
State button — queued: bg Color.black.opacity(0.06) (#0F0F1210), icon #7A7166.
Divider: Color.black.opacity(0.063) (#00000010), height 1.
Wi-Fi row: fill #FFFFFFCC, stroke #00000014, cornerRadius 16.
Wi-Fi toggle ON: fill appPrimary; OFF: fill appDivider. Knob: white.
Spacing tokens: gap between Content children = 14pt; nav padding trailing/leading = 20pt; content padding = 20pt bottom/sides.

**Reuse widgets:** ScaffoldBackground() — for the warm gradient background, CircularActionButton — NOT directly used; the state buttons are custom 36×36 circles (smaller than 44pt), but pattern follows CircularActionButton(subtle:) logic, IconBox — reuse for chapter icon boxes: IconBox(icon:, color:, size:36, cornerRadius:8, iconFontSize:18) — note: design uses solid tinted bg, but IconBox fills with color.opacity(0.12); the design fills are already the tinted value so pass the dark icon color directly to match visual, ProgressBarView — available for future progress bar inside chapter rows if a downloading-progress bar is added below the subtitle (not in this frame but supported by HazardVideoCache.downloadProgress[id]), AppButton — do NOT use for the Download All CTA (design uses solid fill cornerRadius 25, not Liquid Glass); render as a plain Button

**New widgets:**
- StorageUsageCard: View — props: usedGB: Double, freeGB: Double, onClearAll: () -> Void. Renders the outer frosted card + inner cream card with the eyebrow label, used/free values, and a destructive 'Xóa tất cả' inline button. Calls onClearAll after confirmation. File: GPLX2026/Features/Hazard/OfflineDownloadManagerView.swift (private subview or extracted).
- DownloadChapterRow: View — props: chapter: HazardChapter (value type with id, name, iconName, iconBgColor, iconFgColor, videoCount, sizeMB), state: ChapterDownloadState (enum: downloaded, downloading(progress: Double), idle, queued), onTapAction: () -> Void. Renders the 36×36 icon box, name + dynamic subtitle, and the 36×36 state circle button. The subtitle text is derived from state: downloaded → 'X video · đã tải Y MB'; downloading → 'X video · đang tải Z%'; idle → 'X video · Y MB'; queued → 'X video · trong hàng đợi'. File: same view file as above.
- WifiOnlyToggleRow: View — props: isOn: Binding<Bool>. Renders the frosted row with wifi icon, label 'Chỉ tải qua Wi-Fi', and a custom capsule toggle (44×26, cornerRadius 100, fill appPrimary when on / appDivider when off, white 20pt knob, animates with .spring). File: same view file or Core/Common if reused elsewhere.
- HazardChapter: struct (value type) — id: Int, name: String, iconName: String, iconBgColor: Color, iconFgColor: Color, videoCount: Int, estimatedSizeMB: Int. Static list of all chapters with their design colors. File: GPLX2026/Core/Models/ or inline in the view.
- ChapterDownloadState: enum — cases: downloaded, downloading(progress: Double), paused, idle, queued. Computed from HazardVideoCache state for a given chapter id. File: inline in OfflineDownloadManagerView.swift.

**Copy:**
- Tải offline
- BỘ NHỚ ĐÃ DÙNG
- Xóa tất cả
- 1.2 GB
- còn trống 8.4 GB
- Tải tất cả · 120 video (480 MB)
- THEO CHƯƠNG
- Phanh chủ động đô thị
- 30 video · đã tải 120 MB
- Đường cao tốc & quốc lộ
- 30 video · đang tải 45%
- Tình huống ban đêm
- 30 video · 121 MB
- Đường nông thôn & đèo
- 30 video · trong hàng đợi
- Chỉ tải qua Wi-Fi
- Dừng tải · %@ MB/s
- Đã tải xong · %@ video
- Xác nhận xóa tất cả video đã tải?
- Xóa
- Huỷ

**States:** SCREEN-LEVEL STATES:
- Loading (onAppear): call hazardVideoCache.ensureStatsLoaded(). Storage card shows placeholder/skeleton for usedGB until stats are loaded.
- Idle (nothing downloaded): Download All button shows full CTA. All chapter rows show idle state (download button).
- Partially downloaded: mix of chapter row states; Download All button active.
- Downloading all (isDownloadingAll == true): Download All button becomes "Dừng tải · X MB/s" with pause icon. Downloading chapter rows show pause button + "đang tải X%" subtitle. Queued chapters show timer icon.
- All downloaded (isCached == true): Download All button shows completed state. All chapter rows show check state.
- Error state (failedIds non-empty): chapter rows with failed IDs surface an error indicator (red exclamation or red subtitle "Tải thất bại — thử lại"); not shown in the design frame but required for graceful handling.

CHAPTER ROW STATES (per ChapterDownloadState):
- downloaded: green check circle (bg #D9F0DA, icon #1F5A2A), subtitle "X video · đã tải Y MB". Non-tappable state button.
- downloading(progress): terracotta pause circle (bg appPrimary 12%, icon appPrimary), subtitle "X video · đang tải Z%". Tap pauses this chapter.
- idle: filled terracotta download circle (bg appPrimary, icon white), subtitle "X video · Y MB". Tap starts download.
- queued: grey timer circle (bg black 6%, icon #7A7166), subtitle "X video · trong hàng đợi". Shown when isDownloadingAll but this chapter has not started yet.
- failed: red circle (bg appError 12%, icon appError), subtitle "Tải thất bại — thử lại". Tap retries.

TOGGLE STATE:
- ON (default): capsule fill appPrimary, knob right.
- OFF: capsule fill appDivider, knob left.

CLEAR CACHE CONFIRMATION:
- Alert with title "Xác nhận xóa tất cả video đã tải?" and destructive button "Xóa" / cancel "Huỷ".

**Interactions:** NAV: Back chevron button (top-left 38×38 circle) — pops NavigationStack or dismisses sheet. Swipe-back gesture enabled (UINavigationController.interactivePopGestureRecognizer already enabled in AppTheme).

DOWNLOAD ALL BUTTON: Tap when idle → Task { await hazardVideoCache.downloadAll() }. Tap when isDownloadingAll → hazardVideoCache.pauseAll(). Button is disabled (grey) when isCached == true.

CLEAR ALL (Storage Card trailing): Tap → show confirmation Alert. On confirm → hazardVideoCache.clearCache().

CHAPTER ROW STATE BUTTON:
  - Idle state: Tap → Task { await hazardVideoCache.downloadChapter(chapter.id) }.
  - Downloading/paused state: Tap → hazardVideoCache.pauseChapter(chapter.id).
  - Downloaded state: no tap action (or tap → show confirm delete-chapter alert if desired; not in design).
  - Queued state: no tap action (chapter is waiting in the global download queue).
  - Failed state: Tap → Task { await hazardVideoCache.downloadChapter(chapter.id) } (retry).

WI-FI TOGGLE ROW: Tap anywhere on the row → toggle @AppStorage("wifiOnlyDownload"). Animate capsule with .animation(.spring(response: 0.3, dampingFraction: 0.7)).

SPEED DISPLAY: When isDownloadingAll, observe hazardVideoCache.downloadSpeedMBps and format as e.g. "1.2 MB/s" in the Download All button label.

SHEET NAVIGATION TARGET: This screen is presented from PracticeTab or SettingsView (both reference HazardVideoCache). It is a pushed view (NavigationLink or .navigationDestination), not a sheet, based on the Nav bar back-button pattern. Likely target file: GPLX2026/Features/Hazard/ as a new file OfflineDownloadManagerView.swift.

**Notes:** Most likely new file: GPLX2026/Features/Hazard/OfflineDownloadManagerView.swift (does not yet exist). The Hazard feature already has HazardTestView, HazardResultView, HazardHistoryDetailView — this is a new screen in that feature area. HazardVideoCache is already @Observable and environment-injected (see GPLX2026App.swift and HazardTestView). Call hazardVideoCache.ensureStatsLoaded() in .onAppear. 

IconBox in Core/Common/Display/IconBox.swift fills the background with color.opacity(0.12) — but the design provides already-tinted pastel background colors (e.g. #FFE9B0). To match exactly, either: (a) pass the pastel color as the bg by using a custom init that accepts explicit bgColor + iconColor, or (b) pass the dark icon color (#7A4A00) and let IconBox tint it; this will NOT reproduce the exact pastel because the opacity is computed from the dark color. Preferred approach: create a local ChapterIconBox(bgColor: Color, iconName: String, iconColor: Color) private subview rather than using IconBox, OR extend IconBox with an explicit bgColor override parameter. 

The Storage Card outer fill (#FFFFFFCC) and Chapters Card outer fill (#FFFFFFCC) are frosted-white translucent, NOT the flat cardBg (#FAF9F7). Do NOT use .glassCard() modifier (which fills with cardBg solid). Instead apply a manual .background(Color(hex: 0xFFFFFF, opacity: 0.8)) with an overlay stroke Color.black.opacity(0.078) lineWidth 1. This is a deliberate departure from the flat-card rule in the design system — the design uses translucent frosted panels for this screen.

The Download All CTA is a solid terracotta Button (NOT AppButton, which uses Liquid Glass). Render as a plain SwiftUI Button with the HStack content, .frame(maxWidth: .infinity, height: 50), .background(Color.appPrimary), .clipShape(Capsule()) (cornerRadius 25 ≈ height/2).

Swift 6 / strict concurrency: all calls to HazardVideoCache must be on MainActor (already @MainActor). Wrap Task calls in Task { @MainActor in ... } or rely on the view being on MainActor.

The flexible Spacer (3-E) between the Chapters card and Wi-Fi row means the Wi-Fi toggle row is pinned to the bottom of the screen. Since this is inside a ScrollView, on short content the spacer will push it down; on long content (many chapters) it will scroll naturally. Implement as Spacer() inside the ScrollView VStack — this is correct SwiftUI behavior.

Device free-space computation for the "còn trống X GB" label: use FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first and query .volumeAvailableCapacityForImportantUsageKey. Do this off the main thread in a .task modifier.


## Hazard / Mo phong list  (frame YPqmZ)

**Purpose:** Entry-point list screen for the hazard-perception ("mô phỏng / tình huống") feature. Shows overall progress, a "focus" highlight card for a recommended situation, filter chips to scope the chapter list, and a vertically scrollable list of chapters (each acting as a launch point for that chapter's situations). Two modal overlays live in this frame: a deprecation-warning bottom sheet that appears on first entry, and a "situation jump" bottom sheet that lists all individual situations within the current simulated exam session with their per-situation scores.

**Layout:**
The root frame is a 393 pt wide iOS screen with cornerRadius 40, clipped, and a 3-stop warm linear gradient fill (top-left: #FBF8F0 → 55% #EEECE6 → #DAD3C4 at 205°). ScaffoldBackground() provides this shell.

Top to bottom, all content sits inside a vertical VStack("Content") with gap 16 pt, horizontal padding 20 pt, bottom padding 20 pt (no top padding — the Status Bar and Nav sit at the very top within the scroll region):

1. STATUS BAR (id gr53p) — height 62, horizontal padding 28.
   - HStack justifyContent space-between:
     - "9:41" text: Be Vietnam Pro 15/700 fill #0F0F12
     - Indicators HStack gap 6: "•••" (13/700), "≈" (14/700), and a 24×12 rounded rect (r3) fill #0F0F12

2. NAV BAR (id W0UDc) — full-width HStack justifyContent space-between, inside the Content stack:
   - Back button: 38×38 circle fill #FFFFFFCC, stroke #00000014 1pt; lucide chevron-left 20×20 fill #0F0F12.
   - Title: "Mô phỏng" Be Vietnam Pro 17/800 fill #0F0F12.
   - Search button: 38×38 circle fill #FFFFFFCC, stroke #00000014 1pt; lucide search 18×18 fill #0F0F12.

3. HERO PROGRESS CARD (id M3hHk) — full-width, cornerRadius 22, fill #FFFFFFCC, stroke #00000014 1pt, padding 12, inner gap 14, vertical layout. This is a bespoke card (not FeatureCard):
   a. Top row (jTkBi) — HStack justifyContent space-between, full width:
      - Left VStack gap 4 (QYcn9):
        - Eyebrow: "TIẾN ĐỘ CỦA BẠN" Be Vietnam Pro 10/800 fill #7A7166 letterSpacing 1.2
        - Num HStack alignItems end gap 6 (P22na):
          - Big number: "34" Be Vietnam Pro 34/700 lineHeight 1 fill #0F0F12
          - Subtitle: "/ 120 tình huống" Be Vietnam Pro 13/600 fill #7A7166
      - Right pill (omjoZ): cornerRadius 100, fill #FFE9B0, padding [6, 12]:
        - "28%" Be Vietnam Pro 13/800 fill #7A4A00
   b. Foot row (WRJoZ) — HStack justifyContent space-between, full width:
      - Streak HStack gap 6 (hyni7):
        - lucide flame 15×15 fill #E5523F
        - "5 ngày liên tiếp" Be Vietnam Pro 12/700 fill #0F0F12
      - Continue button (zRDmK): cornerRadius 100, fill #0F0F12, padding [7,12,7,14], HStack gap 6:
        - "Tiếp tục" Be Vietnam Pro 12/700 fill #FFFFFF
        - lucide play 14×14 fill #FFFFFF

4. FILTER CHIPS (id iRazt) — full-width HStack gap 8, horizontally scrollable (overflows right). Four chips:
   a. "Tất cả" (tWRNt): cornerRadius 100, fill #0F0F12, padding [7,14]; label Be Vietnam Pro 12/700 fill #FFFFFF — ACTIVE/selected state.
   b. "Chưa làm" (l9m45): cornerRadius 100, fill #FFFFFFCC, stroke #00000014 1pt, padding [7,14]; label 12/600 fill #7A7166 — inactive.
   c. "Sai" (lp73f): same inactive style as above; label "Sai".
   d. "Đã xong" (Ng8Bl): same inactive style; label "Đã xong".

5. FOCUS CARD (id p3S0bh) — full-width FeatureCard ref (EXgYq). Dark card fill #0F0F12, cornerRadius 22, padding 12, shadow blur 20 offset y 8 #0F0F1240. HStack alignItems center gap 14:
   - Info VStack gap 12 (full width):
     - Eyebrow: "GỢI Ý HÔM NAY" Be Vietnam Pro 10/800 fill #FFC233 letterSpacing 1.2
     - Title: "Người đi bộ ngang đường" Be Vietnam Pro 20/700 fill #FFFFFF letterSpacing -0.2, fixed width fill_container
     - Pills HStack gap 6:
       - Pill1 "Chương 3" cornerRadius 14, fill #FFFFFF1F, padding [4,10], text 11.5/700 #FFFFFF
       - Pill2 "00:22" cornerRadius 14, fill #FFFFFF1F, padding [4,10], text 11.5/700 #FFFFFF
       - Pill3 "Trung bình" cornerRadius 14, fill #FFFFFF1F, padding [4,10], text 11.5/700 #FFFFFF (note: design override changes fill to #FFFFFF1F and text to #FFFFFF from the component default of #FFC233 for the highlighted tag)
   - Play button (MVtg2): 52×52, cornerRadius 26, fill #FFC233; lucide play 20×20 fill #7A4A00.

6. CHAPTERS LIST (id rH2U9) — full-width VStack gap 10, vertical layout. Contains 4 chapter rows. Each chapter row is a flat card: full-width, cornerRadius 22, fill #FFFFFFCC, stroke #00000014 1pt, padding 12, HStack alignItems center gap 12:
   - Left Badge: 44×44, cornerRadius 10; unique icon + fill per chapter (see tokens section). Icon 22×22.
   - Mid VStack gap 5 (fill_container):
     - Top row HStack alignItems center justifyContent space-between full-width:
       - Chapter label: "CHƯƠNG N" Be Vietnam Pro 10/800 fill #7A7166 letterSpacing 1
       - Count: "x/30" Be Vietnam Pro 11/700 fill #0F0F12
     - Chapter title: Be Vietnam Pro 14/800 fill #0F0F12, fixed width fill_container
   - Right Play button: 44×44, cornerRadius 22, fill #FFC233; lucide play 18×18 fill #7A4A00.

   Chapter data (design):
   - Ch1 "Phanh chủ động đô thị" — badge bg #FFE9B0, icon building-2 fill #7A4A00 — 12/30
   - Ch2 "Đường cao tốc & quốc lộ" — badge bg #CFE3FF, icon route fill #143A75 — 8/30
   - Ch3 "Tình huống ban đêm" — badge bg #D9F0DA, icon moon fill #1F5A2A — 10/30
   - Ch4 "Đường nông thôn & đèo" — badge bg #FFD7CF, icon mountain fill #8A2A1F — 4/30

   (Note: these chapter names/counts are illustrative design overrides; the actual data comes from HazardSituation.chapters which has 6 real chapters.)

BELOW THE SCROLL (fixed): AppTabBar with Mô phỏng tab active (appPrimary tint D4714E, fill #D4714E1F on active tab).

OVERLAY 1 — DEPRECATION MODAL (id tqPJG): layoutPosition absolute, 0,0, 393×815, fill #0F0F12B3 (scrim). Vertically centered. Shown on first launch, controlled by a @State flag. Contains Dialog card:
   - cornerRadius 24, fill #FFFFFF, padding 24, gap 14, drop shadow blur 50 offset y 20 #0F0F1240. VStack layout:
     - Icon: 60×60 circle fill #FFF1D6, cornerRadius 100; lucide triangle-alert 30×30 fill #B45309
     - Eyebrow: "THÔNG BÁO QUAN TRỌNG" Be Vietnam Pro 11/800 fill #B45309 letterSpacing 1
     - Title: "Phần thi mô phỏng sắp ngừng" Be Vietnam Pro 18/800 fill #0F0F12 letterSpacing -0.3, center-aligned, fixed width fill_container
     - Body: "Từ ngày 1/7, phần thi mô phỏng (tình huống giao thông) sẽ được loại bỏ khỏi quy trình sát hạch giấy phép lái xe. Bạn vẫn có thể luyện tập để tham khảo." Be Vietnam Pro 13.5/500 fill #525252 lineHeight 1.5 center-aligned, fixed width fill_container
     - Actions VStack gap 6, padding top 8, full width:
       - Primary CTA: "Đã hiểu" height 50, cornerRadius 25, fill appPrimary (#D4714E); text 15/700 fill #FFFFFF — taps dismiss overlay permanently
       - Secondary ghost: "Vẫn vào luyện tập" height 44, center-aligned; text 14/600 fill #7A7166 — taps dismiss overlay and proceeds

OVERLAY 2 — SITUATION JUMP SHEET (id c2lWh): layoutPosition absolute, 0,0, 393×815, fill #0F0F12B3 (scrim). Aligns content to bottom (justifyContent end). Disabled by default (enabled: false — only shown mid-session when user accesses chapter situation list). Sheet panel (Yo3xa): full-width, cornerRadius [28,28,0,0], fill #FBF9F5, padding [12,16,24,16], gap 12, VStack:
   - Grabber: centered, 40×4 rect cornerRadius 2 fill #00000022, paddingBottom 4
   - Head HStack justifyContent space-between, padding [0,4]:
     - T VStack gap 2:
       - "Danh sách tình huống" Be Vietnam Pro 17/800 fill #0F0F12 letterSpacing -0.2
       - "Phiên mô phỏng · 5/10 đã xem" Be Vietnam Pro 12/600 fill #7A7166
     - Close button: 36×36, cornerRadius 18, fill #F0EEE9; lucide x 18×18 fill #0F0F12
   - List VStack gap 8 (GIKdS): 10 situation rows, each full-width, cornerRadius 22, fill #FFFFFFCC, stroke #00000014 1pt, padding 12, HStack alignItems center gap 12:
     - Box 34×34 cornerRadius 10: 3 visual states by result:
       a. Passed (score > 0): fill #E7F5EC, lucide check 18×18 fill #1F7A3D
       b. Failed (score 0): fill #FCE4E2, lucide x 18×18 fill #B3261E
       c. Unseen (not yet played): fill #F0EEE9, lucide play 18×18 fill #8A847C
     - Mid VStack gap 2 (fill_container):
       - Title: "N. [situation name]" Be Vietnam Pro 13/700 fill #0F0F12
       - Sub: "Chương N · MM:SS" Be Vietnam Pro 10.5/600 fill #7A7166
     - Score or chevron (trailing):
       a. Played: score text e.g. "5/5" or "4/5" Be Vietnam Pro 15/700 fill #1E9E50 (pass), "0/5" fill #B3261E (fail)
       b. Unseen: lucide chevron-right 18×18 fill #B5AFA4

**Tokens:** Screen background: 3-stop warm gradient #FBF8F0 → #EEECE6 → #DAD3C4 at 205° — rendered by ScaffoldBackground() / AnimatedBackground()
Card surface: #FFFFFFCC (semi-transparent white) → maps to cardBg with opacity modifier; flat, no shadow, stroke #00000014 1pt
FeatureCard (Focus): fill #0F0F12 → appTextDark (dark card variant, matches FeatureCard component)

Text hierarchy:
  appTextDark (#171717) — primary titles, counts, big numbers
  appTextMedium (#737373) — secondary labels, filter chip inactive, chapter labels, sub-lines
  appTextLight — not directly used; #7A7166 is used instead (slightly warm gray, literal hex)
  #525252 — body text in deprecation dialog (literal hex, no direct token)
  appPrimary (#D4714E) — active tab, CTA button fill, eyebrow not applicable here
  #FFC233 — gold accent, play button bg, feature card eyebrow, progress pill bg adjacent (#FFE9B0 = lighter tint)
  appSuccess (#22C55E) — adjacent; design uses #1E9E50 for passed score text (literal, slightly darker green)
  appError (#EF4444) — adjacent; design uses #B3261E for failed score text (literal)
  appWarning (#F59E0B) — adjacent; design uses #B45309 for deprecation warning (literal amber)
  #E5523F — streak flame icon (literal; close to appPrimary family)

Spacing tokens (literal from design):
  Screen H-padding: 20 pt (Content VStack)
  Status bar H-padding: 28 pt
  Content vertical gap: 16 pt
  Hero card inner gap: 14 pt; inner padding: 12 pt
  Chapter card inner padding: 12 pt; inner gap: 12 pt
  Filter chip gap: 8 pt
  Chapter list gap: 10 pt

Radii:
  Screen frame: r40
  Hero/chapter cards: r22
  Back/search nav buttons: r100 (circle)
  Filter chips: r100
  Progress pill: r100
  Chapter badge: r10
  Chapter play button: r22
  Focus card play button: r26
  Deprecation dialog: r24
  Sheet: [28,28,0,0]
  Situation jump rows: r22
  Situation jump close button: r18
  Grabber bar: r2
  Sheet close pill: r100 (36 diameter)

Chapter badge colors (literal, no tokens):
  Ch1 (urban/city): bg #FFE9B0, icon fill #7A4A00
  Ch2 (highway): bg #CFE3FF, icon fill #143A75
  Ch3 (nighttime): bg #D9F0DA, icon fill #1F5A2A
  Ch4 (rural/mountain): bg #FFD7CF, icon fill #8A2A1F
  (Ch5, Ch6 would need additional palette entries following the same tinted-bg + dark icon pattern)

**Reuse widgets:** FeatureCard(eyebrow:title:tags:[String]:highlightLastTag:icon:action) — used for the Focus Card (GỢI Ý HÔM NAY) dark card; configure with eyebrow='GỢI Ý HÔM NAY', title=situation.title, tags=[chapterLabel, durationString, difficultyLabel], highlightLastTag=false (all pills use #FFFFFF1F fill override), icon=play action, FilterChip — reuse for Tất cả / Chưa làm / Sai / Đã xong filter row; active chip uses fill #0F0F12 + white label, inactive uses #FFFFFFCC + stroke, AppTabBar(items:selection:) — bottom frosted tab bar; Mô phỏng tab (index 3) is active with appPrimary tint, ScaffoldBackground() — provides the warm gradient screen background, TagPill(text:color:) — used inside FeatureCard pills for chapter label, duration, difficulty, StatusBadge(text:color:fontSize:) — could be used for per-situation score badge in jump sheet, CloseButton — for the situation jump overlay close (X) button, .glassCard(cornerRadius:tint:) — apply to Hero progress card and each chapter row card (r22, no tint)

**New widgets:**
- HazardProgressHeroCard(completedCount: Int, totalCount: Int, percentage: Int, streakDays: Int, onContinue: () -> Void) — bespoke flat card (r22, fill #FFFFFFCC, stroke #00000014) showing TIẾN ĐỘ CỦA BẠN eyebrow, large completed count, /total subtitle, percentage pill (#FFE9B0), streak row with flame icon, and dark Continue pill button; not a FeatureCard variant
- HazardChapterRow(chapter: HazardSituation.Chapter, completedCount: Int, totalCount: Int, badgeBg: Color, badgeIconFg: Color, badgeIconName: String, onPlay: () -> Void) — flat card row (r22, #FFFFFFCC, stroke) with colored 44×44 icon badge (r10), chapter number label + count top-row, chapter title, and 44×44 golden play button (r22, fill #FFC233); maps to the Chapters list section
- HazardDeprecationModal(isPresented: Binding<Bool>, onDismiss: () -> Void, onContinue: () -> Void) — full-screen scrim (#0F0F12B3) overlay with a centered white dialog card (r24, shadow); contains warning icon, THÔNG BÁO QUAN TRỌNG eyebrow, title, body, and two action buttons (Đã hiểu / Vẫn vào luyện tập)
- SituationJumpSheet(isPresented: Binding<Bool>, situations: [HazardSituation], scores: [Int: Int], viewedIds: Set<Int>, sessionSubtitle: String, onSelect: (HazardSituation) -> Void) — bottom sheet overlay (scrim + drag-to-dismiss) showing a scrollable list of SituationJumpRow; each row shows state-driven icon box (check/x/play), title+chapter·duration, and trailing score or chevron
- SituationJumpRow(index: Int, situation: HazardSituation, state: SituationRowState, score: Int?, onTap: () -> Void) — single row inside SituationJumpSheet; SituationRowState = .passed / .failed / .unseen; box 34×34 r10, mid VStack, trailing score text or chevron-right icon

**Copy:**
- Mô phỏng
- TIẾN ĐỘ CỦA BẠN
- 34
- / 120 tình huống
- 28%
- 5 ngày liên tiếp
- Tiếp tục
- Tất cả
- Chưa làm
- Sai
- Đã xong
- GỢI Ý HÔM NAY
- Người đi bộ ngang đường
- Chương 3
- 00:22
- Trung bình
- CHƯƠNG 1
- 12/30
- Phanh chủ động đô thị
- CHƯƠNG 2
- 8/30
- Đường cao tốc & quốc lộ
- CHƯƠNG 3
- 10/30
- Tình huống ban đêm
- CHƯƠNG 4
- 4/30
- Đường nông thôn & đèo
- THÔNG BÁO QUAN TRỌNG
- Phần thi mô phỏng sắp ngừng
- Từ ngày 1/7, phần thi mô phỏng (tình huống giao thông) sẽ được loại bỏ khỏi quy trình sát hạch giấy phép lái xe. Bạn vẫn có thể luyện tập để tham khảo.
- Đã hiểu
- Vẫn vào luyện tập
- Danh sách tình huống
- Phiên mô phỏng · 5/10 đã xem
- 1. Người đi bộ băng ngang
- Chương 1 · 00:18
- 5/5
- 2. Xe máy cắt đầu bất ngờ
- Chương 1 · 00:22
- 4/5
- 3. Trẻ em chạy ra lòng đường
- Chương 2 · 00:15
- 4. Ô tô phía trước phanh gấp
- Chương 2 · 00:20
- 0/5
- 5. Xe ngược chiều lấn làn
- Chương 3 · 00:24
- 3/5
- 6. Vượt xe trên đèo hẹp
- Chương 3 · 00:19
- 7. Giao lộ không đèn tín hiệu
- Chương 4 · 00:21
- 8. Mưa lớn tầm nhìn kém
- Chương 4 · 00:26
- 9. Xe tải rẽ phải điểm mù
- Chương 5 · 00:23
- 10. Tình huống ban đêm cao tốc
- Chương 5 · 00:28

**States:** populated (default): all 4 chapter rows visible, progress hero shows real data, focus card shows AI-recommended situation, filter chips default to "Tất cả".
loading: while HazardVideoCache / ProgressStore are not yet ready, show skeleton placeholders in place of chapter rows and hero numbers (use ProgressView or opacity pulse).
empty-filter: when "Chưa làm", "Sai", or "Đã xong" filter yields no chapters with matching situations, show an EmptyState widget ("Không có tình huống nào phù hợp") replacing the Chapters list.
deprecation-modal-visible: HazardDeprecationModal overlaid on full screen; background content is non-interactive. Controlled by a @AppStorage flag to show only once.
situation-jump-sheet-visible: SituationJumpSheet overlaid; triggered when user is mid-session and taps a chapter row or a "jump to situation" affordance; enabled:false in design means it defaults hidden.
all-complete: if completedCount == totalCount (34/120 → 120/120), Hero card percentage pill shows "100%" and streak row may show a completion badge variant.
error (video cache failure): if HazardVideoCache.failedIds is non-empty, individual chapter rows could show a warning indicator (not in this design frame but implied by the broader architecture).

**Interactions:** Back button (MBZSI): pop the navigation stack / dismiss this view.
Search button (M80TfN): push or present QuestionSearchView scoped to hazard situations (or a dedicated HazardSearchView if it exists).
Continue button (zRDmK): resume the in-progress chapter session — navigate to HazardTestView with mode .chapter(lastActiveChapter) or mode .exam.
Filter chip tap: update @State selectedFilter (all / notDone / wrong / done); re-filter the Chapters list; the tapped chip adopts active style (fill #0F0F12, white text), others become inactive.
Focus Card tap (anywhere): launch HazardTestView for the featured situation in practice mode (.practice).
Chapter row Play button (GkafM / SzuBT / R7juJ / hTx6U): launch HazardTestView with mode .chapter(chapterNumber).
Deprecation modal "Đã hiểu" (h0Ed0i): dismiss overlay permanently (set @AppStorage flag), do NOT navigate away.
Deprecation modal "Vẫn vào luyện tập" (gZFgm): dismiss overlay, stay on screen.
Situation Jump Sheet — row tap: dismiss sheet, navigate to that specific situation in the current session.
Situation Jump Sheet — close button (w935YN): dismiss sheet, scrim fades out.
Situation Jump Sheet — swipe down gesture on sheet: dismiss sheet (standard bottom sheet drag-to-dismiss).
Tab bar: standard tab switching via AppTabBar selection binding.

**Notes:** Most likely existing code file: GPLX2026/Features/Hazard/ — this screen does not yet exist as a list view. The existing Hazard files are HazardTestView.swift (the player), HazardResultView.swift, and HazardHistoryDetailView.swift. The new file should be created at GPLX2026/Features/Hazard/HazardListView.swift (or potentially placed under Features/Simulation/ given that SimulationExamView.swift and SimulationHistoryDetailView.swift already exist there for the "mô phỏng" concept — inspect those files to confirm whether hazard and simulation are unified).

The frame name "GPLX · Mô phỏng" and the Wrapper parent "Wrapper · Hazard" confirm this is the Hazard feature's list tab, not the Simulation (sa hình) feature.

HazardSituation.chapters defines 6 real chapters (not 4); the design shows only 4 as illustrative. The implementation should iterate over all 6 chapters and compute per-chapter completion counts from ProgressStore.

The FeatureCard component (EXgYq) uses a dark #0F0F12 fill and accepts an eyebrow (String), title (String), tags ([String]), highlightLastTag (Bool), icon name, and action closure per the existing Core/Common component. The Focus Card overrides Pill3 fill to #FFFFFF1F (not the default gold), so the component must support a tags-all-white-pill mode or the override must be applied externally (consider an additionalContent slot or a tagStyle parameter).

Filter chip HStack should be placed inside a ScrollView(.horizontal, showsIndicators: false) since 4 chips at 14pt horizontal padding each can overflow on smaller widths.

The deprecation modal uses @AppStorage("hazardDeprecationDismissed") Bool to persist dismissal across launches. Default = false (show on first visit).

The Situation Jump Sheet (SituationJumpSheet) is shown during an active exam session when users can jump between situations. Its "enabled: false" in the design means it should be hidden by default and only revealed via a floating or in-session trigger (likely from within HazardTestView, not from this list screen). However since it lives in this frame, implement it here as a sheet triggered by a @State Bool passed down or via environment.

Duration strings ("00:18", "00:22" etc.) in the jump sheet are derived from HazardSituation's perfectEnd value or from a recorded playback duration stored in ProgressStore — implement as a formatted string helper.

All text uses .appSans(size:weight:) — never .system(). The design uses "Be Vietnam Pro" which maps to .appSans in the codebase's font cache.


## Hazard video player (landscape)  (frame BSxMj)

**Purpose:** Full-screen landscape video player for the hazard-perception test (tình huống). The user watches a dashcam-style video clip and must tap a large danger button the instant they perceive a hazard. The screen overlays all controls directly on the video with a frosted/semi-transparent treatment — no navigation bar, no tab bar. It handles the playing state, a post-tap "skip" affordance, and also contains the bottom panel that reveals score feedback after the clip ends.

**Layout:**
Root frame: 852 × 393 pt (landscape iPhone), layout: none (all children absolutely positioned), cornerRadius: 40, background: linear gradient #0C1A28 → #0A1320 → #06090F (top-to-bottom), clip: true.

LAYER 1 — Scene image (absolute, fills frame)
  Rectangle "Scene", 852 × 393, fill: Unsplash photo (road/traffic scene). Serves as the video layer placeholder; in production this is replaced by HazardVideoPlayer.

LAYER 2 — Vignette overlay (absolute, fills frame)
  Rectangle "Vignette", 852 × 393, fill: linear gradient rotation 180°:
    position 0   → #00000080 (heavy dark top)
    position 0.35 → #00000000 (transparent mid-upper)
    position 0.60 → #00000040 (light dark mid-lower)
    position 1.0  → #000000CC (heavy dark bottom)
  This ensures top-bar and bottom-panel text are always readable.

LAYER 3 — Status Bar (absolute, x:0 y:0, 852 × 32 pt)
  HStack, justifyContent: space_between, padding: [0, 28]
  Left: Text "9:41", #FFFFFF, .appSans(size:14, weight:.bold)
  Right: HStack gap 6 — signal icon 16×16 #FFFFFF, wifi icon 16×16 #FFFFFF, battery-full icon 24×16 #FFFFFF

LAYER 4 — Top Bar (absolute, x:24 y:42, width:804)
  HStack, justifyContent: space_between, alignItems: center
  LEFT GROUP (HStack gap:10):
    a) Close button — Circle 36×36, fill #00000059, stroke #FFFFFF1A 1pt, X icon 18×18 #FFFFFF
    b) Situation chip — Capsule, fill #00000066, stroke #FFFFFF1A 1pt, padding [6,12,6,8], HStack gap 8:
       - Number badge — Circle 22×22, fill #FFC233, text "5" .appSans(11,.black) color #3A2400
       - Title text "Ngã tư đông đúc" .appSans(13,.bold) #FFFFFF
       - Separator "·" .appSans(13,.bold) #FFFFFF66
       - Counter "TH 5/10" .appSans(12,.semibold) #FFFFFFB3
  RIGHT GROUP (HStack gap:8):
    a) Favourite button — Circle 36×36, fill #00000059, stroke #FFFFFF1A, heart icon 18×18 #FFFFFF
    b) More button — Circle 36×36, fill #00000059, stroke #FFFFFF1A, ellipsis icon 20×20 #FFFFFF

LAYER 5 — Play/Pause button (absolute, x:386 y:144, 80×80)
  Circle, fill #FFFFFF26, stroke #FFFFFF40 1.5pt
  play icon 30×30 #FFFFFF centered
  (Toggles to pause icon when video is playing; centred on the viewport)

LAYER 6 — Hint card (absolute, x:24 y:118, width:230)
  VStack gap:6, cornerRadius:14, fill #FFFFFF14, stroke #FFFFFF1F 1pt, padding:8
  Header row (HStack gap:8): lightbulb icon 14×14 #FFC233 + Text "NHIỆM VỤ" .appSans(9,.black) #FFC233 letterSpacing:1.5
  Body text: "Tap NGAY khi thấy nguy hiểm tiềm tàng." .appSans(12,.semibold) #FFFFFF lineHeight:1.35 width:fill

LAYER 7 — Bottom Panel (absolute, x:16 y:248, width:820)
  VStack gap:10, cornerRadius:22, fill #00000080, stroke #FFFFFF1A 1pt, padding:8

  ┌─ Sub-layer 7a: Meta Row (HStack justifyContent:space_between, width:fill) ─┐
  LEFT (HStack gap:10):
    - Timestamp capsule: cornerRadius:100, fill #FFFFFF14, padding:[4,10]
        Text "00:08 / 00:25" .appSans(11,.bold) #FFFFFF
    - Title "Xe máy bất ngờ cắt đầu" .appSans(14,.black) #FFFFFF
    - Separator "·" .appSans(14,.bold) #FFFFFF66
    - Attempt counter "Lượt 2/3" .appSans(12,.semibold) #FFFFFFB3
  RIGHT (HStack gap:14):
    - Legend dot + label (HStack gap:5): circle 6×6 #30D158 + "Hoàn hảo" .appSans(10,.semibold) #FFFFFFB3
    - Legend dot + label (HStack gap:5): circle 6×6 #FFD60A + "Hơi muộn" .appSans(10,.semibold) #FFFFFFB3
    - Legend dot + label (HStack gap:5): circle 6×6 #FF3B30 + "Bỏ lỡ"   .appSans(10,.semibold) #FFFFFFB3

  ┌─ Sub-layer 7b: Zones timeline bar (width:fill, height:8, cornerRadius:100) ─┐
    Background track fill #FFFFFF14
    Clipped HStack of coloured segments (left to right):
      - Past segment: width:260, fill #FFFFFF66
      - Perfect segment: width:220, fill #30D158
      - Late segment: width:160, fill #FFD60A
      - Miss segment: width:148, fill #FF3B30
    (Segment widths are proportional to the video duration and the situation's hazard window; the design shows a played-through state.)

  ┌─ Sub-layer 7c: Action Row (HStack gap:10, width:fill, alignItems:center) ─┐
    Five children in order:

    1. "Xem lại" button — 80 wide, VStack gap:3, cornerRadius:14, fill #FFFFFF14, stroke #FFFFFF1A, padding:[10,8]
       rotate-ccw icon 16×16 #FFFFFF + Label "Xem lại" .appSans(10,.bold) #FFFFFFCC

    2. "Chậm 0.5x" button — 80 wide, VStack gap:3, cornerRadius:14, fill #FFFFFF14, stroke #FFFFFF1A, padding:[10,8]
       gauge icon 16×16 #FFFFFF + Label "Chậm 0.5x" .appSans(10,.bold) #FFFFFFCC

    3. "PHÁT HIỆN NGUY HIỂM" danger button — width:fill, cornerRadius:14, fill #FF3B30, padding:[12,20], HStack gap:10 justifyContent:center
       triangle-alert icon 20×20 #FFFFFF
       VStack (gap implicit):
         - "PHÁT HIỆN NGUY HIỂM" .appSans(14,.black) #FFFFFF letterSpacing:0.5
         - "Nhấn ngay khi thấy tình huống" .appSans(10,.semibold) #FFFFFFCC

    4. "Bỏ qua" button — 80 wide, VStack gap:3, cornerRadius:14, fill #FFFFFF14, stroke #FFFFFF1A, padding:[10,8]
       skip-forward icon 16×16 #FFFFFF + Label "Bỏ qua" .appSans(10,.bold) #FFFFFFCC

    5. "Tiếp" button — 80 wide, VStack gap:3, cornerRadius:14, fill #FFFFFF14, stroke #FFFFFF1A, padding:[10,8]
       chevrons-right icon 16×16 #FFFFFF + Label "Tiếp" .appSans(10,.bold) #FFFFFFCC

**Tokens:** Background gradient: #0C1A28 / #0A1320 / #06090F (no token; dark cinematic gradient)
Vignette gradient: #000000 at varying opacities (no token)
Status bar / icons: #FFFFFF (appOnPrimary)
Close / More / Fav buttons bg: #00000059 (black 35% — no direct token, use Color.black.opacity(0.35))
Close / More / Fav buttons stroke: #FFFFFF1A (white 10%)
Situation chip bg: #00000066 (black 40% — Color.black.opacity(0.40))
Situation chip stroke: #FFFFFF1A
Number badge bg: #FFC233 (appWarning-adjacent; literal — no exact token; closest is appWarning #F59E0B but this is brighter gold; use literal)
Number badge text: #3A2400 (dark amber; literal)
Hint card + ghost buttons bg: #FFFFFF14 (white 8% — Color.white.opacity(0.08))
Hint card stroke: #FFFFFF1F (white 12%)
Hint label / task icon: #FFC233 (same gold as badge)
Primary text on video: #FFFFFF (appOnPrimary)
Dim text: #FFFFFFB3 (white 70%)
Separator: #FFFFFF66 (white 40%)
Timestamp capsule bg: #FFFFFF14
Bottom panel bg: #00000080 (black 50% — Color.black.opacity(0.50))
Bottom panel stroke: #FFFFFF1A
Timeline past fill: #FFFFFF66
Timeline perfect fill: #30D158 (appSuccess)
Timeline late fill: #FFD60A (yellow — appWarning-adjacent; use literal)
Timeline miss fill: #FF3B30 (appError-adjacent; use literal #FF3B30 not #EF4444)
Danger button bg: #FF3B30 (literal — distinct from appError)
Ghost action buttons stroke: #FFFFFF1A
Ghost action label text: #FFFFFFCC (white 80%)
Spacing tokens: panel padding 8pt, action row gap 10pt, meta row gap 10pt, bottom panel y-offset 248 from 393 total height

**Reuse widgets:** CircularActionButton — reuse as the Close (X), Favourite, and More icon buttons; set size:36, subtle:true (translucent dark fill + white icon)

**New widgets:**
- HazardLandscapePlayerView — the top-level full-screen landscape container: ZStack with absolute-positioned layers (Scene/video, Vignette, StatusBar, TopBar, HintCard, PlayPauseButton, BottomPanel); takes `situation: HazardSituation`, `playerState: Binding<PlayerState>`, `tapTime: Double?`, `attemptNumber: Int`, `totalAttempts: Int`, and callbacks `onClose`, `onFavourite`, `onMore`, `onDangerTap`, `onReplay`, `onSlowMotion`, `onSkip`, `onNext`.
- HazardTopBar — HStack(justifyContent:.spaceBetween) pinned at y:42; left side has CircularActionButton(close) + HazardSituationChip; right side has CircularActionButton(favourite) + CircularActionButton(more). Props: `situationNumber: Int`, `situationTitle: String`, `current: Int`, `total: Int`, `isFavourited: Bool`.
- HazardSituationChip — Capsule with dark translucent fill (#00000066) + white stroke; shows gold numbered badge + title string + separator + counter string. Props: `number: Int`, `title: String`, `counter: String` (e.g. 'TH 5/10').
- HazardHintCard — Semi-transparent VStack card (cornerRadius:14, fill #FFFFFF14, stroke #FFFFFF1F) showing a gold NHIỆM VỤ header row and body instruction text. Props: `instructionText: String`. Positioned absolute bottom-left of video area (x:24, y:118 relative to frame).
- HazardPlayPauseButton — Circle 80×80, fill #FFFFFF26, stroke #FFFFFF40 1.5pt; toggles between play/pause Lucide icon (30pt white). Props: `isPlaying: Bool`, `action: () -> Void`. Centred on the video.
- HazardBottomPanel — VStack gap:10, cornerRadius:22, fill #00000080, stroke #FFFFFF1A, padding:8; composed of HazardMetaRow + HazardZonesBar + HazardLandscapeActionRow.
- HazardMetaRow — HStack(justifyContent:.spaceBetween); left: timestamp capsule + title + separator + attempt counter; right: three colour-dot legend items (Hoàn hảo/green, Hơi muộn/yellow, Bỏ lỡ/red). Props: `currentTime: Double`, `duration: Double`, `title: String`, `attempt: Int`, `totalAttempts: Int`.
- HazardZonesBar — Clipped HStack of four coloured segments inside a pill (height:8, cornerRadius:100, background #FFFFFF14). Segments widths are computed from `situation.perfectStart`, `situation.perfectEnd`, and `duration`. Props: `situation: HazardSituation`, `currentTime: Double`, `duration: Double`. (Distinct from the existing HazardPlayingBar which shows a live-playing bar; HazardZonesBar is a post-play static zone visualization.)
- HazardLandscapeActionRow — HStack gap:10 with five children: GhostActionButton('Xem lại', icon:rotate-ccw), GhostActionButton('Chậm 0.5x', icon:gauge), HazardLandscapeDangerButton (fill-width #FF3B30), GhostActionButton('Bỏ qua', icon:skip-forward), GhostActionButton('Tiếp', icon:chevrons-right).
- GhostActionButton — 80-pt wide VStack gap:3, cornerRadius:14, fill #FFFFFF14, stroke #FFFFFF1A, padding:[10,8]; shows a Lucide icon (16pt white) above a label (.appSans(10,.bold) #FFFFFFCC). Props: `icon: String` (Lucide name), `label: String`, `action: () -> Void`.
- HazardLandscapeDangerButton — fill-width button, cornerRadius:14, fill #FF3B30, padding:[12,20]; HStack gap:10 centred; left: triangle-alert icon 20pt white; right: VStack with 'PHÁT HIỆN NGUY HIỂM' (.appSans(14,.black) white letterSpacing:0.5) and subtitle (.appSans(10,.semibold) #FFFFFFCC). After tap: transitions to a 'Đã phát hiện!' confirmed state (icon + text change, fill shifts to appSuccess-tint). Props: `hasTapped: Bool`, `action: () -> Void`. (This is the landscape-specific layout variant of the existing HazardDangerButton which uses a different aspect ratio for portrait.)

**Copy:**
- 9:41
- Ngã tư đông đúc
- TH 5/10
- NHIỆM VỤ
- Tap NGAY khi thấy nguy hiểm tiềm tàng.
- 00:08 / 00:25
- Xe máy bất ngờ cắt đầu
- Lượt 2/3
- Hoàn hảo
- Hơi muộn
- Bỏ lỡ
- Xem lại
- Chậm 0.5x
- PHÁT HIỆN NGUY HIỂM
- Nhấn ngay khi thấy tình huống
- Bỏ qua
- Tiếp
- Đã phát hiện!
- Không thể tải video
- Kiểm tra kết nối mạng
- Thử lại
- Đang tải...
- Thoát bài thi?
- Kết quả sẽ không được lưu.
- Tiếp tục
- Thoát

**States:** LOADING: HazardVideoPlayer shows ProgressView (tint: appPrimary) centred over the video area; BottomPanel MetaRow shows "--:-- / --:--" for timestamp; ZonesBar shows empty grey pill; danger button is disabled (opacity 0.5, fill #FF3B30 at 40%).

COUNTDOWN (first 3 seconds of video): Danger button disabled; label shows "Chuẩn bị... N" (counting down from 3); fill #FF3B30 at 40%.

PLAYING (active, no tap yet): Danger button fully enabled; fill #FF3B30 at 100%; pulsing scale animation; ZonesBar animates rightward as currentTime advances; timestamp capsule updates in real time.

TAPPED (tap registered, video still playing): Danger button switches to "Đã phát hiện!" with checkmark icon and appSuccess tint; "Bỏ qua" ghost button reveals (animated slide-up); ZonesBar freezes at tap position and colours update to show which zone was hit; white flash overlay on video for 200 ms.

FINISHED (video ended): Bottom panel action row shows full five-button row in static state; ZonesBar shows final zone distribution; score feedback visible in meta row legend; "Tiếp" becomes active navigation.

ERROR: Video area shows error card overlay (exclamationmark.triangle.fill icon + "Không thể tải video" + "Kiểm tra kết nối mạng" + "Thử lại" capsule button) using scaffold background. Bottom panel danger button is disabled.

BUFFERING: ProgressView spinner centred over video; bottom panel danger button disabled.

LAST SITUATION: "Tiếp" ghost button label changes to "Kết quả" with checkmark icon, advancing to HazardResultView.

FAVOURITED: Heart icon in TopBar fills (heart.fill) to indicate saved state.

**Interactions:** CLOSE (X button in TopBar left): shows exit-confirmation alert ("Thoát bài thi?" / "Kết quả sẽ không được lưu." / destructive "Thoát" + cancel "Tiếp tục"); on confirm calls dismiss().

SITUATION CHIP: tappable only if used in practice mode — could navigate to a situation detail; in exam mode non-interactive.

FAVOURITE button (heart): toggles isFavourited state; bookmarks the current HazardSituation via ProgressStore; icon animates heart → heart.fill with spring bounce.

MORE button (ellipsis): presents a sheet or action menu (report issue / share etc.; behavior TBD by product).

PLAY/PAUSE button (centre of video): toggles AVPlayer play/pause; icon transitions between play and pause.

TAP ANYWHERE ON VIDEO AREA: primary tap-to-detect gesture; calls handleTap(at:) only when countdown has elapsed and user hasn't already tapped; triggers white flash overlay + haptic impact rigid.

PHÁT HIỆN NGUY HIỂM danger button: same as video tap; disabled during countdown and after first tap.

XEM LẠI ghost button: calls retryCurrent() — clears tapTime, resets PlayerState, increments restartToken, decrements attempt counter; only shown in practice mode.

CHẬM 0.5X ghost button: sets AVPlayer rate to 0.5; button label toggles to "Tốc độ bình thường" and icon changes to gauge with active tint when slowmo is active.

BỎ QUA ghost button: calls skipVideo() (sets playerState.isFinished = true); only meaningfully actionable after first tap (design always shows it but code reveals it after tap).

TIẾP ghost button: calls advanceOrFinish(); on last situation navigates via navigationDestination to HazardResultView.

ORIENTATION: view is shown only when GeometryReader detects landscape (width > height) OR sizeClass == .regular (iPad); portrait triggers the separate portrait layout already in HazardTestView. OrientationManager.shared.allowedOrientations = .allButUpsideDown is set on appear; reset to locked on disappear.

**Notes:** Most likely existing file: GPLX2026/Features/Hazard/HazardTestView.swift. The design frame "GPLX · Mô phỏng · Player" (BSxMj) corresponds directly to the `landscapeLayout(situation:hasTapped:geo:)` method inside HazardTestView.

Key delta between design and current code:

1. BOTTOM PANEL LAYOUT: The design consolidates all landscape controls into a single bottom-anchored panel (HazardBottomPanel) that includes MetaRow + ZonesBar + ActionRow as a dark translucent card (fill #00000080). The current code distributes these across a separate right-side VStack panel. A refactor is needed to align with the design.

2. ZONES BAR: The design shows a static coloured segment bar (past/perfect/late/miss) inside the bottom panel, distinct from the live HazardPlayingBar used during playback. This HazardZonesBar is a new widget.

3. ACTION ROW: The design places all five secondary actions (Xem lại, Chậm 0.5x, Danger button, Bỏ qua, Tiếp) in a single horizontal row within the bottom panel. The current code surfaces these in a vertical VStack. The landscape action row is a new widget with a distinct layout.

4. GHOST ACTION BUTTONS: The design uses a consistent vertical icon-above-label ghost button (GhostActionButton) for the four flanking actions. The current code uses AppButton for secondary actions. New widget needed.

5. HINT CARD: The design shows a "NHIỆM VỤ" hint card overlaid on the top-left of the video (y:118 from top). The current code does not include this overlay. New widget.

6. NUMBER BADGE IN CHIP: The gold circle badge showing the situation number uses color #FFC233 (not appWarning #F59E0B). Use literal Color(hex: "FFC233") or define a local constant.

7. TIMELINE LEGEND IN META ROW: The right side of the meta row shows three dot-legend items inline. These appear in the "playing" state (the design captures the state mid-play), suggesting they are always visible so the user can interpret the ZonesBar in real time.

8. PLAY/PAUSE BUTTON: Centred on video at 80×80; frosted circle. Currently the view has no visible play/pause toggle overlay — the player auto-starts. If added, it should auto-hide after 2s of inactivity (standard video player UX).

9. The status bar layer in the design is decorative (the real iOS status bar is shown natively in landscape fullscreen); do not render a custom status bar in SwiftUI — rely on the system status bar with preferredColorScheme(.dark) or .statusBarHidden(isCurrentlyLandscape) if a fully immersive experience is desired.

10. Font: all text in the design uses "Be Vietnam Pro" which maps to .appSans in the codebase — never use .custom("Be Vietnam Pro", ...) directly.


## Hazard result  (frame p1cOS)

**Purpose:** Shows the per-situation result immediately after a hazard-perception (tình huống) simulation session. Displays: a pass/score hero for the current situation, a segmented session-progress bar for the full session (e.g. 5/10 done), a "situation card" naming the hazard just handled, a timeline card showing where in the video the user tapped vs the scoring window, and two primary CTAs (review / next situation) plus a ghost link back to Home.

**Layout:**
OVERALL FRAME: 393 × 852 pt, cornerRadius 40, clip true. Background: linear gradient top-to-bottom — #DFF1E6 (pos 0) → #EBECEF (pos 0.55) → #E6E4DF (pos 1.0), rotation 180°. Root layout: VStack spacing 0 (layout:vertical, no explicit gap at root; inner Content drives the gap).

─────────────────────────────────────────
A. STATUS BAR ("y3MN0C")
   HStack justifyContent:space_between, height 62, horizontalPadding 28.
   Left: Text "9:41" — Be Vietnam Pro 16/600, fill #171717.
   Right: HStack gap 7 — signal(18×18), wifi(18×18), battery-full(24×18), all fill #171717.

B. NAV BAR ("WYLaV")
   HStack justifyContent:space_between, padding [top:0, trailing:20, bottom:8, leading:20], width fill.
   Left: Back button "Z865gl" — circular 38×38, cornerRadius 100, fill #FFFFFFCC, stroke #00000014 1pt inner; contains chevron-left 20×20 fill #0F0F12.
   Center: Text "Kết quả mô phỏng" — Be Vietnam Pro 17/800 #0F0F12, textAlign center, fixed-width fill.
   Right: Spacer frame 38×38 (balances the back button, no content).

C. CONTENT VStack ("ASiuz")
   layout:vertical, gap 14, padding [top:0, trailing:20, bottom:20, leading:20], height fill_container, width fill.

   C1. SCORE HERO GROUP ("hkG90") — VStack gap 8, width fill
   
     C1a. RESULT HERO CARD ("m8hw6i") — reuse/adapt ResultHero component
       cornerRadius 22, fill #E7F5EC, padding 16, gap 14, width fill.
       Inner: HStack justifyContent:space_between ("uyMZb"):
         LEFT column ("yND7L") VStack gap 8:
           Badge row ("r7pd9H"): HStack gap 5, cornerRadius 100, fill #22C55E, padding [5,12,5,10].
             • Icon thumbs-up 14×14 fill #FFFFFF (Lucide).
             • Text "TỐT" — Be Vietnam Pro 12/800 #FFFFFF letterSpacing 1.
           Heading VStack ("hy0fc") gap 2:
             • Title "Tốt lắm!" — Be Vietnam Pro 24/800 #171717 letterSpacing -0.5.
             • Sub "Tình huống 5/10" — Be Vietnam Pro 12.5/500 #5E7A66.
         RIGHT column ("QTOV2") VStack alignItems:end:
           • Large score "4/5" — Be Vietnam Pro 48/700 #1E9E50, lineHeight 1.
           • Label "điểm phản xạ" — Be Vietnam Pro 12/500 #737373.
   
     C1b. SESSION PROGRESS CARD ("spitO")
       cornerRadius 22, fill #FFFFFF, stroke #0000000D 1pt, padding 12, gap 10, layout:vertical, width fill.
       Row 1 — Head HStack ("yVUmO") justifyContent:space_between, width fill:
         • Label "TIẾN ĐỘ PHIÊN" — Be Vietnam Pro 10/800 #7A7166 letterSpacing 1.2.
         • Right cluster HStack alignItems:end gap 4 ("MHiH0"):
             – Text "38/50" — Be Vietnam Pro 18/700 #0F0F12.
             – Text "điểm" — Be Vietnam Pro 12/500 #7A7166.
       Row 2 — Segments HStack ("G9hTQ") gap 4, width fill:
         10 pill-shaped segments (S1–S10), each height 8, cornerRadius 3, fill_container width.
         • Completed (S1–S5, count = completedCount): fill #30D158 (appSuccess).
         • Remaining (S6–S10): fill #E6E3DD (near-appDivider, a warm light gray).
       Row 3 — Foot HStack ("Pu1NM") justifyContent:space_between, width fill:
         • Left: "Đã hoàn thành 5/10 tình huống" — Be Vietnam Pro 11.5/600 #7A7166.
         • Right: "50%" — Be Vietnam Pro 14/700 #1E9E50.
   
     C1c. SITUATION CARD ("Ffe51")
       cornerRadius 22, fill #FFFFFF, stroke #0000000D 1pt, padding 12, gap 8, layout:vertical, width fill.
       Head HStack ("z6mdjW") justifyContent:space_between, padding [bottom:2], width fill:
         • Title "Tình huống vừa xử lý" — Be Vietnam Pro 14/800 #0F0F12.
         • Detail HStack ("TSH2S") alignItems:center gap 3:
             – Text "Xem lại" — Be Vietnam Pro 12/700 #7A7166.
             – Icon chevron-right 14×14 fill #7A7166.
       Divider ("MRgwU") — Rectangle height 1, fill #00000010, width fill.
       Situation row HStack ("Mt1n2") alignItems:center gap 10, padding [top:2, bottom:2], width fill:
         • Number badge ("nObJP") — frame 30×30, cornerRadius 10, fill #FFC233, center-aligned.
             Text "5" — Be Vietnam Pro 15/700 #7A4A00.
         • Text block VStack ("nov0s") gap 1, layout:vertical, width fill:
             – Title "Xe máy bất ngờ cắt đầu" — Be Vietnam Pro 14/800 #0F0F12.
             – Subtitle "Ngã tư đông đúc · Tình huống 5/10" — Be Vietnam Pro 11.5/600 #7A7166.
   
     C1d. TIMELINE CARD ("QloOe")
       cornerRadius 22, fill #FFFFFFCC (semi-transparent white), stroke #00000014 1pt, padding 12, gap 12, layout:vertical, width fill.
       Head HStack ("N9XOW") justifyContent:space_between, width fill:
         • Label "THỜI ĐIỂM BẠN BẤM" — Be Vietnam Pro 10/800 #7A7166 letterSpacing 1.2.
         • Value "Giây 9.2" — Be Vietnam Pro 15/700 #0F0F12.
       Timeline bar HStack ("x0wEz") width fill, height 14 visual:
         Segments laid out as a color-coded horizontal bar (no gap between segments):
         1. "Som" (Sớm/Too early): cornerRadius [7,0,0,7], fill #C9C4BC, height 14, width proportional.
         2. "Perfect" (Hoàn hảo): fill #30D158, height 14, width proportional.
         3. "Tot1" (Tốt left side): fill #FFD60A, height 14.
         4. "Marker" (tap position): cornerRadius 2, fill #0F0F12, height 26 (taller than bar, centered), width 4 — indicates where user tapped.
         5. "Tot2" (Tốt right side): fill #FFD60A, height 14.
         6. "Miss" (Bỏ lỡ): cornerRadius [0,7,7,0], fill #FF3B30, height 14.
         The bar extends full width; marker overlaps via ZStack/offset.
       Legend HStack ("S8BE68") gap 14, width fill:
         Four legend items (dot + label), each HStack gap 5 alignItems:center:
         • "Sớm" — dot 8×8 ellipse fill #C9C4BC; text Be Vietnam Pro 11/600 #7A7166.
         • "Hoàn hảo" — dot 8×8 ellipse fill #30D158; text Be Vietnam Pro 11/600 #7A7166.
         • "Tốt" — dot 8×8 ellipse fill #FFD60A; text Be Vietnam Pro 11/600 #7A7166.
         • "Bỏ lỡ" — dot 8×8 ellipse fill #FF3B30; text Be Vietnam Pro 11/600 #7A7166.

   C2. SPACER ("sVSn9") — fill_container height, pushes actions to bottom.

   C3. ACTIONS GROUP ("EgWGE") — VStack (no layout key = HStack in design? — design shows gap:12, width fill; children are both fill_container — render as VStack gap 12 since both are fill_container width):
     Button 1 ("bDwwI") — Secondary glass CTA, height 52, width fill, cornerRadius 26.
       Uses component/CTA · Glass Secondary style: fill #FFFFFF73 + gradient (#FFFFFF80→#FFFFFF1A), backgroundBlur radius 16, shadow outer.
       Icon: rotate-ccw 16×16 fill #C75F3C (appPrimary).
       Label: "Xem lại" — Be Vietnam Pro 15/700 #C75F3C.
     Button 2 ("lY3Cv") — Primary glass CTA, height 52, width fill, cornerRadius 26.
       Uses component/CTA · Glass Primary style: fill gradient #C75F3C (solid at bottom), stroke #FFFFFF80 1pt inner.
       Label: "Tình huống tiếp" — Be Vietnam Pro 15/700 #FFFFFF.
       Trailing icon: arrow-right 16×16 fill #FFFFFF.

   C4. HOME LINK ("Qvw2X") — HStack justifyContent:center, gap 6, height 44, width fill.
       Icon: house 16×16 fill #7A7166.
       Text: "Về trang chủ" — Be Vietnam Pro 14/600 #7A7166.

**Tokens:** Background gradient: linear 180° — #DFF1E6 (pos 0) → #EBECEF (pos 0.55) → #E6E4DF (pos 1.0). No token; render as LinearGradient in ScaffoldBackground or as a ZStack backdrop.
Nav chevron fill: #0F0F12 (appTextDark).
Nav back button bg: #FFFFFFCC (white 80% opacity).
Nav title: #0F0F12 = appTextDark.
ResultHero card bg: #E7F5EC (green-tinted surface; closest to appSuccess with low opacity, no direct token — use Color(hex:"E7F5EC")).
Badge fill: #22C55E = appSuccess.
Score large: #1E9E50 (darker green, no token — literal hex).
Sub text #5E7A66 (muted green, no token — literal hex).
Session card bg: #FFFFFF = white / cardBg.
Segment completed: #30D158 (appSuccess on iOS / system green; same hex — use Color(hex:"30D158") or .appSuccess).
Segment remaining: #E6E3DD (warm light gray, no token — literal hex, close to appDivider).
Progress % text: #1E9E50 (same as score green).
Section labels: #7A7166 (warm mid-gray, no token — literal hex, close to appTextMedium #737373).
Situation number badge bg: #FFC233 (amber/gold, no token — literal hex).
Situation badge text: #7A4A00 (dark amber, no token — literal hex).
Situation title: #0F0F12 = appTextDark.
Timeline card bg: #FFFFFFCC (glass white).
Timeline card stroke: #00000014.
Timeline bar — Sớm: #C9C4BC; Hoàn hảo: #30D158; Tốt: #FFD60A; Bỏ lỡ: #FF3B30 = appError.
Tap marker: #0F0F12 = appTextDark.
CTA Primary fill: gradient #C75F3C solid (= appPrimary terracotta).
CTA Secondary: frosted glass white with appPrimary icon/label.
Home link icon+text: #7A7166.
Fonts: Be Vietnam Pro throughout = .appSans. No .appSerif or .appMono on this screen.
Spacing tokens: content padding H=20, card internal padding=12, card gap=8, main VStack gap=14, segment gap=4.

**Reuse widgets:** ResultHero — adapt for hazard variant (badge with thumbs-up icon + 'TỐT'/'KÉM' label, large score 'N/5', subtitle 'Tình huống X/Y', bg #E7F5EC), StatusBadge — used inside ResultHero for the pass/fail badge pill, ScoreRow — already in HazardResultView for score breakdowns (not on this screen but in sibling view), SectionTitle — not needed on this screen, AppButton — not used; CTAs are the glass CTA components, ScaffoldBackground — not used directly; background is a custom gradient, not the standard scaffold gradient

**New widgets:**
- HazardSessionProgressCard(completedCount: Int, totalCount: Int, sessionScore: Int, sessionMaxScore: Int) — white flat card (cornerRadius 22, fill .white, stroke #0000000D): row 1 = label 'TIẾN ĐỘ PHIÊN' + score cluster; row 2 = 10 segmented pill bar (HStack of fixed-height rounded rectangles, completed = #30D158, remaining = #E6E3DD, gap 4); row 3 = completion text + percentage. Animates filled segments on appear.
- HazardSituationSummaryCard(index: Int, situationTitle: String, situationSubtitle: String, onReview: () -> Void) — white flat card (cornerRadius 22, fill .white, stroke #0000000D): header row with title 'Tình huống vừa xử lý' + tappable 'Xem lại ›' detail link; divider; situation row with amber number badge (30×30, cornerRadius 10, fill #FFC233, text dark amber) + VStack of title/subtitle.
- HazardTimelineCard(tapTime: Double?, perfectStart: Double, perfectEnd: Double, videoDuration: Double) — semi-transparent glass card (cornerRadius 22, fill #FFFFFFCC, stroke #00000014): header row 'THỜI ĐIỂM BẠN BẤM' + formatted tap time 'Giây X.X'; color-coded segmented bar showing Sớm/Hoàn hảo/Tốt/Bỏ lỡ zones with a vertical marker at tap position; legend row with four dot+label pairs. Bar segments are proportional to timing windows. Marker is taller (26pt) than bar (14pt), centered vertically.
- GlassCTAButton(label: String, icon: String?, style: GlassCTAStyle, action: () -> Void) — encapsulates both Primary (solid appPrimary gradient fill, white text/icon, cornerRadius 26, height 52) and Secondary (frosted glass fill, appPrimary text/icon, backgroundBlur 16, outer shadow, cornerRadius 26, height 52) variants. Matches existing component/CTA · Glass Primary and component/CTA · Glass Secondary reusable components in design.

**Copy:**
- Kết quả mô phỏng
- TỐT
- Tốt lắm!
- Tình huống 5/10
- 4/5
- điểm phản xạ
- TIẾN ĐỘ PHIÊN
- 38/50
- điểm
- Đã hoàn thành 5/10 tình huống
- 50%
- Tình huống vừa xử lý
- Xem lại
- 5
- Xe máy bất ngờ cắt đầu
- Ngã tư đông đúc · Tình huống 5/10
- THỜI ĐIỂM BẠN BẤM
- Giây 9.2
- Sớm
- Hoàn hảo
- Tốt
- Bỏ lỡ
- Tình huống tiếp
- Về trang chủ

**States:** populated (normal post-situation state — all four cards shown with real data); last-situation (isLastSituation == true → replace 'Tình huống tiếp' button with 'Xem kết quả phiên' or 'Hoàn thành'; hide session progress percentage if at 100%); missed (tapTime == nil → Timeline card header shows 'Bỏ lỡ' or 'Không bấm', marker absent, whole bar shaded red-dominant); perfect-tap (score == 5 → badge reads 'HOÀN HẢO' + star icon, ResultHero bg could pulse green); poor-tap (score == 0 or 1 → badge reads 'CHƯA ĐẠT' + x icon, fill #FEE2E2 on ResultHero); session-score-pass/fail variant of session progress (session total >= passScore → progress score text in #1E9E50; below pass → #EF4444 = appError).

**Interactions:** Back button (Z865gl): dismisses this screen / pops to hazard test view. 'Xem lại' CTA (bDwwI): navigates to video replay for the current situation (HazardTestView in review mode or HazardHistoryDetailView). 'Tình huống tiếp' CTA (lY3Cv): advances to the next situation index in the session (calls back to HazardTestView/session coordinator). 'Xem lại' detail link in Situation Card (TSH2S): secondary tap target — also navigates to replay (same destination as primary Xem lại CTA). 'Về trang chủ' ghost link (Qvw2X): pops to root (calls popToRoot environment action). Timeline tap marker is informational only (no tap interaction). Session progress bar segments are read-only display.

**Notes:** Most likely existing file: GPLX2026/Features/Hazard/HazardResultView.swift. The current HazardResultView.swift is the full-session aggregate result screen (shows score distribution chart, review rows, etc.) — it is NOT this design. This design is a per-situation inter-session result shown between each hazard video, similar to an exam question result card. The design's name 'GPLX · Mô phỏng · Kết quả' and navbar title 'Kết quả mô phỏng' confirm this is the simulation (mô phỏng) flow, distinct from the hazard session summary. This screen would be a new view, e.g. HazardSituationResultView.swift, placed in GPLX2026/Features/Hazard/. It takes: situationIndex, situation (HazardSituation), tapTime (Double?), score (Int, 0–5), sessionCompletedCount, sessionTotalCount, sessionScore, sessionMaxScore, and callbacks onNext / onReview / onHome. The ResultHero component (Bs1tH) already exists as a reusable component but is designed for exam pass/fail — on this screen it is used with hazard-specific content (badge icon thumbs-up instead of check, score 'N/5' instead of '%', cornerRadius 22 vs 10 on the component default). Implement as a HazardResultHeroCard local view rather than forcing the existing ResultHero to accept too many variants. The timeline bar (HazardTimelineCard) replaces the existing TimingBar private struct already in HazardResultView.swift — the new standalone card widget is a promoted version of that pattern. Background gradient (#DFF1E6 → #EBECEF → #E6E4DF) is a unique mint-to-neutral gradient for this screen, distinct from the standard ScaffoldBackground; implement as a ZStack background layer using LinearGradient ignoring safe area. The GlassCTAButton maps to the existing component/CTA · Glass Primary and component/CTA · Glass Secondary design-system components — check if these already exist in GPLX2026/Core/Common/ before building new ones. The Actions area (EgWGE) in the design has both buttons as fill_container width in a VStack gap 12 — NOT side-by-side HStack. The existing HazardResultView uses an HStack for its two buttons, but this design stacks them vertically.
