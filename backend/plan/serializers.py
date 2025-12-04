import json
import os
from rest_framework import serializers
from .models import Plan, Route, HistoryInput, Equipment

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

    personalized_equipment_list = serializers.JSONField(required=False, allow_null=True)
    dangers_snapshot = serializers.JSONField(required=False, allow_null=True)

    class Meta:
        model = Plan
        read_only_fields = []
        fields = '__all__'

    def create(self, validated_data):
        plan = Plan.objects.create(**validated_data)
        return plan

    def update(self, instance, validated_data):
        instance.route = validated_data.get('route', instance.route)
        instance.personalized_equipment_list = validated_data.get('personalized_equipment_list', instance.personalized_equipment_list)
        instance.dangers_snapshot = validated_data.get('dangers_snapshot', instance.dangers_snapshot)
        instance.save()
        return instance
