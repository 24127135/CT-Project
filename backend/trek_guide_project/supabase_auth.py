import jwt
import os
from django.contrib.auth import get_user_model
from rest_framework.authentication import BaseAuthentication
from rest_framework import exceptions

User = get_user_model()


class SupabaseJWTAuthentication(BaseAuthentication):
    """
    Authenticate requests using Supabase-issued JWTs.
    Hỗ trợ cả HS256 (JWT Secret) và RS256 (JWKS).
    """

    def authenticate(self, request):
        auth = request.headers.get('Authorization')
        if not auth or not auth.startswith('Bearer '):
            return None

        token = auth.split(' ', 1)[1].strip()

        # 1. Lấy Secret từ file .env (Cái bạn vừa thêm)
        supabase_secret = os.getenv('SUPABASE_JWT_SECRET')

        try:
            # ƯU TIÊN: Dùng Secret với thuật toán HS256 (Fix lỗi hiện tại của bạn)
            if supabase_secret:
                payload = jwt.decode(
                    token,
                    supabase_secret,
                    algorithms=["HS256"],
                    options={"verify_aud": False}  # Supabase thường không yêu cầu check audience chặt chẽ
                )

            # DỰ PHÒNG: Nếu không có Secret thì dùng cách cũ (RS256 / JWKS)
            else:
                supabase_jwks = os.getenv('SUPABASE_JWKS_URL')
                supabase_url = os.getenv('SUPABASE_URL')

                if not supabase_jwks:
                    if not supabase_url:
                        raise exceptions.AuthenticationFailed('SUPABASE_URL or SUPABASE_JWKS_URL must be set')
                    # Tự động thêm đường dẫn nếu thiếu
                    supabase_jwks = f"{supabase_url.rstrip('/')}/auth/v1/.well-known/jwks.json"

                jwk_client = jwt.PyJWKClient(supabase_jwks)
                signing_key = jwk_client.get_signing_key_from_jwt(token)
                payload = jwt.decode(
                    token,
                    signing_key.key,
                    algorithms=["RS256"],
                    options={"verify_aud": False}
                )

            # 2. Xử lý logic User sau khi giải mã Token thành công
            email = payload.get('email')
            if not email:
                raise exceptions.AuthenticationFailed('Token does not contain email')

            # Tìm user trong Database Django, nếu chưa có thì tạo mới
            user, created = User.objects.get_or_create(
                email=email,
                defaults={'username': email}  # Dùng email làm username
            )

            return (user, None)

        except jwt.ExpiredSignatureError:
            raise exceptions.AuthenticationFailed('Token has expired')
        except jwt.DecodeError:
            raise exceptions.AuthenticationFailed('Error decoding token')
        except Exception as e:
            raise exceptions.AuthenticationFailed(f'Authentication error: {str(e)}')