# On thi GPLX 2026

App on thi ly thuyet giay phep lai xe hang B1/B2 theo bo de moi nhat 2026.

## Tinh nang

- **600 cau hoi** theo bo de thi that cua Bo GTVT
- **Thi thu** — 35 cau, 25 phut, cham diem tu dong
- **Mo phong tinh huong** — 20 tinh huong co hinh anh, 60 giay moi cau
- **Hoc theo chu de** — 5 chu de chinh (Quy dinh, Ky thuat, Cau tao, Bien bao, Sa hinh)
- **Cau diem liet** — tap trung on cac cau sai la truot
- **Tra cuu** — bien bao giao thong, toc do, khoang cach, muc phat
- **Theo doi tien do** — do chinh xac theo chu de, chuoi ngay hoc, thanh tich
- **20 de thi co dinh** giong de thi that
- **Danh dau & cau sai** — luu lai de on tap
- **Flashcard** — hoc nhanh bang the ghi nho
- **Dark mode** — ho tro sang/toi/theo he thong

## Yeu cau

- iOS 18.0+
- Xcode 16.0+
- Swift 6.0

## Cai dat

```bash
# Clone repo
git clone https://github.com/kienmai160598/On-thi-GPLX.git
cd On-thi-GPLX

# Mo bang Xcode
open GPLX2026.xcodeproj

# Hoac build + cai len iPhone bang Makefile
make install
```

### Lenh Makefile

| Lenh | Mo ta |
|------|-------|
| `make install` | Build va cai len iPhone dang ket noi |
| `make build` | Archive va export .ipa |
| `make clean` | Xoa build artifacts |
| `make device` | Hien thi thiet bi dang ket noi |

## Cau truc du an

```
GPLX2026/
├── Core/
│   ├── Common/         # UI components dung chung (AppButton, StatusBadge, ...)
│   ├── Models/         # Data models (Question, Topic, ExamResult, ...)
│   ├── Storage/        # QuestionStore, ProgressStore (UserDefaults)
│   └── Theme/          # Mau sac, modifier, glass card
├── Features/
│   ├── Home/           # Trang chu, tab thi thu, tab mo phong, diem liet
│   ├── Learn/          # Man hinh lam cau hoi, meo ghi nho
│   ├── Exam/           # Thi thu (MockExamView, ket qua, lich su)
│   ├── Simulation/     # Mo phong tinh huong
│   ├── Topics/         # Hoc theo chu de, chu de yeu
│   ├── Badges/         # Thanh tich
│   ├── Bookmarks/      # Danh dau, cau sai
│   ├── Flashcard/      # Flashcard
│   ├── Reference/      # Tra cuu bien bao, toc do
│   ├── Settings/       # Cai dat (theme, mau, xoa du lieu)
│   └── Onboarding/     # Man hinh gioi thieu
└── Resources/
    └── Data/           # questions.json, memory_tips.json
```

## Tech stack

- **SwiftUI** — 100% declarative UI
- **@Observable** macro (Observation framework)
- **UserDefaults** — luu tien do hoc tap offline
- **Liquid Glass** — ho tro iOS 26 glass effect (fallback material cho iOS 18)
- **XcodeGen** — tao project tu `project.yml` (tuy chon)

## Giay phep

MIT License — xem file [LICENSE](LICENSE).
