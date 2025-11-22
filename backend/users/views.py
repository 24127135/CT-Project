from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from django.contrib.auth import get_user_model, authenticate
from .serializers import UserRegisterSerializer, TripTemplateSerializer
from .models import TripTemplate
from rest_framework_simplejwt.tokens import RefreshToken
import random
from django.utils import timezone
from django.core.mail import send_mail
from django.conf import settings

User = get_user_model()

def generate_and_send_otp(user):
    otp = str(random.randint(1000, 9999))
    user.otp = otp
    user.otp_created_at = timezone.now()
    user.save()

    subject = 'Your Trek Guide Verification Code'
    message = f'Hello {user.full_name},\n\nYour verification code is: {otp}\n\nUse this to verify your account.'
    email_from = getattr(settings, 'EMAIL_HOST_USER', 'noreply@trekguide.com')
    recipient_list = [user.email]
    
    try:
        send_mail(subject, message, email_from, recipient_list)
        print(f"Email sent successfully to {user.email}")
    except Exception as e:
        print(f"Failed to send email: {e}")
        print(f"--- DEBUG OTP: {otp} ---")


class RegisterView(generics.CreateAPIView):
    serializer_class = UserRegisterSerializer
    permission_classes = [permissions.AllowAny]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        user.is_active = False 
        user.save()
        generate_and_send_otp(user)
        return Response({
            "message": "User registered. Please verify OTP.",
            "email": user.email
        }, status=status.HTTP_201_CREATED)


class LoginView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')
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
            if user.otp == otp_entered:
                user.otp = None
                user.save()
                if not user.is_active:
                    user.is_active = True
                    user.save()
                
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

# --- NEW VIEW: MANAGE TRIP TEMPLATES ---
class TripTemplateListCreateView(generics.ListCreateAPIView):
    """
    GET: Returns list of templates for the logged-in user.
    POST: Saves a new template.
    """
    serializer_class = TripTemplateSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Only return templates belonging to the current user
        return TripTemplate.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        # Automatically attach the current user to the template
        serializer.save(user=self.request.user)