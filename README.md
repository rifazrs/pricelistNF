# Excel Price App

A full-stack VS Code project using:

- Frontend: React + Vite + HTML/CSS/JavaScript
- Backend: Node.js + Express
- Excel handling: ExcelJS
- Storage: SQLite by default, with secure MySQL/Amazon RDS support

## What this app does

- Upload your Excel file.
- Read the `INPUT DATA` and `CNF` sheets.
- Show material selling price, calculated cost price, LME/rate inputs, and CNF price list.
- Edit SP and market rate values in the browser.
- Recalculate CP as `SP * 0.97`.
- Recalculate CNF USD and EUR using the EUR/USD rate.
- Download the updated Excel file.
- Compare daily prices with the previous published day, copy that day, search,
  filter, and track entry completeness.
- Show who last saved and published each regional board.
- Warn before downloading CNF lists containing missing or zero calculated prices.
- Download the current or a saved day's CNF list directly as JPEG or PDF.
- Calculate USA FAS indications from editable CNF prices, deduction percentages,
  20FT/40FT freight, destination, and minimum container loading.

## How to run in VS Code

### 0. Set secure passwords before creating a new user database

Existing accounts are loaded from the selected database. If the user table is
empty, startup requires strong seed passwords or migration of the existing
SQLite accounts; the server no longer creates accounts from passwords embedded
in source code.

Set these environment variables before starting with a new, empty user database:

```bash
ADMIN_USERNAME=admin
ADMIN_PASSWORD=change-this-admin-password
INDIAN_TEAM_USERNAME=india
INDIAN_TEAM_PASSWORD=change-this-india-password
USA_FREIGHT_USERNAME=usa_freight
USA_FREIGHT_PASSWORD=change-this-usa-freight-password
SESSION_TTL_MS=28800000
```

Administrators can create a login with one workspace or any combination of
workspaces from **Users & Access**. Existing accounts can be changed in the same
screen without changing their username, password, or saved business data. For
example, one account can receive Europe (SP), UK (SP), USA (SP), and Gross Margin
together, while another account can be limited to a single section.

Assign Europe, UK, and USA independently under **Gross Margin** and **Price
History**. These choices do not grant access to the regional SP entry sheets.
Older accounts keep their effective region permissions until an administrator
changes their access.

The restricted USA Freight workspaces are:

- **Freight Rates Only** opens the dated POL/POD/container rate matrix.
- **Freight Rate Comparison** compares two saved dates and downloads the comparison, without granting rate editing.
- **USA Purchase Price Sheet** opens the 11-column USA SP-to-FAS material calculation table.

Freight Rates saves each matrix by working date and can download a saved rate
sheet. Comparison becomes available after a second date is saved. Each purchase
user's saved material visibility and calculation settings are private to their
login. The USA SP source and freight rates are still shared.

Existing unscoped USA Freight accounts keep full freight access for compatibility.
Indian Team accounts receive the reduced Material/CNF entry screen, while Admin
accounts retain full access. These restrictions are enforced by separate backend
save routes, not only by hiding controls in the browser.

If an installation was configured for MySQL before the USA Freight role was added,
run `CONFIGURE_MYSQL.cmd` once more and enter the MySQL root password. The
idempotent setup applies schema version 2 without deleting existing accounts,
prices, freight settings, or history.

### 1. Extract the ZIP
Open the extracted `excel-price-app` folder in VS Code.

### 2. Install Node.js
Install Node.js LTS from https://nodejs.org if you do not already have it.

### 3. Install dependencies
Open VS Code terminal inside the project folder and run:

```bash
npm run install:all
```

### 4. Run the app on this laptop

On Windows, double-click **START_APP.cmd**. It builds the frontend and serves the
page and API together at **http://localhost:5173**. Keep the window open and press
**Ctrl+C** in it to stop the app. Stop any previously running copy before
launching again.

Use the hostname `localhost`, not a numeric IP address. The app listens only on this computer. Other devices cannot open it over Wi-Fi
or Ethernet. No firewall exception or router port forwarding is needed. The
existing database and logins are unchanged.

For development, run both processes with:

```bash
npm run dev
```

Use one launcher at a time. The development command checks both ports before
starting anything, and stops the paired process if either one exits. If the app
is already up, the launcher points you to the running copy. Neither launcher
kills an existing process to free a port.

- Frontend: http://localhost:5173
- Backend API: http://localhost:5000

### 5. Upload your Excel file
Click **Choose Excel file**, select your `.xlsx`, then click **Upload Excel**.

## Host the app for multiple users

Laptop and development launches stay private by default. For a hosted copy,
build with `npm run build:hosted` and configure the deployment's HTTPS domain
with `APP_PUBLIC_URL`. See the [AWS hosting guide](docs/AWS_HOSTING.md) for the
proxy, network, and database setup. No change to the laptop launcher is needed.

## Main folders

```text
excel-price-app/
  client/     React frontend
    src/
      app/        Shared configuration, access rules, formatting, materials, and pricing calculations
      features/   Screen components grouped by daily prices, materials, SP/CP, CNF, freight, history, users, and shell
      styles/     Ordered CSS layers for the existing visual design
      App.jsx     Application state, API calls, and screen coordination
  server/     Node.js backend
```

The frontend is organized by feature so screen changes remain local. Shared
pricing rules belong in `client/src/app/pricing.js`; reusable page chrome belongs
in `client/src/features/shell`; and CSS imports remain ordered in
`client/src/styles.css` to preserve the existing cascade.

## Important backend API routes

```text
POST /api/login
GET  /api/me
POST /api/logout
GET  /api/daily-prices
PUT  /api/daily-prices
GET  /api/daily-prices/previous
GET  /api/usa-freight
PUT  /api/usa-freight
PUT  /api/usa-freight/rates
PUT  /api/usa-freight/materials
GET  /api/usa-freight/rate-comparison
POST /api/usa-freight/rates/export
POST /api/usa-freight/rate-comparison/export
POST /api/usa-freight/export
POST /api/upload
GET  /api/files/:id
PUT  /api/files/:id/recalculate
GET  /api/files/:id/download
```

Security notes:

- Legacy Indian Team users can read/update daily prices and use their reduced
  Material/CNF freight view.
- Freight Rates accounts can read and save only dated freight-rate matrices.
- USA Purchase Price Sheet accounts can read calculations and save only deduction,
  POD, container, and minimum-load settings.
- Admin users can access protected controller routes.
- Login sessions expire automatically.
- Failed login attempts are throttled.
- The laptop and development servers bind to loopback. A hosted deployment opts
  in to an exact HTTPS hostname and keeps the app port behind a trusted proxy.
- Uploaded Excel files have a size limit controlled by `MAX_UPLOAD_BYTES`.
- Database secrets are loaded from the ignored `server/.env` file.
- MySQL uses a pooled, prepared-statement connection and a restricted
  application account.
- Freight ports, material settings, and dated freight-rate snapshots are stored
  in the existing database-backed USA Freight state. No additional MySQL schema
  migration is required for the two restricted freight access types.

## Database and MySQL Workbench

The default database is SQLite, stored under `server/data`. SQLite is a real SQL
database but is file-based, so it has no server credentials and cannot be
managed directly by MySQL Workbench.

For MySQL Server or Amazon RDS setup, secure credentials, migration of existing
SQLite/JSON data, and Workbench connection details, see
[`docs/MYSQL_SETUP.md`](docs/MYSQL_SETUP.md).

For a local MySQL Server on Windows, double-click `CONFIGURE_MYSQL.cmd`. The
helper securely prompts for the MySQL administrator password, creates the
restricted application account and schema, backs up and migrates the existing
SQLite/JSON data, switches `DB_CLIENT` to `mysql`, and verifies the result. The
administrator password is never written to `.env`.

If the local MySQL root password is forgotten, run `RESET_MYSQL_ROOT.cmd`.
Windows requests Administrator approval, the new password is entered twice in
a hidden prompt, and MySQL is reset using a protected one-time initialization
file. The helper removes temporary password files and verifies the normal
`MySQL84` service login before reporting success.

## Notes

This project is customized for your uploaded Excel format:

- Sheet name: `INPUT DATA`
- Sheet name: `CNF`
- SP column: C
- CP column: D
- Material column: E
- Market labels: G
- Market values: H
