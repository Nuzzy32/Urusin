import 'package:flutter/material.dart';

import '../models/service_category.dart';

const serviceCategories = [
  ServiceCategory(id: 'ac', name: 'AC', slug: 'ac', icon: Icons.ac_unit),
  ServiceCategory(
    id: 'plumbing',
    name: 'Plumbing',
    slug: 'plumbing',
    icon: Icons.plumbing,
  ),
  ServiceCategory(
    id: 'listrik',
    name: 'Listrik',
    slug: 'listrik',
    icon: Icons.electrical_services,
  ),
];

const quickServiceLabels = ['AC Bocor', 'Pipa Mampet', 'Listrik Mati'];
