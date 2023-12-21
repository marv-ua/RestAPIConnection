﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ОписаниеСистемы = Новый СистемнаяИнформация;
	Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии("8.3.17.0", ОписаниеСистемы.ВерсияПриложения) > 0 Тогда
		ВызватьИсключение НСтр("ru='Форма не предназначена для использования с платформой версии ниже 8.3.17'");
	КонецЕсли;
	
	ТипыВнешнихСистем = ОбсужденияСлужебныйКлиентСервер.ТипыВнешнихСистем();
	
	Телеграмм = СписокПодключений.ПолучитьЭлементы().Добавить();
	Телеграмм.Наименование = НСтр("ru='Чаты Telegram'");
	Телеграмм.Активно = -1;
	Телеграмм.Тип = ТипыВнешнихСистем.Телеграм;
	
	ВКонтакте = СписокПодключений.ПолучитьЭлементы().Добавить();
	ВКонтакте.Наименование = НСтр("ru='Чаты ВКонтакте'");
	ВКонтакте.Активно = -1;
	ВКонтакте.Тип = ТипыВнешнихСистем.ВКонтакте;
	
	ОбновитьСписокИнтеграций();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СоздатьБотаТелеграмм(Команда)
	Оповещение = Новый ОписаниеОповещения("ПослеИзмененияИнтеграции", ЭтотОбъект);
	ОбсужденияСлужебныйКлиент.ПоказатьИнформациюОбИнтеграции(ЭтотОбъект, 
		Новый Структура("Тип", ОбсужденияСлужебныйКлиентСервер.ТипыВнешнихСистем().Телеграм),
		Оповещение);
КонецПроцедуры

&НаКлиенте
Процедура СоздатьБотаВКонтакте(Команда)
	Оповещение = Новый ОписаниеОповещения("ПослеИзмененияИнтеграции", ЭтотОбъект);
	ОбсужденияСлужебныйКлиент.ПоказатьИнформациюОбИнтеграции(ЭтотОбъект, 
		Новый Структура("Тип", ОбсужденияСлужебныйКлиентСервер.ТипыВнешнихСистем().ВКонтакте),
		Оповещение);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПослеИзмененияИнтеграции(Результат, ДополнительныеПараметры) Экспорт
	ОбновитьСписокИнтеграций();	
КонецПроцедуры

&НаСервере
Процедура ОбновитьСписокИнтеграций()

	ТипыИнтеграции = Новый Соответствие;
	
	Для каждого ТипИнтеграции Из СписокПодключений.ПолучитьЭлементы() Цикл
		ТипИнтеграции.ПолучитьЭлементы().Очистить();
		ТипыИнтеграции.Вставить(ТипИнтеграции.Тип, ТипИнтеграции);
	КонецЦикла;
	
	Для каждого Интеграция Из Вычислить("СистемаВзаимодействия.ПолучитьИнтеграции()") Цикл // АПК:488-безопасный код
		
		Категория = ТипыИнтеграции[Интеграция.ТипВнешнейСистемы];
		Если Категория <> Неопределено Тогда
			НоваяИнтеграция = Категория.ПолучитьЭлементы().Добавить();
			ИнтеграцияВДанныеФормы(Интеграция, НоваяИнтеграция);	
		Иначе
		    ЗаписьЖурналаРегистрации(ОбсужденияСлужебный.СобытиеЖурналаРегистрации(),
				УровеньЖурналаРегистрации.Ошибка,,,
				НСтр("ru='Не поддерживаемый тип внешней интеграции'"));
		КонецЕсли;
			
	КонецЦикла;

КонецПроцедуры

// Параметры:
//  Интеграция - ИнтеграцияСистемыВзаимодействия 
//  ДанныеФормы - ДанныеФормыЭлементДерева из см. Обработка.ПодключениеОбсуждений.Форма.НастройкиСообщенийИзДругихПрограмм.СписокПодключений
//
&НаСервере
Процедура ИнтеграцияВДанныеФормы(Знач Интеграция, Знач ДанныеФормы)
	
	ДанныеФормы.Активно = ?(Интеграция.Использование, 0, 2);
	ДанныеФормы.Наименование = Интеграция.Представление;
	ДанныеФормы.Идентификатор = Интеграция.Идентификатор;
	ДанныеФормы.Тип = Интеграция.ТипВнешнейСистемы;

КонецПроцедуры

&НаКлиенте
Процедура СписокПодключенийВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	
	Интеграция = СписокПодключений.НайтиПоИдентификатору(ВыбраннаяСтрока);
	Если Интеграция.Идентификатор = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Оповещение = Новый ОписаниеОповещения("ПослеИзмененияИнтеграции", ЭтотОбъект);
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Тип", Интеграция.Тип);
	ПараметрыФормы.Вставить("Идентификатор", Интеграция.Идентификатор);
	ОбсужденияСлужебныйКлиент.ПоказатьИнформациюОбИнтеграции(
		ЭтотОбъект, 
		ПараметрыФормы,
		Оповещение);
КонецПроцедуры

&НаКлиенте
Процедура Обновить(Команда)
	ОбновитьНаСервере();
КонецПроцедуры

&НаСервере
Процедура ОбновитьНаСервере()
	ОбновитьСписокИнтеграций();
КонецПроцедуры

#КонецОбласти
