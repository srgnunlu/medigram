import 'package:get/get.dart';
import 'package:medigram/data/models/medical_card.dart';
import 'package:medigram/data/services/medical_card_service.dart';
import 'package:medigram/data/services/auth_service.dart';
import 'package:medigram/core/utils/snackbar_helper.dart';

class MedicalCardController extends GetxController {
  final MedicalCardService _medicalCardService = MedicalCardService();
  final AuthService _authService = AuthService();

  // Observable state
  final RxList<MedicalCard> _medicalCards = <MedicalCard>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxString _selectedCategory = ''.obs;
  final RxInt _currentPage = 1.obs;
  final RxBool _hasMorePages = true.obs;

  // Getters
  List<MedicalCard> get medicalCards => _medicalCards;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  String get selectedCategory => _selectedCategory.value;
  bool get hasMorePages => _hasMorePages.value;

  @override
  void onInit() {
    super.onInit();
    fetchMedicalCards();
  }

  // Fetch medical cards
  Future<void> fetchMedicalCards({
    String? category,
    bool? isPremium,
    String? search,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        _isLoading.value = true;
        _currentPage.value = 1;
        _medicalCards.clear();
      } else if (_currentPage.value == 1) {
        _isLoading.value = true;
      } else {
        _isLoadingMore.value = true;
      }

      final cards = await _medicalCardService.getMedicalCards(
        category: category ?? _selectedCategory.value,
        isPremium: isPremium,
        search: search,
        page: _currentPage.value,
        pageSize: 25,
      );

      if (cards.isEmpty) {
        _hasMorePages.value = false;
      } else {
        if (refresh || _currentPage.value == 1) {
          _medicalCards.value = cards;
        } else {
          _medicalCards.addAll(cards);
        }
        _currentPage.value++;
      }
    } catch (e) {
      SnackbarHelper.showError('Kartlar yüklenirken hata oluştu: ${e.toString()}');
    } finally {
      _isLoading.value = false;
      _isLoadingMore.value = false;
    }
  }

  // Load more cards (pagination)
  Future<void> loadMore() async {
    if (!_isLoadingMore.value && _hasMorePages.value) {
      await fetchMedicalCards();
    }
  }

  // Refresh cards
  Future<void> refresh() async {
    _hasMorePages.value = true;
    await fetchMedicalCards(refresh: true);
  }

  // Filter by category
  Future<void> filterByCategory(String category) async {
    _selectedCategory.value = category;
    _hasMorePages.value = true;
    await fetchMedicalCards(category: category, refresh: true);
  }

  // Clear filter
  Future<void> clearFilter() async {
    _selectedCategory.value = '';
    _hasMorePages.value = true;
    await fetchMedicalCards(refresh: true);
  }

  // Search
  Future<void> search(String query) async {
    if (query.isEmpty) {
      await refresh();
      return;
    }

    try {
      _isLoading.value = true;
      _medicalCards.clear();

      final cards = await _medicalCardService.searchMedicalCards(query);
      _medicalCards.value = cards;
    } catch (e) {
      SnackbarHelper.showError('Arama sırasında hata oluştu: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Toggle like
  Future<void> toggleLike(int cardId) async {
    try {
      // Check if user is logged in
      final isLoggedIn = await _authService.isLoggedIn();
      if (!isLoggedIn) {
        SnackbarHelper.showWarning('Beğenmek için giriş yapmalısınız.');
        return;
      }

      final result = await _medicalCardService.toggleLike(cardId);

      // Update local state
      final index = _medicalCards.indexWhere((card) => card.id == cardId);
      if (index != -1) {
        final card = _medicalCards[index];
        final user = await _authService.getCurrentUser();

        if (user != null) {
          List<String> updatedLikes = List.from(card.likes);
          if (result['isLiked'] == true) {
            if (!updatedLikes.contains(user.id.toString())) {
              updatedLikes.add(user.id.toString());
            }
          } else {
            updatedLikes.remove(user.id.toString());
          }

          _medicalCards[index] = card.copyWith(likes: updatedLikes);
        }
      }

      if (result['isLiked'] == true) {
        SnackbarHelper.showSuccess('Beğenildi!');
      }
    } catch (e) {
      SnackbarHelper.showError('Beğeni işlemi başarısız: ${e.toString()}');
    }
  }

  // Share card
  Future<void> shareCard(int cardId) async {
    try {
      await _medicalCardService.shareMedicalCard(cardId);
      SnackbarHelper.showSuccess('Paylaşıldı!');
    } catch (e) {
      SnackbarHelper.showError('Paylaşım başarısız: ${e.toString()}');
    }
  }

  // Get single card
  Future<MedicalCard?> getCardById(int id) async {
    try {
      return await _medicalCardService.getMedicalCardById(id);
    } catch (e) {
      SnackbarHelper.showError('Kart yüklenemedi: ${e.toString()}');
      return null;
    }
  }
}
