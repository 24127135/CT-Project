import os
from django.contrib.auth import get_user_model
from rest_framework.authentication import BaseAuthentication
from rest_framework import exceptions
import jwt

User = get_user_model()


class SupabaseJWTAuthentication(BaseAuthentication):
    """Authenticate requests using Supabase-issued JWTs.

    It fetches the JWKS from SUPABASE_JWKS_URL or constructs it from SUPABASE_URL.
    On successful verification, it returns (User, None). If the user doesn't
    exist, a local user is created with the token email.
    """

    def authenticate(self, request):
        auth = request.headers.get('Authorization')
        if not auth or not auth.startswith('Bearer '):
            return None
        token = auth.split(' ', 1)[1].strip()

        supabase_jwks = os.getenv('SUPABASE_JWKS_URL')
        supabase_url = os.getenv('SUPABASE_URL')
        if not supabase_jwks:
            if not supabase_url:
                raise exceptions.AuthenticationFailed('SUPABASE_URL or SUPABASE_JWKS_URL must be set')
            supabase_jwks = f"{supabase_url.rstrip('/')}/auth/v1/.well-known/jwks.json"

        try:
            jwk_client = jwt.PyJWKClient(supabase_jwks)
            signing_key = jwk_client.get_signing_key_from_jwt(token)
            payload = jwt.decode(token, signing_key.key, algorithms=["RS256"], options={"verify_aud": False})
        except Exception as e:
            raise exceptions.AuthenticationFailed(f'Invalid JWT: {e}')

        email = payload.get('email') or payload.get('sub')
        if not email:
            raise exceptions.AuthenticationFailed('Token missing email claim')

        user, _ = User.objects.get_or_create(email=email, defaults={'full_name': payload.get('name', '')})
        return (user, None)
