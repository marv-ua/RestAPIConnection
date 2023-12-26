﻿Перем URLСервиса;
Перем Лог;
Перем этоФоновоеЗадание;
Перем ИдентификаторЗадания;
Перем АдресПолучателяДляЛогов;

Процедура ЗапуститьВыполнение() Экспорт
	
	Если ПустаяСтрока(URLСервиса) Тогда
		Возврат;
	КонецЕсли;
	этоФоновоеЗадание = этоФоновоеЗадание();
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-Type", "application/json");

	ДопПараметрыЗапроса = Новый Структура;
	ДопПараметрыЗапроса.Вставить("Метод"                   , "GET");
	ДопПараметрыЗапроса.Вставить("Заголовки"               , Заголовки);
	ДопПараметрыЗапроса.Вставить("ФорматОтвета"            , 1);
	
	Очередь = ПрочитатьОчередь();
	Для Каждого Запись Из Очередь Цикл
		Лог = "";
		Отказ = Ложь;

		Если ПустаяСтрока(Запись.Адрес) Тогда
			Лог = "Empty address";
			ЗаписатьЛог(Запись, Отказ);
			Запись.Успех = Истина;
			Продолжить;
		КонецЕсли;
		
			
		РезультатОперации = dev_КоннекторHTTP.ЗагрузитьСодержимоеИзИнтернет(
			СтрШаблон(URLСервиса, Запись.Адрес),
			,
			,
			ДопПараметрыЗапроса
		);
		
				
		Если РезультатОперации.КодСостояния = 200 Тогда
			СтруктураОтвета = JSONВЗначение(РезультатОперации.Содержимое);
			Если СтруктураОтвета.Свойство("items") Тогда
				Если ТипЗнч(СтруктураОтвета.items) = Тип("Массив") Тогда
					Если СтруктураОтвета.items.Количество() Тогда
						Результат = СтруктураОтвета.items[0];
						ЗаписатьНормализованныйАдрес(Запись.Контрагент, Запись.Период, Результат, Отказ);
					Иначе
						ДобавитьОшибку(
							СтрШаблон(
								НСтр("ru = 'Неверный ответ по Контрагенту %1 с адресом %2'; en = 'Invalid response for Counterparty %1 with address %2'"),
								Запись.Контрагент,
								Запись.Адрес
							),
							Отказ
						);
					КонецЕсли;
				Иначе
					ДобавитьОшибку(
						СтрШаблон(
							НСтр("ru = 'Неверный ответ по Контрагенту %1 с адресом %2'; en = 'Invalid response for Counterparty %1 with address %2'"),
							Запись.Контрагент,
							Запись.Адрес
						),
						Отказ
					);
				КонецЕсли;
			КонецЕсли;
			
		Иначе
			ДобавитьОшибку(
				СтрШаблон(
					"Response code: %1
					|Error code: %2
					|Error message: %3",
					РезультатОперации.КодСостояния,
					РезультатОперации.КодОшибки,
					РезультатОперации.СообщениеОбОшибке
				),
				Отказ
			);
		КонецЕсли;
		
		Запись.Успех = Не Отказ;
		ЗаписатьЛог(Запись, Отказ);
	
	КонецЦикла;
	
	УдалитьИзОчереди(Очередь);
	ОтправитьЛоги();

КонецПроцедуры

Процедура ЗаписатьНормализованныйАдрес(Контрагент, Период, Результат, Отказ)
	
	Менеджер = РегистрыСведений.dev_АдресныеСведенияКонтрагентов.СоздатьМенеджерЗаписи();
	Менеджер.Период = Период;
	Менеджер.Контрагент = Контрагент;

	Результат.Свойство("title", Менеджер.ПредставлениеАдреса);
	Если Результат.Свойство("address") Тогда
		Адрес = Результат.address;
		Адрес.Свойство("postalCode", Менеджер.Индекс);
		Если Адрес.Свойство("countryCode") И Адрес.Свойство("countryName") Тогда
			Менеджер.Страна = ПолучитьСтрану(Адрес.countryCode, Адрес.countryName, Отказ);
		Иначе
			ДобавитьОшибку(
				СтрШаблон(
					НСтр("ru = 'Ответ от сервиса не вернул данные по стране для адреса %1'; en = 'the response from the service did not return country data for the address %1'"),
					Менеджер.ПредставлениеАдреса
				),
				Отказ
			);
		КонецЕсли;
		Адрес.Свойство("city", Менеджер.Город);
		Адрес.Свойство("street", Менеджер.Улица);
		Адрес.Свойство("houseNumber", Менеджер.Дом);

	КонецЕсли;
	
	Если Не Отказ Тогда
		Менеджер.Записать();
	КонецЕсли;

КонецПроцедуры

// Функция - Получить страну
// Получает страну из справочника СтраныМира, если записи нет - создает
//
// Параметры:
//  Код			 - Строка - 
//  Наименование - Строка - 
//  Отказ		 - Булево - 
// 
// Возвращаемое значение:
//   - 
//
Функция ПолучитьСтрану(Код, Наименование, Отказ)
	
	спрСтрана = Справочники.СтраныМира.НайтиПоРеквизиту("КодАльфа3", Код);
	Если Не ЗначениеЗаполнено(спрСтрана) Тогда
		спрСтрана = Справочники.СтраныМира.НайтиПоКоду(Код);
		Если Не ЗначениеЗаполнено(спрСтрана) Тогда
			Об = Справочники.СтраныМира.СоздатьЭлемент();
			Об.КодАльфа3 = Код;
			Об.Код = Код;
			Об.Наименование = Наименование;
			Об.НаименованиеПолное = Наименование;
			Попытка
				Об.Записать();
			Исключение
				ДобавитьОшибку(ОписаниеОшибки(), Отказ);
				Возврат Справочники.СтраныМира.ПустаяСсылка();
			КонецПопытки;
		Иначе
			Возврат спрСтрана;
		КонецЕсли;
	КонецЕсли;
	
	Возврат спрСтрана;
	
КонецФункции

Функция JSONВЗначение(Строка, ИменаСвойствСоЗначениямиДата = Неопределено)
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(Строка);
	Возврат ПрочитатьJSON(ЧтениеJSON, Ложь, ИменаСвойствСоЗначениямиДата);
КонецФункции

Функция ПрочитатьОчередь()
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Очередь.Контрагент КАК Контрагент,
	               |	ЕСТЬNULL(Адреса.Период, ДАТАВРЕМЯ(1, 1, 1)) КАК Период,
	               |	ЕСТЬNULL(Адреса.Адрес, """") КАК Адрес,
	               |	ЛОЖЬ КАК Успех,
	               |	Очередь.Идентификатор КАК Идентификатор
	               |ИЗ
	               |	РегистрСведений.dev_ОчередьНормализацииАдресовКонтрагентов КАК Очередь
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.dev_АдресаКонтрагентов КАК Адреса
	               |		ПО Очередь.Контрагент = Адреса.Контрагент";
	
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

Процедура УдалитьИзОчереди(Очередь)
	
	МассивКонтрагентов = Очередь.ВыгрузитьКолонку("Контрагент");
	Очередь.Индексы.Добавить("Контрагент");
	Очередь.Свернуть("Контрагент,Успех");
	Для Каждого Элемент Из МассивКонтрагентов Цикл
		МассивСтрок = Очередь.НайтиСтроки(Новый Структура("Контрагент", Элемент));
		Если МассивСтрок.Количество() = 1 Тогда
			Если МассивСтрок[0].Успех Тогда
				НаборЗаписей = РегистрыСведений.dev_ОчередьНормализацииАдресовКонтрагентов.СоздатьНаборЗаписей();
				НаборЗаписей.Отбор.Контрагент.Установить(Элемент);
				Попытка
					НаборЗаписей.Записать();
				Исключение
					ДобавитьОшибку(ОписаниеОшибки());
				КонецПопытки;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

// Процедура - Инициализировать
// Инициализация переменных модуля
//
Процедура Инициализировать()
	
	URLСервиса = "";
	
	Спр = ПредопределенноеЗначение("Справочник.dev_НастройкиПодключенийКСервисам.GeocodingSearchAPI");
	Если ЗначениеЗаполнено(Спр.Адрес) Тогда
		СтрАдрес = СокрЛП(Спр.Адрес);
		Если Не ПустаяСтрока(Спр.Метод) Тогда
			Если Не Прав(СтрАдрес, 1) = "/" Тогда
				СтрАдрес = СтрАдрес + "/";
			КонецЕсли;
			СтрАдрес = СтрАдрес + СокрЛП(Спр.Метод) + ?(Спр.Параметры.Количество(), "?", "");
		КонецЕсли;
		
		СтрокаПараметров = "";
		Для Каждого Параметр Из Спр.Параметры Цикл
			СтрокаПараметров = СтрокаПараметров + Параметр.Ключ + "=" + Параметр.Значение + "&";
		КонецЦикла;
		Если Не ПустаяСтрока(СтрокаПараметров) Тогда
			СтрокаПараметров = Лев(СтрокаПараметров, СтрДлина(СтрокаПараметров) - 1);
		КонецЕсли;
		
		URLСервиса = СтрАдрес + СтрокаПараметров;
		
		АдресПолучателяДляЛогов = Спр.АдресДляЛогов;

	КонецЕсли;
	
КонецПроцедуры

Процедура ДобавитьОшибку(мОшибка, Отказ = Ложь)
	
	Лог	= Лог 
			+ ?(ПустаяСтрока(Лог), "", Символы.ПС)
			+ мОшибка;
	Если Не этоФоновоеЗадание Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(мОшибка);
	КонецЕсли;
		
	Отказ = Истина;
	
КонецПроцедуры

// Функция - Это фоновое задание
// Проверяет является ли текущий сеанс фоновым заданием
// 
// Возвращаемое значение:
// Булево - 
//
Функция ЭтоФоновоеЗадание() Экспорт 
	
	НомерСеанса = НомерСеансаИнформационнойБазы();
	Сеансы = ПолучитьСеансыИнформационнойБазы();
	
	Для Каждого Сеанс Из Сеансы Цикл
		
		Если Сеанс.НомерСеанса = НомерСеанса Тогда
			
			Результат = (НРег(Сеанс.ИмяПриложения) = НРег("BackgroundJob"));
			Прервать;
			
		КонецЕсли; 
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Процедура ЗаписатьЛог(Данные, Отказ)
	
	Менеджер = РегистрыСведений.dev_ЛогНормализацииАдресовКонтрагентов.СоздатьМенеджерЗаписи();
	ЗаполнитьЗначенияСвойств(Менеджер, Данные,, "Период");
	Менеджер.Период = ТекущаяДата();
	Менеджер.Успешно = Не Отказ;
	Менеджер.ОписаниеОшибки = Лог;
	Менеджер.ИдентификаторЗадания = ИдентификаторЗадания;
	
	Попытка
		Менеджер.Записать();
	Исключение
		ЗаписьЖурналаРегистрации("Geocoding & Search API",, Метаданные.РегистрыСведений.dev_ЛогНормализацииАдресовКонтрагентов,, ОписаниеОшибки());
	КонецПопытки;
	

	
КонецПроцедуры

// Процедура - Отправить логи
// отправляет логи на адрес электронной почты
//
Процедура ОтправитьЛоги()
	
	Построитель = Новый ПостроительОтчета;
	Построитель.Текст = "ВЫБРАТЬ
	               |	Т.*
	               |ИЗ
	               |	РегистрСведений.dev_ЛогНормализацииАдресовКонтрагентов КАК Т
	               |ГДЕ
	               |	Т.ИдентификаторЗадания = &ИдентификаторЗадания";
	Построитель.Параметры.Вставить("ИдентификаторЗадания", ИдентификаторЗадания);
	Построитель.ЗаполнитьНастройки();
	Построитель.Выполнить();
	Построитель.ВыводитьЗаголовокОтчета = Истина;
	Построитель.ТекстЗаголовка = "Counterparty address normalisation log";
	
	ТабДок = Новый ТабличныйДокумент;
	Построитель.Вывести(ТабДок);
	Адрес = ПоместитьВоВременноеХранилище(ТабДок);
	
	УчетнаяЗапись = Справочники.УчетныеЗаписиЭлектроннойПочты.СистемнаяУчетнаяЗаписьЭлектроннойПочты;
	
	Если ЗначениеЗаполнено(АдресПолучателяДляЛогов) Тогда
		Попытка
			ОтправитьТабличныйДокументЭлектроннойПочтойКакPDF(
				Справочники.УчетныеЗаписиЭлектроннойПочты.СистемнаяУчетнаяЗаписьЭлектроннойПочты,
				АдресПолучателяДляЛогов,
				"Counterparty address normalisation log, Job ID: " + ИдентификаторЗадания,
				"Counterparty address normalisation log",
				Адрес
			);
		Исключение
			ЗаписьЖурналаРегистрации("Geocoding & Search API.log sending",,,, ОписаниеОшибки());
		КонецПопытки;
	КонецЕсли;
	
КонецПроцедуры

// Функция - Отправить табличный документ электронной почтой как PDF
//
// Параметры:
//  УчетнаяЗаписьПочтыОтправителя				 - СправочникСсылка.УчетныеЗаписиЭлектроннойПочты - 
//  ПочтаПолучателя								 - Строка - 
//  ТекстПисьма									 - Строка - 
//  ТемаПисьма									 - Строка - 
//  АдресТабличногоДокументаВоВременномХранилище - Строка - 
// 
// Возвращаемое значение:
// Булево - 
//
Функция ОтправитьТабличныйДокументЭлектроннойПочтойКакPDF(УчетнаяЗаписьПочтыОтправителя, ПочтаПолучателя, ТекстПисьма, ТемаПисьма, АдресТабличногоДокументаВоВременномХранилище)

	Отправлено = Ложь;
	
	Если УчетнаяЗаписьПочтыОтправителя = Неопределено Или УчетнаяЗаписьПочтыОтправителя.Пустая() Тогда
		
		Возврат Отправлено;
		
	КонецЕсли;
	
	ТабДок = ПолучитьИзВременногоХранилища(АдресТабличногоДокументаВоВременномХранилище);
	
	ПотокФайла = Новый ПотокВПамяти();
	ТабДок.Записать(ПотокФайла, ТипФайлаТабличногоДокумента.PDF);
	
	ДвоичныеДанныеФайла = ПотокФайла.ЗакрытьИПолучитьДвоичныеДанные();
	
	ВременноеХранилищеФайла = ПоместитьВоВременноеХранилище(ДвоичныеДанныеФайла, Новый УникальныйИдентификатор);
	
	Вложения = Новый Массив;
	
	ОписаниеВложения = Новый Структура("Представление, АдресВоВременномХранилище", ТекстПисьма + ".pdf", ВременноеХранилищеФайла);
	
	Вложения.Добавить(ОписаниеВложения);
	
	ПараметрыПисьма = Новый Структура;
	ПараметрыПисьма.Вставить("Кому", ПочтаПолучателя);
	ПараметрыПисьма.Вставить("Тема", ТемаПисьма);
	ПараметрыПисьма.Вставить("Тело", ТекстПисьма);
	ПараметрыПисьма.Вставить("ТипТекста", "ПростойТекст");
	ПараметрыПисьма.Вставить("Вложения", Вложения);
	
	Попытка
		
		Идентификатор = РаботаСПочтовымиСообщениями.ОтправитьПочтовоеСообщение(УчетнаяЗаписьПочтыОтправителя, ПараметрыПисьма);
		
		Если ЗначениеЗаполнено(Идентификатор) Тогда
			
			Отправлено = Истина;
			
		КонецЕсли;
		
	Исключение
		
		ЗаписьЖурналаРегистрации("Отправка письма " + ПочтаПолучателя, УровеньЖурналаРегистрации.Ошибка,,,ОписаниеОшибки());
		
	КонецПопытки;
	
	Возврат Отправлено;

КонецФункции

Инициализировать();
ИдентификаторЗадания = Новый УникальныйИдентификатор;