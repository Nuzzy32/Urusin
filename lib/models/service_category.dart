import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String name;
  final String slug;
  final IconData icon;
  final bool isActive;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    this.isActive = true,
  });
}
