-- iScanJai database schema (the app creates this automatically)
CREATE TABLE IF NOT EXISTS payments(
  id           TEXT PRIMARY KEY,
  date         TEXT NOT NULL,              -- YYYY-MM-DD
  time         TEXT NOT NULL DEFAULT '',   -- HH:MM
  merchant     TEXT NOT NULL,
  amount_minor INTEGER NOT NULL,           -- 202.00 THB is stored as 20200
  currency     TEXT NOT NULL DEFAULT 'THB',
  category     TEXT NOT NULL DEFAULT 'other',
  note         TEXT NOT NULL DEFAULT '',
  ref          TEXT NOT NULL DEFAULT '',
  created_at   TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS payments_date ON payments(date);
