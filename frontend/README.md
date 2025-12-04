# frontend

A new Flutter project.

Local environment setup
-----------------------

- Copy `frontend/.env.local.example` to `frontend/.env` and fill values for local development.
- Copy `backend/.env.local.example` to `backend/.env` and fill server values.
- Run the helper to create local `.env` files from examples (PowerShell):

```powershell
./scripts/setup_local_env.ps1
```

- To generate a runtime `env.js` for the web `index.html` (reads `window.__ENV`):

```powershell
./scripts/generate_env_js.ps1 -UseDotenv
```

The repo ignores `.env` files; do not commit real secrets.
