class MeUser {
  final String id;
  final String name;
  final String email;
  final bool twoFactorEnabled;

  const MeUser({
    required this.id,
    required this.name,
    required this.email,
    required this.twoFactorEnabled,
  });

  factory MeUser.fromJson(Map<String, dynamic> json) {
    return MeUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      twoFactorEnabled: json['two_factor_enabled'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'two_factor_enabled': twoFactorEnabled,
    };
  }
}

class MeCompany {
  final String id;
  final String name;
  final String code;

  const MeCompany({
    required this.id,
    required this.name,
    required this.code,
  });

  factory MeCompany.fromJson(Map<String, dynamic> json) {
    return MeCompany(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }
}

class MeMenuItem {
  final String key;
  final String label;
  final String icon;
  final String module;

  const MeMenuItem({
    required this.key,
    required this.label,
    required this.icon,
    required this.module,
  });

  factory MeMenuItem.fromJson(Map<String, dynamic> json) {
    return MeMenuItem(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      module: json['module']?.toString() ?? 'core',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'icon': icon,
      'module': module,
    };
  }
}

class MeResponseModel {
  final MeUser user;
  final MeCompany company;
  final Map<String, List<String>> permissions;
  final List<String> modules;
  final List<MeMenuItem> menu;
  final Map<String, int> badges;

  const MeResponseModel({
    required this.user,
    required this.company,
    required this.permissions,
    required this.modules,
    required this.menu,
    required this.badges,
  });

  factory MeResponseModel.fromJson(Map<String, dynamic> json) {
    // Safe envelope extraction
    final Map<String, dynamic> data = (json['data'] is Map)
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    // Parse user
    final userRaw = (data['user'] is Map)
        ? Map<String, dynamic>.from(data['user'] as Map)
        : <String, dynamic>{};
    final user = MeUser.fromJson(userRaw);

    // Parse company
    final compRaw = (data['company'] is Map)
        ? Map<String, dynamic>.from(data['company'] as Map)
        : <String, dynamic>{};
    final company = MeCompany.fromJson(compRaw);

    // Parse permissions map
    final Map<String, List<String>> permissions = {};
    if (data['permissions'] is Map) {
      (data['permissions'] as Map).forEach((key, value) {
        if (value is List) {
          permissions[key.toString()] =
              value.map((e) => e.toString()).toList();
        } else if (value == null) {
          permissions[key.toString()] = <String>[];
        }
      });
    }

    // Parse modules list
    final List<String> modules = [];
    if (data['modules'] is List) {
      modules.addAll(
        (data['modules'] as List).map((e) => e.toString()),
      );
    }

    // Parse menu list
    final List<MeMenuItem> menu = [];
    if (data['menu'] is List) {
      for (final item in (data['menu'] as List)) {
        if (item is Map) {
          menu.add(MeMenuItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    // Parse badges map
    final Map<String, int> badges = {};
    if (data['badges'] is Map) {
      (data['badges'] as Map).forEach((key, value) {
        final parsed = int.tryParse(value.toString()) ?? 0;
        badges[key.toString()] = parsed;
      });
    }

    return MeResponseModel(
      user: user,
      company: company,
      permissions: permissions,
      modules: modules,
      menu: menu,
      badges: badges,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'company': company.toJson(),
      'permissions': permissions,
      'modules': modules,
      'menu': menu.map((m) => m.toJson()).toList(),
      'badges': badges,
    };
  }
}
