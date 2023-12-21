﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Переводит текст на другой язык с использованием сервиса перевода текста.
//
// Параметры:
//  Текст        - Строка - произвольный текст.
//  ЯзыкПеревода - Строка - код языка в формате ISO 639-1, на который выполняется перевод.
//                          Например, "en".
//                          Если не указан, то перевод выполняется на текущий язык.
//  ИсходныйЯзык - Строка - код языка в формате ISO 639-1, с которого выполняется перевод.
//                          Например, "ru".
//                          Если не указан, то язык будет установлен сервисом перевода текста.
//
// Возвращаемое значение:
//  Строка
//
Функция ПеревестиТекст(Текст, ЯзыкПеревода = Неопределено, ИсходныйЯзык = Неопределено) Экспорт
	
	Если Не ЗначениеЗаполнено(Текст) Тогда
		Возврат Текст;
	КонецЕсли;
	
	Возврат ПеревестиТексты(ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(Текст), ЯзыкПеревода, ИсходныйЯзык)[Текст];
	
КонецФункции

// Переводит тексты на другой язык с использованием сервиса перевода текста.
//
// Параметры:
//  Тексты - Массив из Строка - произвольные тексты.
//  ЯзыкПеревода - Строка - код языка в формате ISO 639-1, на который выполняется перевод.
//                          Например, "en".
//                          Если не указан, то перевод выполняется на текущий язык.
//  ИсходныйЯзык - Строка - код языка в формате ISO 639-1, с которого выполняется перевод.
//                          Например, "ru".
//                          Если не указан, то язык будет установлен сервисом перевода текста.
//
// Возвращаемое значение:
//  Соответствие из КлючИЗначение:
//   * Ключ     - Строка - текст;
//   * Значение - Строка - перевод.
//
Функция ПеревестиТексты(Тексты, ЯзыкПеревода = Неопределено, ИсходныйЯзык = Неопределено) Экспорт
	
	ПроверитьНастройки();
	
	Если ЗначениеЗаполнено(ИсходныйЯзык) И ЯзыкПеревода = ИсходныйЯзык Тогда
		НайденныеПереводы = Новый Соответствие;
		Для Каждого Текст Из Тексты Цикл
			НайденныеПереводы.Вставить(Текст, Текст);
		КонецЦикла;
		Возврат НайденныеПереводы;
	КонецЕсли;
	
	НайденныеПереводы = НайтиПереводТекстов(Тексты, ЯзыкПеревода, ИсходныйЯзык);
	ТекстыТребующиеПеревод = Новый Массив;
	
	Для Каждого Текст Из Тексты Цикл
		Если ЗначениеЗаполнено(НайденныеПереводы[Текст]) Тогда
			Продолжить;
		КонецЕсли;
		Если ЗначениеЗаполнено(Текст) Тогда
			ТекстыТребующиеПеревод.Добавить(Текст);
		Иначе
			НайденныеПереводы.Вставить(Текст, Текст);
		КонецЕсли;
	КонецЦикла;
	
	Если Не ПолучитьФункциональнуюОпцию("ИспользоватьСервисПереводаТекста") Тогда
		Возврат НайденныеПереводы;
	КонецЕсли;
	
	МодульСервисаПереводаТекста = МодульСервисаПереводаТекста();
	
	ОчередьПеревода = Новый Массив;
	Порция = Новый Массив;
	РазмерПорции = 0;
	МаксимальныйРазмерПорции = МодульСервисаПереводаТекста.МаксимальныйРазмерПорции();
	
	Для Каждого Текст Из ТекстыТребующиеПеревод Цикл
		Если РазмерПорции + СтрДлина(Текст) <= МаксимальныйРазмерПорции Тогда
			Порция.Добавить(Текст);
			РазмерПорции = РазмерПорции + СтрДлина(Текст);
		Иначе
			ОчередьПеревода.Добавить(Порция);
			Порция = Новый Массив;
			РазмерПорции = 0;
		КонецЕсли;
	КонецЦикла;
	Если ЗначениеЗаполнено(Порция) Тогда
		ОчередьПеревода.Добавить(Порция);
	КонецЕсли;
	
	Для Каждого Порция Из ОчередьПеревода Цикл
		Попытка
			Переводы = МодульСервисаПереводаТекста.ПеревестиТексты(Порция, ЯзыкПеревода, ИсходныйЯзык);
		Исключение
			ЗаписьЖурналаРегистрации(НСтр("ru = 'Перевод текста'", ОбщегоНазначения.КодОсновногоЯзыка()), УровеньЖурналаРегистрации.Ошибка,
				Метаданные.Перечисления.СервисыПереводаТекста, Константы.СервисПереводаТекста.Получить(), ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
				
			Если Пользователи.ЭтоПолноправныйПользователь() Тогда
				ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр(
					"ru = 'Не удалось выполнить операцию по причине:
					|%1'"), КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
			Иначе
				ТекстОшибки = НСтр("ru = 'Не удалось выполнить операцию. Обратитесь к администратору.'");
			КонецЕсли;
			
			ВызватьИсключение ТекстОшибки;
		КонецПопытки;
		Для Каждого Перевод Из Переводы Цикл
			СохранитьПереводТекста(Перевод.Ключ, Перевод.Значение, ИсходныйЯзык, ЯзыкПеревода);
			НайденныеПереводы.Вставить(Перевод.Ключ, Перевод.Значение);
		КонецЦикла;
	КонецЦикла;
	
	Возврат НайденныеПереводы;
	
КонецФункции

// Возвращает список языков, поддерживаемых сервисом перевода текста.
//
// Возвращаемое значение:
//  СписокЗначений:
//   * Значение - код языка;
//   * Представление - представление языка.
//
Функция ДоступныеЯзыки() Экспорт
	
	ПредставленияЯзыков = Новый Соответствие;
	Для Каждого КодЯзыка Из ПолучитьДопустимыеКодыЛокализации() Цикл
		ПредставленияЯзыков.Вставить(КодЯзыка, ПредставлениеКодаЛокализации(КодЯзыка));
	КонецЦикла;
	
	Результат = Новый СписокЗначений;
	
	МодульСервисаПереводаТекста = МодульСервисаПереводаТекста();
	Если МодульСервисаПереводаТекста = Неопределено Тогда
		Возврат Результат;
	КонецЕсли;
	
	Попытка
		ДоступныеЯзыки = МодульСервисаПереводаТекста.ДоступныеЯзыки();
	Исключение
		ЗаписьЖурналаРегистрации(НСтр("ru = 'Перевод текста'", ОбщегоНазначения.КодОсновногоЯзыка()), УровеньЖурналаРегистрации.Ошибка,
			Метаданные.Перечисления.СервисыПереводаТекста, Константы.СервисПереводаТекста.Получить(), ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			
		Если Пользователи.ЭтоПолноправныйПользователь() Тогда
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр(
				"ru = 'Не удалось выполнить операцию по причине:
				|%1'"), КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
		Иначе
			ТекстОшибки = НСтр("ru = 'Не удалось выполнить операцию. Обратитесь к администратору.'");
		КонецЕсли;
		
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;
	
	Для Каждого КодЯзыка Из ДоступныеЯзыки Цикл
		Представление = ПредставленияЯзыков[КодЯзыка];
		Если ЗначениеЗаполнено(Представление) Тогда
			Результат.Добавить(КодЯзыка, ТРег(Представление));
		КонецЕсли;
	КонецЦикла;
	
	Результат.СортироватьПоПредставлению();
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Функция ДоступенПереводТекста() Экспорт
	
	Возврат ПолучитьФункциональнуюОпцию("ИспользоватьСервисПереводаТекста");
	
КонецФункции

Функция СервисПереводаТекста() Экспорт
	
	Возврат Константы.СервисПереводаТекста.Получить();
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция НайтиПереводТекстов(Тексты, ЯзыкПеревода, ИсходныйЯзык)
	
	ТекстыДляПоиска = Новый Массив;
	ИдентификаторыТекстов = Новый Соответствие;
	Для Каждого Текст Из Тексты Цикл
		ИдентификаторТекста = ИдентификаторТекста(Текст);
		ТекстыДляПоиска.Добавить(ИдентификаторТекста);
		ИдентификаторыТекстов.Вставить(Текст, ИдентификаторТекста);
	КонецЦикла;
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	КэшПереводов.Текст КАК Текст,
	|	КэшПереводов.Перевод КАК Перевод,
	|	КэшПереводов.ИсходныйЯзык КАК ИсходныйЯзык
	|ИЗ
	|	РегистрСведений.КэшПереводов КАК КэшПереводов
	|ГДЕ
	|	КэшПереводов.Текст В(&Текст)
	|	И КэшПереводов.ЯзыкПеревода = &ЯзыкПеревода
	|	И КэшПереводов.ИсходныйЯзык = &ИсходныйЯзык";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("Текст", ТекстыДляПоиска);
	Запрос.УстановитьПараметр("ЯзыкПеревода", ЯзыкПеревода);
	Запрос.УстановитьПараметр("ИсходныйЯзык", ИсходныйЯзык);
	
	ПереведенныеТексты = Новый Соответствие;
	
	УстановитьПривилегированныйРежим(Истина);
	Выборка = Запрос.Выполнить().Выбрать();
	УстановитьПривилегированныйРежим(Ложь);
	
	Пока Выборка.Следующий() Цикл
		ПереведенныеТексты.Вставить(Выборка.Текст, Выборка.Перевод);
	КонецЦикла;
	
	Результат = Новый Соответствие;
	Для Каждого Текст Из Тексты Цикл
		Результат.Вставить(Текст, ПереведенныеТексты[ИдентификаторыТекстов[Текст]]);
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Процедура СохранитьПереводТекста(Текст, Перевод, ИсходныйЯзык, ЯзыкПеревода)
	
	Если Не ЗначениеЗаполнено(Текст) Или Не ЗначениеЗаполнено(Перевод) Или Не ЗначениеЗаполнено(ЯзыкПеревода) Тогда
		Возврат;
	КонецЕсли;
	
	ИдентификаторТекста = ИдентификаторТекста(Текст);
	
	НаборЗаписей = РегистрыСведений.КэшПереводов.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Текст.Установить(ИдентификаторТекста);
	НаборЗаписей.Отбор.ЯзыкПеревода.Установить(ЯзыкПеревода);
	НаборЗаписей.Отбор.ИсходныйЯзык.Установить(ИсходныйЯзык);
	Запись = НаборЗаписей.Добавить();
	Запись.Текст = ИдентификаторТекста;
	Запись.ИсходныйЯзык = ИсходныйЯзык;
	Запись.ЯзыкПеревода = ЯзыкПеревода;
	Запись.Перевод = СокрЛП(Перевод);
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.КэшПереводов");
	ЭлементБлокировки.УстановитьЗначение("Текст", ИдентификаторТекста);
	ЭлементБлокировки.УстановитьЗначение("ИсходныйЯзык", ИсходныйЯзык);
	ЭлементБлокировки.УстановитьЗначение("ЯзыкПеревода", ЯзыкПеревода);
	
	УстановитьПривилегированныйРежим(Истина);
	
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		НаборЗаписей.Записать();
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

Функция ИдентификаторТекста(Знач Текст)
	
	Возврат ОбщегоНазначения.СократитьСтрокуКонтрольнойСуммой(НРег(СокрЛП(Текст)), 50);
	
КонецФункции

Функция ПредставлениеЯзыка(КодЯзыка) Экспорт
	
	Если ПолучитьДопустимыеКодыЛокализации().Найти(КодЯзыка) <> Неопределено Тогда
		Возврат ПредставлениеКодаЛокализации(КодЯзыка);
	КонецЕсли;
	
	Возврат "";
	
КонецФункции

Функция МодульСервисаПереводаТекста(Знач СервисПереводаТекста = Неопределено)
	
	Если СервисПереводаТекста = Неопределено Тогда
		СервисПереводаТекста = Константы.СервисПереводаТекста.Получить();
	КонецЕсли;
	
	Возврат МодулиСервисовПереводаТекста()[СервисПереводаТекста];
	
КонецФункции

// Имена модулей соответствуют именам значений перечисления СервисыПереводаТекста.
Функция МодулиСервисовПереводаТекста()
	
	Результат = Новый Соответствие;
	
	Для Каждого ОбъектМетаданных Из Метаданные.Перечисления.СервисыПереводаТекста.ЗначенияПеречисления Цикл
		ИмяМодуля = ОбъектМетаданных.Имя;
		Если Метаданные.ОбщиеМодули.Найти(ИмяМодуля) <> Неопределено Тогда
			Результат.Вставить(Перечисления.СервисыПереводаТекста[ОбъектМетаданных.Имя], ОбщегоНазначения.ОбщийМодуль(ИмяМодуля));
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Процедура ПроверитьНастройки()
	
	МодульСервисаПереводаТекста = МодульСервисаПереводаТекста();
	Если МодульСервисаПереводаТекста = Неопределено Или Не МодульСервисаПереводаТекста.НастройкаВыполнена() Тогда
		ВызватьИсключение НСтр("ru = 'Не указаны настройки сервиса перевода текстов.'");
	КонецЕсли;
	
КонецПроцедуры

// Возвращаемое значение:
//  Структура:
//   * ИнструкцияПоПодключению - Строка
//   * ПараметрыАвторизации - см. ПараметрыАвторизации
//
Функция НастройкиСервисаПереводаТекста(СервисПереводаТекста) Экспорт
	
	Настройки = Новый Структура;
	Настройки.Вставить("ИнструкцияПоПодключению");
	Настройки.Вставить("ПараметрыАвторизации", ПараметрыАвторизации());
	МодульСервисаПереводаТекста(СервисПереводаТекста).ПриОпределенииНастроек(Настройки);
	
	Возврат Настройки;
	
КонецФункции

// Возвращаемое значение:
//  ТаблицаЗначений:
//   * Имя - Строка
//   * Представление - Строка
//   * Подсказка - Строка
//   * ОтображениеПодсказки - ОтображениеПодсказки
//
Функция ПараметрыАвторизации()
	
	Результат = Новый ТаблицаЗначений;
	Результат.Колонки.Добавить("Имя");
	Результат.Колонки.Добавить("Представление");
	Результат.Колонки.Добавить("Подсказка");
	Результат.Колонки.Добавить("ОтображениеПодсказки", Новый ОписаниеТипов("ОтображениеПодсказки"));
	
	Возврат Результат;
	
КонецФункции

Функция НастройкиАвторизации(Знач СервисПереводаТекста = Неопределено) Экспорт
	
	МодульСервисаПереводаТекста = МодульСервисаПереводаТекста(СервисПереводаТекста);
	Если МодульСервисаПереводаТекста = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат МодульСервисаПереводаТекста(СервисПереводаТекста).НастройкиАвторизации();
	
КонецФункции

#КонецОбласти
