from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from django.contrib.auth import get_user_model
from .models import TripTemplate

User = get_user_model()

class TripTemplateTests(APITestCase):
    def setUp(self):
        # 1. Create a test user
        self.user = User.objects.create_user(
            email='test@example.com', 
            password='password123',
            full_name='Test User'
        )
        # 2. Authenticate the client (Force login without OTP for testing)
        self.client.force_authenticate(user=self.user)
        
        # 3. URL for templates
        self.url = reverse('trip-templates') # Matches the name='trip-templates' in urls.py

    def test_create_template_success(self):
        """Test that we can create a new template"""
        data = {
            "name": "Da Lat Chill",
            "location": "Da Lat",
            "accommodation": "Homestay",
            "pax_group": "Nhóm nhỏ",
            "difficulty": "Người mới",
            "duration_days": 3,
            "interests": ["Coffee", "Cloud Hunting"]
        }
        response = self.client.post(self.url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(TripTemplate.objects.count(), 1)
        self.assertEqual(TripTemplate.objects.get().name, "Da Lat Chill")

    def test_create_duplicate_name_fails(self):
        """Test that creating a template with the same name fails"""
        data = {
            "name": "Da Lat Chill",
            "location": "Da Lat",
            "accommodation": "Homestay",
            "pax_group": "Nhóm nhỏ",
            "difficulty": "Người mới",
            "duration_days": 3
        }
        # Create first time
        self.client.post(self.url, data, format='json')
        
        # Create second time (Should fail)
        response = self.client.post(self.url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        # Check if the custom error message exists
        self.assertIn("Bạn đã có mẫu chuyến đi với tên này", str(response.data))

    def test_get_templates(self):
        """Test that we can retrieve the list of templates"""
        # Create a dummy template in DB
        TripTemplate.objects.create(
            user=self.user, 
            name="Sapa Trek", 
            location="Sapa", 
            accommodation="Camping",
            pax_group="Solo", 
            difficulty="Hard"
        )

        response = self.client.get(self.url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['name'], "Sapa Trek")
