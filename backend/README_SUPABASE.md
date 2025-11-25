# Backend (Django) — Supabase / Deployment Notes

This file explains how to configure the Django backend to use a Supabase Postgres database and keep secrets out of source control.

1) Required environment variables

- `SECRET_KEY` — Django secret key (required). Do NOT commit this to git.
- Option A (recommended for Supabase): `DATABASE_URL`
  - Use the full connection string provided by Supabase, for example:
    ```
    postgresql://postgres:[PASSWORD]@db.qesmaldvlbfznrkrzdhc.supabase.co:5432/postgres
    ```
  - Put it in a `.env` file in the `backend/` directory during local development (this file should be in `.gitignore`).

- Option B (individual vars): `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT` (used only if `DATABASE_URL` is not set)

2) Local `.env` example (create `backend/.env` and do not commit)

```
SECRET_KEY=your-dev-secret-key
DATABASE_URL=postgresql://postgres:YourPassword@db.qesmaldvlbfznrkrzdhc.supabase.co:5432/postgres
# or use DB_NAME, DB_USER, DB_PASSWORD, DB_HOST, DB_PORT
```

3) Using Supabase connection in Django

- `trek_guide_project/settings.py` has been updated to read `DATABASE_URL` if present and configure the `DATABASES` setting accordingly.
- Supabase requires SSL to the managed Postgres; the configuration sets `sslmode=require` for safety.

4) Running locally

- Create a `.env` file in `backend/` with the variables above.
- Install required packages in your Python environment (examples):
  ```powershell
  cd backend
  python -m venv venv
  venv\Scripts\activate; pip install -r requirements.txt
  ```
- Run migrations and start server:
  ```powershell
  python manage.py migrate
  python manage.py runserver
  ```

5) Security notes

- Never commit `backend/.env` or any files containing secrets.
- For production, use your hosting provider's secret management (e.g., environment variables in container/VM/hosting service or a vault) rather than a `.env` file.

6) Optional: Accepting Supabase JWTs in Django

If you want Django to accept Supabase-issued JWTs in `Authorization: Bearer <token>` headers, you'll need to configure JWT validation in Django using the Supabase project's public keys (from the project's `API` settings). This is an advanced step — ask me and I can provide a code snippet and instructions for validating Supabase JWTs in Django.
