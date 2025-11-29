import json
import os
import random
import google.generativeai as genai
from rest_framework import serializers
from .models import Plan, Route, HistoryInput, Equipment

# Configure Gemini
GENAI_KEY = os.getenv('GEMINI_API_KEY')
if GENAI_KEY:
    genai.configure(api_key=GENAI_KEY)

# 1. RouteSerializer
class RouteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Route
        fields = '__all__'

# 2. HistoryInputSerializer
class HistoryInputSerializer(serializers.ModelSerializer):
    class Meta:
        model = HistoryInput
        exclude = ['user']

# 3. PlanSerializer
class PlanSerializer(serializers.ModelSerializer):
    user = serializers.PrimaryKeyRelatedField(read_only=True)
    route = serializers.PrimaryKeyRelatedField(queryset=Route.objects.all(), required=False, allow_null=True)

    class Meta:
        model = Plan
        read_only_fields = ['personalized_equipment_list', 'dangers_snapshot']
        fields = '__all__'

    def create(self, validated_data):
        plan = Plan.objects.create(**validated_data)
        return plan
