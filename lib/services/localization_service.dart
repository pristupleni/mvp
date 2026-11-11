enum AppLanguage { ru, ky }

class LocalizationService {
  static final Map<String, Map<String, String>> _localizedValues = {
    'ru': {
      'app_title': 'SmartSklad B2B',
      'warehouse': 'Склад',
      'raw_materials': 'Товары & Гаджеты',
      'auto_purchase': 'Авто-закуп',
      'debts': 'Долги',
      'profile': 'Профиль',
      'contacts': 'Контакты',
      'cost_calculator': 'Калькулятор маржинальности и карго',
      'audit_logs': 'История операций и аудит',
      'stock_in': 'Приход (+)',
      'stock_out': 'Продажа (-)',
      'receivables': 'Мне должны',
      'payables': 'Я должен',
      'add_product': 'Добавить новый товар',
      'add_debt': 'Записать долг',
      'add_contact': 'Добавить контакт',
      'import_sheets': 'Импорт из Google Таблиц',
      'scan_qr': 'Сканировать QR-код',
      'search_hint': 'Поиск клавиатур, чехлов, подставок, гаджетов...',
      'days_left': 'Хватит на {days} дней',
      'online': 'Онлайн',
      'offline': 'Офлайн режим',
      'role_workshop': 'Магазин электроники / Продавец',
      'role_wholesaler': 'Оптовый поставщик (Дордой)',
      'export_excel': 'Экспорт Excel',
      'export_pdf': 'Экспорт PDF',
      'batch_quantity': 'Размер партии (шт.)',
      'fabric_consumption': 'Вес/объем на 1 шт. (кг)',
      'fabric_price': 'Закупочная цена в Китае (KGS/USD)',
      'accessories_cost': 'Карго и доставка за 1 шт. (KGS)',
      'tailor_wage': 'Упаковка и наклейка штрихкода (KGS)',
      'extra_costs': 'Прочие расходы на партию (KGS)',
      'unit_cost': 'Себестоимость 1 шт. с доставкой',
      'total_batch_cost': 'Общая стоимость закупки партии',
      'recommended_price': 'Рекомендуемая розничная цена (+40%)',
    },
    'ky': {
      'app_title': 'SmartSklad B2B',
      'warehouse': 'Склад',
      'raw_materials': 'Товарлар жана гаджеттер',
      'auto_purchase': 'Авто-сатып алуу',
      'debts': 'Карыздар',
      'profile': 'Профиль',
      'contacts': 'Контакттар',
      'cost_calculator': 'Маржа жана карго калькулятору',
      'audit_logs': 'Операциялар тарыхы жана аудит',
      'stock_in': 'Кириш (+)',
      'stock_out': 'Сатуу (-)',
      'receivables': 'Мага карыз',
      'payables': 'Мен карызмын',
      'add_product': 'Жаңы товар кошуу',
      'add_debt': 'Карыз жазуу',
      'add_contact': 'Контакт кошуу',
      'import_sheets': 'Google Таблицадан импорттоо',
      'scan_qr': 'QR-код сканерлөө',
      'search_hint': 'Клавиатура, чехол, подставка, гаджет издөө...',
      'days_left': '{days} күнгө жетет',
      'online': 'Онлайн',
      'offline': 'Офлайн режим',
      'role_workshop': 'Электроника дүкөнү / Сатуучу',
      'role_wholesaler': 'Дордой оптовиги',
      'export_excel': 'Excel экспорттоо',
      'export_pdf': 'PDF экспорттоо',
      'batch_quantity': 'Партиянын саны (даана)',
      'fabric_consumption': '1 даананын салмагы/көлөмү (кг)',
      'fabric_price': 'Кытайдагы сатып алуу баасы (сом/USD)',
      'accessories_cost': '1 даанага карго жана жеткирүү (сом)',
      'tailor_wage': 'Упаковка жана штрихкод (сом)',
      'extra_costs': 'Кошумча чыгымдар (сом)',
      'unit_cost': '1 даананын жеткирүүсү менен өздүк наркы',
      'total_batch_cost': 'Партиянын жалпы баасы',
      'recommended_price': 'Сунушталган чекене баасы (+40%)',
    },
  };

  static String tr(AppLanguage lang, String key, {Map<String, String>? args}) {
    final langCode = lang == AppLanguage.ky ? 'ky' : 'ru';
    String value = _localizedValues[langCode]?[key] ?? _localizedValues['ru']?[key] ?? key;
    if (args != null) {
      args.forEach((k, v) {
        value = value.replaceAll('{$k}', v);
      });
    }
    return value;
  }
}
