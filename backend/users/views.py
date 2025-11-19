from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
import random
from .serializers import UserRegisterSerializer

# --- MOCK DATABASE ---
# In the real app, this data comes from PostgreSQL
MOCK_USERS = {
    "test@email.com": "password123",
    "user2@email.com": "securepass"
}

# --- MOCK OTP STORAGE ---
# In real app, store this in Redis or Database with an expiration time
# Format: { "email": "1234" }
MOCK_OTP_STORE = {}

class RegisterView(generics.CreateAPIView):
    """
    API View để đăng ký một user mới.
    Chỉ cho phép phương thức POST.
    """
    serializer_class = UserRegisterSerializer

    # Ai cũng có thể gọi API này (kể cả khi chưa đăng nhập)
    permission_classes = [permissions.AllowAny]


# --- NEW LOGIN LOGIC ---

class LoginView(APIView):
    # Allow anyone to access login endpoint
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')

        # 1. Validate Email and Password
        if email in MOCK_USERS and MOCK_USERS[email] == password:
            
            # 2. Generate 4-digit OTP
            otp = str(random.randint(1000, 9999))
            
            # 3. Store OTP temporarily
            MOCK_OTP_STORE[email] = otp
            
            # 4. Send Email (Mocking this by printing to terminal)
            print(f"\n==========================================")
            print(f" [EMAIL SYSTEM] Sending OTP to {email}")
            print(f" SUBJECT: Your Trek Guide Verification Code")
            print(f" BODY: Your code is: {otp}")
            print(f"==========================================\n")

            return Response({
                "message": "OTP sent to email", 
                "email": email
            }, status=status.HTTP_200_OK)
        
        return Response({
            "error": "Invalid email or password"
        }, status=status.HTTP_401_UNAUTHORIZED)


class VerifyOTPView(APIView):
    # Allow anyone to access verify endpoint
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        email = request.data.get('email')
        otp_entered = request.data.get('otp')

        # 1. Check if an OTP exists for this email
        if email in MOCK_OTP_STORE:
            stored_otp = MOCK_OTP_STORE[email]

            # 2. Compare OTPs
            if stored_otp == otp_entered:
                # 3. Clear the OTP so it can't be used twice
                del MOCK_OTP_STORE[email]
                
                return Response({
                    "message": "Login Successful", 
                    "token": "fake-jwt-token-12345" # In real app, return actual JWT here
                }, status=status.HTTP_200_OK)
            
            return Response({"error": "Invalid OTP"}, status=status.HTTP_400_BAD_REQUEST)

        return Response({"error": "OTP expired or not requested"}, status=status.HTTP_400_BAD_REQUEST)