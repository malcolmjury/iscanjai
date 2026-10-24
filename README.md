# iScanJai

A one-page spending tracker that reads bank slips and receipts. You choose one or more screenshots (up to 30 at once), for example a Krungthai, KBank or SCB transfer slip or a Shopee receipt. iScanJai pulls out the payee, amount, date, time, reference and note, and suggests a category. You check each slip's details and save it, then move on to the next. The page shows a monthly total, a breakdown by category, and a list of payments by day.

It is a single `index.html` with no build step. Tesseract.js, sql.js and the fonts load from CDNs, so it needs an internet connection when it opens.

## Run it

- **Locally:** open `index.html` in a browser.
- **GitHub Pages:** push this repo, then go to **Settings → Pages**, choose **Deploy from a branch**, and select `main` with the folder `/ (root)`. The site appears at `https://<your-username>.github.io/<repo-name>/`.

## Reading slips

There are two ways to read a slip. Choose one in **Settings**.

### Free OCR (default)

[Tesseract.js](https://tesseract.projectnaptha.com/) reads the text from the image in your browser, in English and Thai. Simple pattern rules in `parseSlipText()` then pick out the details:

| Field | How it's found |
|---|---|
| Amount | A number with two decimals on a line labelled Amount, Total, จำนวนเงิน or ยอดรวม. Otherwise the largest amount marked THB, ฿ or บาท. Fees, change and VAT lines are skipped. |
| Paid to | "Payment to …" or the line after "To". Thai transfer slips list two names with masked account numbers, so the second one is used. |
| Date and time | "22 Oct 2026 - 14:31", "22 ต.ค. 69 14:31", 22/10/2026 or 2026-10-22. Buddhist-era years are converted. |
| Reference | The value after Ref. no., Transaction ID or เลขที่รายการ. |
| Note | The value after Note, Memo or บันทึกช่วยจำ. |
| Category | Keywords in the note, payee and text, such as ปลา → Food or Grab → Transport. |

It is free, and your slips never leave your device. The first slip downloads about 10 MB of recognition data from jsDelivr, which the browser then caches. It works best on clean bank-app screenshots. Fields it couldn't find are highlighted, and **Text found on the slip** shows what OCR read, so you can copy from it.

To support another slip layout, add its labels to the patterns in `parseSlipText()`. To add category keywords, edit `CAT_WORDS`.

### Claude (optional)

Claude copes better with paper receipts and new layouts, and translates Thai notes. It needs an Anthropic API key:

1. Create a key at <https://console.anthropic.com/>.
2. In **Settings**, choose **Claude**, paste the key and tap **Save**.

The key is stored in your browser's `localStorage` and sent only to `api.anthropic.com`. Images are shrunk to 1600px first. Each slip costs about half a US cent with the default `MODEL` (`claude-sonnet-5-5`). Setting it to `claude-haiku-5-5` costs about 1/20 as much.

> Don't put your key into the code or commit it.

You can always add a payment with **Enter by hand**.

## Your data

Payments are stored in a **SQLite** database that runs in your browser using [sql.js](https://sql.js.org/), a WebAssembly build of SQLite. The database file is kept in the browser's IndexedDB and saved after every change. The SQLite engine loads from jsDelivr, so the app needs an internet connection when it opens.

- **Download database** saves `iscanjai-<date>.sqlite`. You can open it in [DB Browser for SQLite](https://sqlitebrowser.org/), the `sqlite3` command line, Python and other tools.
- **Open database** loads a `.sqlite` file downloaded from the app, for example to move your data to another device. It replaces what is in the browser, after asking you to confirm.
- **Export CSV** saves a spreadsheet-friendly copy.

The table layout is in [`schema.sql`](schema.sql). Amounts are stored as whole minor units in `amount_minor`, so 202.00 THB is stored as `20200`. This keeps totals exact. For example:

```sql
SELECT substr(date,1,7) AS month, category, SUM(amount_minor)/100.0 AS total
FROM payments WHERE currency='THB'
GROUP BY month, category ORDER BY month DESC, total DESC;
```

Clearing the browser's site data deletes the database, so download it now and then as a backup. Payments saved by earlier versions of the app (in `localStorage`) are moved into SQLite automatically.

When the page runs as a Claude artifact on claude.ai, it uses Claude's built-in slip reading and synced storage instead, and the API key setting and database buttons are hidden.

## Customising

- **Categories:** edit the `CATS` array and the matching `--c-*` colour tokens in the CSS.
- **Extraction rules:** edit `PROMPT`, for example to handle another bank's slip layout or your own categories.
- **Colours and fonts:** all colours are CSS custom properties at the top of the `<style>` block, with separate light and dark values.
