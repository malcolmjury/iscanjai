# iScanJai

A one-page spending tracker that reads bank slips and receipts. You choose a screenshot, for example a Krungthai, KBank or SCB transfer slip or a Shopee receipt. Claude pulls out the payee, amount, date, time, reference and note, and suggests a category. You check the details and save. The page shows a monthly total, a breakdown by category, and a list of payments by day.

It is a single `index.html` with no build step and no dependencies. The fonts load from Google Fonts.

## Run it

- **Locally:** open `index.html` in a browser.
- **GitHub Pages:** push this repo, then go to **Settings → Pages**, choose **Deploy from a branch**, and select `main` with the folder `/ (root)`. The site appears at `https://<your-username>.github.io/<repo-name>/`.

## Reading slips

Slip reading uses Claude's vision through the Anthropic API.

1. Create an API key at <https://console.anthropic.com/>.
2. In the app, tap **Settings**, paste the key, and tap **Save key**.

The key is stored in your browser's `localStorage` and sent only to `api.anthropic.com`. Requests go straight from your browser; the app has no server. Images are shrunk to 1600px before they are sent. The model is set by `MODEL` in `index.html` (default `claude-sonnet-5-5`).

> Don't put your key into the code or commit it. Anyone who can use the browser where it is saved can see it, so only save it on your own devices.

Without a key you can still add payments with **Enter by hand**.

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
