import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final ringtoneRepositoryProvider = Provider<RingtoneRepository>((ref) {
  throw UnimplementedError('Initialize this provider in main');
});

// Cached Providers to prevent reloading on navigation
final trendingRingtonesProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  final repo = ref.watch(ringtoneRepositoryProvider);
  return repo.getTrendingRingtones();
});

final latestRingtonesProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  final repo = ref.watch(ringtoneRepositoryProvider);
  return repo.getLatestRingtones();
});

final categoriesProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  final repo = ref.watch(ringtoneRepositoryProvider);
  return repo.getCategoryList();
});

final categoryRingtonesProvider = FutureProvider.family<List<Map<String, String>>, String>((ref, categoryName) async {
  final repo = ref.watch(ringtoneRepositoryProvider);
  if (categoryName == 'Latest') {
     return repo.getLatestRingtones();
  }
  return repo.getByCategory(categoryName);
});

final songsProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  final repo = ref.watch(ringtoneRepositoryProvider);
  return repo.getSongs();
});

final favoritesProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  final repo = ref.watch(ringtoneRepositoryProvider);
  return repo.getFavorites();
});

final isPremiumUserProvider = StateProvider<bool>((ref) {
  final repo = ref.watch(ringtoneRepositoryProvider);
  return repo.isPremiumUser();
});

class RingtoneRepository {
  final SharedPreferences prefs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RingtoneRepository(this.prefs);

  static const _favoritesKey = 'favorites_list';
  static const _recentKey = 'recent_list';
  static const _isPremiumUserKey = 'is_premium_user';
  static const _unlockedRingtonesKey = 'unlocked_ringtones';

  bool isPremiumUser() {
    return prefs.getBool(_isPremiumUserKey) ?? false;
  }

  Future<void> setPremiumUser(bool isPremium) async {
    await prefs.setBool(_isPremiumUserKey, isPremium);
  }

  bool isRingtoneUnlocked(String id) {
    if (isPremiumUser()) return true;
    final unlocked = prefs.getStringList(_unlockedRingtonesKey) ?? [];
    return unlocked.contains(id);
  }

  Future<void> unlockRingtone(String id) async {
    final unlocked = prefs.getStringList(_unlockedRingtonesKey) ?? [];
    if (!unlocked.contains(id)) {
      unlocked.add(id);
      await prefs.setStringList(_unlockedRingtonesKey, unlocked);
    }
  }

  Future<void> toggleFavorite(String id) async {
    final favorites = _getStringList(_favoritesKey);
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }
    await prefs.setStringList(_favoritesKey, favorites);
  }

  Future<bool> isFavorite(String id) async {
    final favorites = _getStringList(_favoritesKey);
    return favorites.contains(id);
  }

  Future<void> addToRecent(String id) async {
    final recent = _getStringList(_recentKey);
    recent.remove(id);
    recent.insert(0, id);
    if (recent.length > 20) recent.removeLast();
    await prefs.setStringList(_recentKey, recent);
  }

  Future<List<Map<String, String>>> getFavorites() async {
     final ids = _getStringList(_favoritesKey);
     if (ids.isEmpty) return [];
     
     List<Map<String, String>> results = [];
     for (var id in ids) {
       try {
          // Try fetching from 'ringtones' first
          var doc = await _firestore.collection('ringtones').doc(id).get();
          
          // If not found, try 'songs' collection
          if (!doc.exists) {
             doc = await _firestore.collection('songs').doc(id).get();
          }

          if (doc.exists) {
            results.add(_docToMap(doc));
          }
       } catch (e) {
         // Handle error or deleted item
       }
     }
     return results;
  }

  Future<List<Map<String, String>>> getRecents() async {
     final ids = _getStringList(_recentKey);
     if (ids.isEmpty) return [];
     
     List<Map<String, String>> results = [];
     for (var id in ids) {
       try {
          final doc = await _firestore.collection('ringtones').doc(id).get();
          if (doc.exists) {
            results.add(_docToMap(doc));
          }
       } catch (e) {
          // ignore
       }
     }
     return results;
  }

  List<String> _getStringList(String key) {
    return prefs.getStringList(key) ?? [];
  }

  Future<List<Map<String, String>>> getTrendingRingtones() async {
    try {
      final querySnapshot = await _firestore.collection('ringtones')
          .where('active', isEqualTo: true)
          .where('isBanner', isEqualTo: true)
          .limit(10).get();
      return querySnapshot.docs.map(_docToMap).toList();
    } catch (e) {
      print("Error fetching trending: $e");
      return [];
    }
  }

  Future<List<Map<String, String>>> getByCategory(String category) async {
    try {
      // Assuming 'category' field exists in Firestore
      final querySnapshot = await _firestore
          .collection('ringtones')
          .where('category', isEqualTo: category)
          .where('active', isEqualTo: true)
          .limit(20)
          .get();
      return querySnapshot.docs.map(_docToMap).toList();
    } catch (e) {
       print("Error fetching category $category: $e");
       return [];
    }
  }

  Future<List<Map<String, String>>> getLatestRingtones() async {
    // Mock / Cache priority? 
    // Just return mock for now if mock enabled
    try {
      // if (_useMock) return _mockRingtones; // Assuming _useMock and _mockRingtones are defined elsewhere if needed
      
      // Real: Fetch from 'ringtones' collection, order by 'createdAt' desc
      // Assuming 'createdAt' field exists
      final snapshot = await _firestore.collection('ringtones')
          .where('active', isEqualTo: true)
          .limit(10)
          .get(); // Add orderBy('createdAt', descending: true) when field exists

      return snapshot.docs.map(_docToMap).toList();

    } catch (e) {
      print("Error fetching latest ringtones: $e");
      return [];
    }
  }

  Future<List<Map<String, String>>> getCategoryList() async {
    try {
      // Try correct spelling first
      var querySnapshot = await _firestore.collection('categories').get();
      
      // Fallback: Try common misspelling 'catagories' if correct one is empty
      if (querySnapshot.docs.isEmpty) {
        print(" 'categories' collection empty. Checking 'catagories'...");
        querySnapshot = await _firestore.collection('catagories').get();
      }

      print("Found ${querySnapshot.docs.length} categories");

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          // Check 'category' (correct), 'catagory' (misspelling), or 'name' (legacy)
          'name': data['category']?.toString() 
               ?? data['catagory']?.toString() 
               ?? data['name']?.toString() 
               ?? doc.id,
          'image': data['image']?.toString() ?? '', 
        };
      }).toList();
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }

  Future<List<Map<String, String>>> getSongs() async {
    try {
      final querySnapshot = await _firestore.collection('songs').get();
      return querySnapshot.docs
          .map(_docToMap)
          .where((s) => s['active'] == 'true')
          .toList();
    } catch (e) {
      print("Error fetching songs: $e");
      return [];
    }
  }

  Future<Map<String, String>?> fetchRingtone(String id) async {
    try {
      var doc = await _firestore.collection('ringtones').doc(id).get();
      if (!doc.exists) {
         doc = await _firestore.collection('songs').doc(id).get();
      }
      
      if (doc.exists) {
        return _docToMap(doc);
      }
    } catch (e) {
      print("Error fetching ringtone $id: $e");
    }
    return null;
  }

  Future<List<Map<String, String>>> searchRingtones(String query) async {
    if (query.isEmpty) return [];

    try {
      // Basic Search Strategy:
      // Firestore does not support true case-insensitive search or OR queries across collections easily.
      // We will perform parallel queries for 'ringtones' AND 'songs'.
      // We will also try a few case variations to help the user.
      
      String term = query.trim();
      List<String> variations = [term];
      
      // Add Capitalized version (e.g. "iphone" -> "Iphone")
      if (term.isNotEmpty) {
         variations.add(term[0].toUpperCase() + term.substring(1));
      }
      // Add Lowercase version
      variations.add(term.toLowerCase());
      
      variations = variations.toSet().toList(); // Unique

      List<Future<QuerySnapshot>> futures = [];

      for (String v in variations) {
         // Search Ringtones
         futures.add(_firestore
          .collection('ringtones')
          .where('title', isGreaterThanOrEqualTo: v)
          .where('title', isLessThan: v + '\uf8ff')
          .limit(10)
          .get());
          
         // Search Songs
         futures.add(_firestore
          .collection('songs')
          .where('title', isGreaterThanOrEqualTo: v)
          .where('title', isLessThan: v + '\uf8ff')
          .limit(10)
          .get());
      }

      final snapshots = await Future.wait(futures);
      
      // Merge results
      // Use a Map to deduplicate by ID
      Map<String, Map<String, String>> merged = {};
      
      for (var snap in snapshots) {
         for (var doc in snap.docs) {
            final data = _docToMap(doc);
            // In-memory filter for active status to avoid index requirements
            final isActive = data['active'] == 'true' || data['active'] == true;
            if (isActive) {
               merged[doc.id] = data;
            }
         }
      }

      return merged.values.toList();

    } catch (e) {
      print("Search error: $e");
      return [];
    }
  }

  Map<String, String> _docToMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return {
      'id': doc.id,
      'title': data['title']?.toString() ?? 'Unknown Title',
      'author': data['author']?.toString() ?? 'Unknown Artist',
      'duration': data['duration']?.toString() ?? '',
      'url': data['url']?.toString() ?? '',
      'category': data['category']?.toString() ?? 'General',
      'isPremium': data['isPremium']?.toString() ?? 'false',
      'active': data['active']?.toString() ?? 'true',
      'image': data['image']?.toString() ?? '',
      'tags': (data['tags'] is List) 
          ? (data['tags'] as List).map((e) => e.toString()).join(',') 
          : '',
    };
  }
}
