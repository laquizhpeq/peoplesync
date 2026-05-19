import 'package:flutter/material.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';

class RelationshipTypePreset {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final List<Color> gradient;
  final List<String> aliases;

  const RelationshipTypePreset({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.aliases,
  });
}

const List<RelationshipTypePreset> relationshipTypePresets = [
  RelationshipTypePreset(
    key: 'networking',
    label: 'Networking',
    icon: Icons.hub_outlined,
    color: Color(0xFF4F6BED),
    gradient: [Color(0xFF5D7BFF), Color(0xFF3557E0)],
    aliases: ['networking', 'network'],
  ),
  RelationshipTypePreset(
    key: 'amistad',
    label: 'Amistad',
    icon: Icons.favorite_outline_rounded,
    color: Color(0xFFE85D75),
    gradient: [Color(0xFFFF8AA1), Color(0xFFE85D75)],
    aliases: ['amistad', 'amigo', 'amiga'],
  ),
  RelationshipTypePreset(
    key: 'clientes',
    label: 'Clientes',
    icon: Icons.business_center_outlined,
    color: Color(0xFFF2994A),
    gradient: [Color(0xFFFFBE6B), Color(0xFFF2994A)],
    aliases: ['clientes', 'cliente'],
  ),
  RelationshipTypePreset(
    key: 'colaboradores',
    label: 'Colaboradores',
    icon: Icons.handshake_outlined,
    color: Color(0xFF1FA37A),
    gradient: [Color(0xFF48C99F), Color(0xFF148A65)],
    aliases: ['colaboradores', 'colaborador', 'colaboracion'],
  ),
  RelationshipTypePreset(
    key: 'familia',
    label: 'Familia',
    icon: Icons.home_outlined,
    color: Color(0xFF9B51E0),
    gradient: [Color(0xFFB978F6), Color(0xFF8E44D4)],
    aliases: ['familia', 'familiar'],
  ),
  RelationshipTypePreset(
    key: 'seguir cultivando',
    label: 'Seguir cultivando',
    icon: Icons.eco_outlined,
    color: Color(0xFF43A047),
    gradient: [Color(0xFF6DCB71), Color(0xFF2E7D32)],
    aliases: ['seguir cultivando', 'cultivando', 'seguir', 'cuidar'],
  ),
];

RelationshipTypePreset? resolveRelationshipPreset(ContactRecord contact) {
  final candidates = <String>[
    contact.relationship.relationshipType ?? '',
    ...contact.relationship.lookingFor,
    ...contact.relationship.personalityTags,
  ];

  for (final candidate in candidates) {
    final preset = relationshipPresetFromText(candidate);
    if (preset != null) return preset;
  }

  return null;
}

RelationshipTypePreset? relationshipPresetFromText(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized.isEmpty) return null;

  for (final preset in relationshipTypePresets) {
    for (final alias in preset.aliases) {
      if (normalized.contains(alias)) return preset;
    }
  }

  return null;
}
