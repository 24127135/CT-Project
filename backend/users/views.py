from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from django.contrib.auth import get_user_model, authenticate
from .serializers import UserRegisterSerializer
from rest_framework_simplejwt.tokens import RefreshToken
import random
from django.utils import timezone

User = get_user_model()

# --- HELPER FUNCTION (This generates the OTP) ---
def generate_and_send_otp(user):
    # 1. Generate 4-digit code
    otp = str(random.randint(1000, 9999))
    
    # 2. Save to Database
    user.otp = otp
    user.otp_created_at = timezone.now()
    user.save()

    # 3. Mock Email Sending (Print to terminal)
    print(f"\n==========================================")
    print(f" [EMAIL SYSTEM] Sending OTP to {user.email}")
    print(f" SUBJECT: Your Trek Guide Verification Code")
    print(f" BODY: Your code is: {otp}")
    print(f"==========================================\n")


class RegisterView(generics.CreateAPIView):
    serializer_class = UserRegisterSerializer
    permission_classes = [permissions.AllowAny]

    # --- THIS WAS MISSING IN YOUR FILE ---
    def create(self, request, *args, **kwargs):
        # 1. Use the serializer to validate input (email, password match, etc.)
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        # 2. Save the user to the database
        user = serializer.save()
        
        # 3. Set user to 'inactive' so they can't login yet
        user.is_active = False 
        user.save()

        # 4. Generate the OTP
        generate_and_send_otp(user)

        # 5. Return the custom response
        return Response({
            "message": "User registered. Please verify OTP.",
            "email": user.email
        }, status=status.HTTP_201_CREATED)
    # -------------------------------------


class LoginView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')

        # Authenticate checks the Database for matching email/password
        user = authenticate(username=email, password=password)

        if user is not None:
            generate_and_send_otp(user)
            return Response({
                "message": "OTP sent to email",
                "email": email
            }, status=status.HTTP_200_OK)
        
        return Response({"error": "Invalid email or password"}, status=status.HTTP_401_UNAUTHORIZED)


class VerifyOTPView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        email = request.data.get('email')
        otp_entered = request.data.get('otp')

        try:
            user = User.objects.get(email=email)
            
            # Check if OTP matches
            if user.otp == otp_entered:
                # 1. Clear OTP so it can't be used again
                user.otp = None
                user.save()

                # 2. Activate user if this was a registration flow
                if not user.is_active:
                    user.is_active = True
                    user.save()
                
                # 3. Generate JWT Token (Access + Refresh)
                refresh = RefreshToken.for_user(user)

                return Response({
                    "message": "Login Successful",
                    "refresh": str(refresh),
                    "access": str(refresh.access_token),
                }, status=status.HTTP_200_OK)
            
            else:
                return Response({"error": "Invalid OTP"}, status=status.HTTP_400_BAD_REQUEST)

        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)