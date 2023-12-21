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
	
	ИмяСобытияЖурналаРегистрации = БлокировкаРаботыСВнешнимиРесурсами.ИмяСобытияЖурналаРегистрации();
	
	ПараметрыБлокировки = БлокировкаРаботыСВнешнимиРесурсами.СохраненныеПараметрыБлокировки();
	ПроверятьИмяСервера = ПараметрыБлокировки.ПроверятьИмяСервера;
	
	Если Параметры.ПринятиеРешенияОБлокировке Тогда
		
		ТекстСнятияБлокировки = РегламентныеЗаданияСлужебный.ЗначениеНастройки("РасположениеКомандыСнятияБлокировки");
		РазделениеВключено = ОбщегоНазначения.РазделениеВключено();
		ИзменилосьРазделение = ПараметрыБлокировки.РазделениеВключено <> РазделениеВключено;
		
		Если РазделениеВключено Тогда
			Элементы.ИнформационнаяБазаПеремещена.Заголовок = НСтр("ru = 'Приложение перемещено'");
			Элементы.ЭтоКопияИнформационнойБазы.Заголовок = НСтр("ru = 'Это копия приложения'");
			Заголовок = НСтр("ru = 'Приложение было перемещено или восстановлено из резервной копии'");
		КонецЕсли;
		
		Если Не РазделениеВключено И Не ИзменилосьРазделение Тогда
			
			УточнениеМасштабируемыйКластер = ?(ОбщегоНазначения.ИнформационнаяБазаФайловая(), "",
				НСтр("ru = '• При работе в масштабируемом кластере для предотвращения ложных срабатываний из-за смены компьютеров, выступающих
				           |  в роли рабочих серверов, отключите проверку имени компьютера, нажмите <b>Еще - Проверять имя сервера.</b>'"));
			
			НадписьПредупреждение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Работа со всеми внешними ресурсами (синхронизация данных, отправка почты и т.п.), выполняемая по расписанию,
				           |заблокирована для предотвращения конфликтов с основной информационной базой.
				           |
				           |%1
				           |
				           |<a href = ""ЖурналРегистрации"">Техническая информация о причине блокировки</a>
				           |
				           |• Если информационная база будет использоваться для ведения учета, нажмите <b>Информационная база перемещена</b>.
				           |• Если это копия информационной базы, нажмите <b>Это копия информационной базы</b>.
				           |%2
				           |
				           |%3'"),
				ПараметрыБлокировки.ПричинаБлокировки,
				УточнениеМасштабируемыйКластер,
				ТекстСнятияБлокировки);
		ИначеЕсли Не РазделениеВключено И ИзменилосьРазделение Тогда
			НадписьПредупреждение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Работа со всеми внешними ресурсами (синхронизация данных, отправка почты и т.п.), выполняемая по расписанию,
				           |заблокирована для предотвращения конфликтов с приложением в Интернете.
				           |
				           |<b>Информационная база была загружена из приложения в Интернете</b>
				           |
				           |• Если информационная база будет использоваться для ведения учета, нажмите <b>Информационная база перемещена</b>.
				           |• Если это копия информационной базы, нажмите <b>Это копия информационной базы</b>.
				           |
				           |%1'"),
				ТекстСнятияБлокировки);
		ИначеЕсли РазделениеВключено И Не ИзменилосьРазделение Тогда
			НадписьПредупреждение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Работа со всеми внешними ресурсами (синхронизация данных, отправка почты и т.п.), выполняемая по расписанию,
				           |заблокирована для предотвращения конфликтов с приложением в Интернете.
				           |
				           |<b>Приложение было перемещено</b>
				           |
				           |• Если приложение будет использоваться для ведения учета, нажмите <b>Приложение перемещено</b>.
				           |• Если это копия приложения, нажмите <b>Это копия приложения</b>.
				           |
				           |%1'"),
				ТекстСнятияБлокировки);
		Иначе // Если РазделениеВключено И ИзменилосьРазделение
			НадписьПредупреждение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Работа со всеми внешними ресурсами (синхронизация данных, отправка почты и т.п.), выполняемая по расписанию,
				           |заблокирована для предотвращения конфликтов с локальной версией.
				           |
				           |Приложение было загружено из локальной версии
				           |
				           |• Если приложение будет использоваться для ведения учета, нажмите <b>Приложение перемещено</b>.
				           |• Если это копия приложения, нажмите <b>Это копия приложения</b>.
				           |
				           |%1'"),
				ТекстСнятияБлокировки);
		КонецЕсли;
		
		Элементы.НадписьПредупреждение.Заголовок = СтроковыеФункции.ФорматированнаяСтрока(НадписьПредупреждение);
		
		Если ОбщегоНазначения.ИнформационнаяБазаФайловая() Тогда
			Элементы.ФормаГруппаЕще.Видимость = Ложь;
		Иначе
			Элементы.ФормаПроверятьИмяСервера.Пометка = ПроверятьИмяСервера;
			Элементы.ФормаСправка.Видимость = Ложь;
		КонецЕсли;
		
	Иначе
		Элементы.ГруппаПараметрыФормы.ТекущаяСтраница = Элементы.ГруппаПараметрыБлокировки;
		Элементы.НадписьПредупреждение.Видимость = Ложь;
		Элементы.ЗаписатьИЗакрыть.КнопкаПоУмолчанию = Истина;
		Заголовок = НСтр("ru = 'Параметры блокировки работы с внешними ресурсами'");
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура НадписьПредупреждениеОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("СобытиеЖурналаРегистрации", ИмяСобытияЖурналаРегистрации);
	ОткрытьФорму("Обработка.ЖурналРегистрации.Форма.ЖурналРегистрации", ПараметрыФормы);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ИнформационнаяБазаПеремещена(Команда)
	
	РазрешитьРаботуСВнешнимиРесурсами();
	СтандартныеПодсистемыКлиент.УстановитьРасширенныйЗаголовокПриложения();
	ОбновитьИнтерфейс();
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура ЭтоКопияИнформационнойБазы(Команда)
	
	ЗапретитьРаботуСВнешнимиРесурсами();
	СтандартныеПодсистемыКлиент.УстановитьРасширенныйЗаголовокПриложения();
	ОбновитьИнтерфейс();
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверятьИмяСервера(Команда)
	
	ПроверятьИмяСервера = Не ПроверятьИмяСервера;
	Элементы.ФормаПроверятьИмяСервера.Пометка = ПроверятьИмяСервера;
	УстановитьПроверкуИмениСервераВПараметрыБлокировки(ПроверятьИмяСервера);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьИЗакрыть(Команда)
	
	УстановитьПроверкуИмениСервераВПараметрыБлокировки(ПроверятьИмяСервера);
	Закрыть();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Процедура РазрешитьРаботуСВнешнимиРесурсами()
	
	БлокировкаРаботыСВнешнимиРесурсами.РазрешитьРаботуСВнешнимиРесурсами();
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ЗапретитьРаботуСВнешнимиРесурсами()
	
	БлокировкаРаботыСВнешнимиРесурсами.ЗапретитьРаботуСВнешнимиРесурсами();
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура УстановитьПроверкуИмениСервераВПараметрыБлокировки(ПроверятьИмяСервера)
	
	БлокировкаРаботыСВнешнимиРесурсами.УстановитьПроверкуИмениСервераВПараметрыБлокировки(ПроверятьИмяСервера);
	
КонецПроцедуры

#КонецОбласти
