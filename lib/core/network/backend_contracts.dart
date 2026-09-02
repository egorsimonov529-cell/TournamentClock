class BackendContracts {
  const BackendContracts._();

  static const String authPath = '/api/v1/auth';
  static const String usersPath = '/api/v1/users';
  static const String tablesPath = '/api/v1/tables';
  static const String playersPath = '/api/v1/players';
  static const String tournamentsPath = '/api/v1/tournaments';
  static const String adminPath = '/api/v1/admin';

  static const Map<String, dynamic> authLogin = {
    'type': 'object',
    'required': ['login', 'password'],
    'properties': {
      'login': {'type': 'string'},
      'password': {'type': 'string'},
      'remember_me': {'type': 'boolean'},
    },
  };

  static const Map<String, dynamic> authResponse = {
    'type': 'object',
    'required': ['accessToken', 'refreshToken', 'user'],
    'properties': {
      'accessToken': {'type': 'string'},
      'refreshToken': {'type': 'string'},
      'user': {
        'type': 'object',
        'required': ['id', 'login', 'email', 'role'],
        'properties': {
          'id': {'type': 'string'},
          'login': {'type': 'string'},
          'email': {'type': 'string'},
          'role': {'type': 'string'},
          'firstName': {'type': 'string'},
          'lastName': {'type': 'string'},
          'avatarUrl': {'type': 'string'},
        },
      },
    },
  };

  static const Map<String, dynamic> userProfile = {
    'type': 'object',
    'required': ['id', 'login', 'email', 'role'],
    'properties': {
      'id': {'type': 'string'},
      'login': {'type': 'string'},
      'email': {'type': 'string'},
      'role': {'type': 'string'},
      'firstName': {'type': 'string'},
      'lastName': {'type': 'string'},
      'avatarUrl': {'type': 'string'},
      'isActive': {'type': 'boolean'},
      'createdAt': {'type': 'string', 'format': 'date-time'},
      'lastLoginAt': {'type': 'string', 'format': 'date-time'},
    },
  };

  static const Map<String, dynamic> tournament = {
    'type': 'object',
    'required': ['id', 'name', 'start_date', 'end_date', 'max_players'],
    'properties': {
      'id': {'type': 'string'},
      'name': {'type': 'string'},
      'description': {'type': 'string'},
      'start_date': {'type': 'string', 'format': 'date-time'},
      'end_date': {'type': 'string', 'format': 'date-time'},
      'max_players': {'type': 'integer'},
      'buy_in': {'type': 'number'},
      'format': {'type': 'string'},
      'status': {'type': 'string'},
      'registered_players': {
        'type': 'array',
        'items': {'type': 'string'},
      },
    },
  };

  static const Map<String, dynamic> table = {
    'type': 'object',
    'required': ['id', 'name', 'seats'],
    'properties': {
      'id': {'type': 'string'},
      'name': {'type': 'string'},
      'seats': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'number': {'type': 'integer'},
            'player': {
              'type': ['object', 'null'],
              'properties': {
                'id': {'type': 'string'},
                'name': {'type': 'string'},
                'rpsRank': {'type': 'string'},
                'skillScore': {'type': 'integer'},
              },
            },
          },
        },
      },
    },
  };

  static const Map<String, dynamic> player = {
    'type': 'object',
    'required': ['id', 'name', 'rpsRank', 'skillScore'],
    'properties': {
      'id': {'type': 'string'},
      'name': {'type': 'string'},
      'rpsRank': {'type': 'string'},
      'skillScore': {'type': 'integer'},
    },
  };

  static const Map<String, dynamic> rankDefinition = {
    'type': 'object',
    'required': ['id', 'code', 'name', 'minimumPoints'],
    'properties': {
      'id': {'type': 'string'},
      'code': {'type': 'string'},
      'name': {'type': 'string'},
      'minimumPoints': {'type': 'integer'},
      'description': {'type': 'string'},
    },
  };

  static const Map<String, dynamic> adminWorkspace = {
    'type': 'object',
    'required': ['club_name', 'club_short_name', 'currency'],
    'properties': {
      'club_name': {'type': 'string'},
      'club_short_name': {'type': 'string'},
      'logo_asset_path': {'type': 'string'},
      'currency': {'type': 'string'},
      'notifications_enabled': {'type': 'boolean'},
      'transactions': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'id': {'type': 'string'},
            'description': {'type': 'string'},
            'amount': {'type': 'number'},
            'created_at': {'type': 'string', 'format': 'date-time'},
          },
        },
      },
      'campaigns': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'id': {'type': 'string'},
            'title': {'type': 'string'},
            'description': {'type': 'string'},
            'active': {'type': 'boolean'},
          },
        },
      },
    },
  };
}
