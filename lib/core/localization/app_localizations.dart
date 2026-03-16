import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString('lib/core/localization/l10n/app_${locale.languageCode}.arb');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      _localizedStrings = jsonMap.map((key, value) {
        // Skip metadata keys that start with '@' or '_comment'
        if (key.startsWith('@') || key.startsWith('_comment')) {
          return MapEntry(key, '');
        }
        return MapEntry(key, value.toString());
      });
      
      return true;
    } catch (e) {
      debugPrint('Error loading localizations: $e');
      return false;
    }
  }

  String translate(String key, {Map<String, String>? params}) {
    String translation = _localizedStrings[key] ?? key;
    
    // Replace placeholders if params provided
    if (params != null) {
      params.forEach((key, value) {
        translation = translation.replaceAll('{$key}', value);
      });
    }
    
    return translation;
  }

  // Common strings
  String get appName => translate('appName');
  String get appTitle => translate('appTitle');
  String get ok => translate('ok');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get confirm => translate('confirm');
  String get yes => translate('yes');
  String get no => translate('no');
  String get submit => translate('submit');
  String get search => translate('search');
  String get filter => translate('filter');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get retry => translate('retry');
  String get close => translate('close');
  String get back => translate('back');
  String get next => translate('next');
  String get previous => translate('previous');
  String get done => translate('done');
  String get required => translate('required');
  String get optional => translate('optional');

  // Auth
  String get signIn => translate('signIn');
  String get signInToContinue => translate('signInToContinue');
  String get email => translate('email');
  String get password => translate('password');
  String get logout => translate('logout');
  String get logoutConfirmTitle => translate('logoutConfirmTitle');
  String get logoutConfirmMessage => translate('logoutConfirmMessage');

  // Validation
  String get emailRequired => translate('emailRequired');
  String get emailInvalid => translate('emailInvalid');
  String get passwordRequired => translate('passwordRequired');
  String get passwordMinLength => translate('passwordMinLength');
  String get fieldRequired => translate('fieldRequired');
  String get invalidNumber => translate('invalidNumber');
  String get numberMustBePositive => translate('numberMustBePositive');

  // Profile
  String get profile => translate('profile');
  String get role => translate('role');
  String get phone => translate('phone');
  String get phoneNotSet => translate('phoneNotSet');
  String get memberSince => translate('memberSince');
  String get language => translate('language');
  String get languageSettings => translate('languageSettings');
  String get selectLanguage => translate('selectLanguage');
  String get english => translate('english');
  String get arabic => translate('arabic');

  // Dashboard
  String get dashboard => translate('dashboard');
  String welcomeBack(String name) => translate('welcomeBack', params: {'name': name});
  String get todaysOrders => translate('todaysOrders');
  String get assignedOrders => translate('assignedOrders');
  String get assigned => translate('assigned');
  String get overdueOrders => translate('overdueOrders');
  String get overdue => translate('overdue');
  String get totalOrders => translate('totalOrders');
  String get noOrdersYet => translate('noOrdersYet');
  String get viewAll => translate('viewAll');
  String get quickActions => translate('quickActions');
  String get viewOrders => translate('viewOrders');

  // Orders
  String get orders => translate('orders');
  String get orderNumber => translate('orderNumber');
  String get orderSummary => translate('orderSummary');
  String get supplier => translate('supplier');
  String get totalAmount => translate('totalAmount');
  String get expectedDate => translate('expectedDate');
  String get products => translate('products');
  String get items => translate('items');
  String get status => translate('status');
  String get notes => translate('notes');
  String get notesOptional => translate('notesOptional');
  String get addNotesHint => translate('addNotesHint');
  String get enterNotesHere => translate('enterNotesHere');
  String get confirmOrder => translate('confirmOrder');
  String get confirming => translate('confirming');
  String get orderConfirmedSuccess => translate('orderConfirmedSuccess');
  String orderConfirmFailed(String error) => translate('orderConfirmFailed', params: {'error': error});

  // Order Status
  String get statusNotAssigned => translate('statusNotAssigned');
  String get statusAssigned => translate('statusAssigned');
  String get statusConfirmed => translate('statusConfirmed');
  String get statusPaid => translate('statusPaid');
  String get statusCanceled => translate('statusCanceled');

  // Submit Review
  String get billReceiptPhoto => translate('billReceiptPhoto');
  String get uploadProofOfPurchase => translate('uploadProofOfPurchase');
  String get selectImage => translate('selectImage');
  String get takePhoto => translate('takePhoto');
  String get chooseFromGallery => translate('chooseFromGallery');
  String get selectImageRequired => translate('selectImageRequired');
  String imagePickFailed(String error) => translate('imagePickFailed', params: {'error': error});
  String get editPriceQuantity => translate('editPriceQuantity');
  String get reviewAndAdjustHint => translate('reviewAndAdjustHint');
  String get productName => translate('productName');
  String get quantity => translate('quantity');
  String get unitPrice => translate('unitPrice');
  String originalPrice(String price) => translate('originalPrice', params: {'price': price});
  String originalQuantity(String qty) => translate('originalQuantity', params: {'qty': qty});
  String get changesSummary => translate('changesSummary');
  String get noChanges => translate('noChanges');
  String changedFrom(String oldValue, String newValue) => translate('changedFrom', params: {'oldValue': oldValue, 'newValue': newValue});

  // Notifications
  String get notifications => translate('notifications');
  String get noNotifications => translate('noNotifications');
  String get markAsRead => translate('markAsRead');
  String get markAllAsRead => translate('markAllAsRead');

  // Products
  String get product => translate('product');
  String get category => translate('category');
  String get price => translate('price');
  String get stock => translate('stock');
  String get inStock => translate('inStock');
  String get outOfStock => translate('outOfStock');

  // Suppliers
  String get suppliers => translate('suppliers');
  String get supplierName => translate('supplierName');
  String get contactInfo => translate('contactInfo');

  // Tasks
  String get tasks => translate('tasks');
  String get taskDetails => translate('taskDetails');
  String get taskName => translate('taskName');
  String get taskStatus => translate('taskStatus');
  String get dueDate => translate('dueDate');
  String get markAsDone => translate('markAsDone');
  String get markingAsDone => translate('markingAsDone');
  String get taskMarkedDone => translate('taskMarkedDone');

  // Transfers
  String get transfers => translate('transfers');
  String get transferDetails => translate('transferDetails');
  String get noTransfersFound => translate('noTransfersFound');
  String get pendingTransfers => translate('pendingTransfers');
  String get inProgress => translate('inProgress');
  String get viewTransfers => translate('viewTransfers');
  String get startTransfer => translate('startTransfer');
  String get markAsArrived => translate('markAsArrived');
  String get transferUpdatedSuccess => translate('transferUpdatedSuccess');
  String get updating => translate('updating');

  // Navigation
  String get home => translate('home');
  String get myOrders => translate('myOrders');
  String get myTasks => translate('myTasks');

  // Errors
  String get somethingWentWrong => translate('somethingWentWrong');
  String get noInternetConnection => translate('noInternetConnection');
  String get tryAgainLater => translate('tryAgainLater');
  String get unexpectedError => translate('unexpectedError');
  String get loadingFailed => translate('loadingFailed');

  // Admin
  String get adminDashboard => translate('adminDashboard');
  String get staffManagement => translate('staffManagement');
  String get supplierManagement => translate('supplierManagement');
  String get orderManagement => translate('orderManagement');
  String get productManagement => translate('productManagement');
  String get categoryManagement => translate('categoryManagement');
  String get analytics => translate('analytics');

  String get createStaff => translate('createStaff');
  String get editStaff => translate('editStaff');
  String get deleteStaff => translate('deleteStaff');
  String get staffList => translate('staffList');
  String get staffName => translate('staffName');
  String get staffEmail => translate('staffEmail');
  String get staffPhone => translate('staffPhone');
  String get staffRole => translate('staffRole');
  String get staffAddress => translate('staffAddress');
  String get staffActive => translate('staffActive');
  String get activeStaff => translate('activeStaff');
  String get inactiveStaff => translate('inactiveStaff');

  String get createSupplier => translate('createSupplier');
  String get editSupplier => translate('editSupplier');
  String get deleteSupplier => translate('deleteSupplier');

  String get createOrder => translate('createOrder');
  String get editOrder => translate('editOrder');
  String get createNewOrder => translate('createNewOrder');
  String get selectSupplier => translate('selectSupplier');
  String get addItem => translate('addItem');
  String get removeItem => translate('removeItem');
  String get orderItems => translate('orderItems');

  String get createProduct => translate('createProduct');
  String get editProduct => translate('editProduct');
  String get deleteProduct => translate('deleteProduct');

  String get createCategory => translate('createCategory');
  String get editCategory => translate('editCategory');
  String get deleteCategory => translate('deleteCategory');
  String get categoryName => translate('categoryName');
  String get categoryDescription => translate('categoryDescription');

  String get totalSpending => translate('totalSpending');
  String get pendingOrders => translate('pendingOrders');
  String get totalStaff => translate('totalStaff');
  String get lowStock => translate('lowStock');

  String get confirmDelete => translate('confirmDelete');
  String get deleteConfirmMessage => translate('deleteConfirmMessage');

  // Admin UI
  String get noStaffFound => translate('noStaffFound');
  String get noSuppliersFound => translate('noSuppliersFound');
  String get noProductsFound => translate('noProductsFound');
  String get noCategoriesFound => translate('noCategoriesFound');
  String get noAnalyticsData => translate('noAnalyticsData');
  String get noOrdersFound => translate('noOrdersFound');
  String get confirmPayment => translate('confirmPayment');
  String get uploadReceipt => translate('uploadReceipt');
  String get orderConfirmation => translate('orderConfirmation');
  String get billingNotes => translate('billingNotes');
  String get selectCategory => translate('selectCategory');
  String get noCategory => translate('noCategory');
  String get isActive => translate('isActive');
  String get roleAdmin => translate('roleAdmin');
  String get roleStaff => translate('roleStaff');
  String get supplierDescription => translate('supplierDescription');
  String get contactPerson => translate('contactPerson');
  String get supplierCity => translate('supplierCity');
  String get supplierCountry => translate('supplierCountry');
  String get minQuantity => translate('minQuantity');
  String get recommendedQuantity => translate('recommendedQuantity');
  String get unitLabel => translate('unitLabel');
  String get barcode => translate('barcode');
  String get imageUpload => translate('imageUpload');
  String get changeImage => translate('changeImage');
  String get categoryAnalytics => translate('categoryAnalytics');
  String get monthlyAnalytics => translate('monthlyAnalytics');
  String get all => translate('all');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
