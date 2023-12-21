﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Обработчики обновления.

// Регистрирует на плане обмена ОбновлениеИнформационнойБазы объекты,
// для которых необходимо обновить записи в регистре.
//
Процедура ЗарегистрироватьДанныеКОбработкеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВерсииФайлов.Ссылка
		|ИЗ
		|	Справочник.ВерсииФайлов КАК ВерсииФайлов
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДвоичныеДанныеФайлов КАК ДвоичныеДанныеФайлов
		|		ПО ВерсииФайлов.Ссылка = ДвоичныеДанныеФайлов.Файл
		|ГДЕ
		|	ДвоичныеДанныеФайлов.Файл ЕСТЬ NULL
		|	И ВерсииФайлов.ТипХраненияФайла = ЗНАЧЕНИЕ(Перечисление.ТипыХраненияФайлов.ВИнформационнойБазе)
		|
		|УПОРЯДОЧИТЬ ПО
		|	ВерсииФайлов.ДатаМодификацииУниверсальная УБЫВ";
	
	МассивСсылок = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
	ОбновлениеИнформационнойБазы.ОтметитьКОбработке(Параметры, МассивСсылок);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ДвоичныеДанныеФайлов.Файл КАК Ссылка
	|ИЗ
	|	РегистрСведений.ДвоичныеДанныеФайлов КАК ДвоичныеДанныеФайлов
	|ГДЕ
	|	ТИПЗНАЧЕНИЯ(ДвоичныеДанныеФайлов.Файл) = &ТипФайла";
	
	Запрос.УстановитьПараметр("ТипФайла", ТипЗнч(Справочники.Файлы.ПустаяСсылка()));
	
	МассивСсылок = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
	ОбновлениеИнформационнойБазы.ОтметитьКОбработке(Параметры, МассивСсылок);
	
КонецПроцедуры

// Обновить записи регистра.
Процедура ОбработатьДанныеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	Выборка = ОбновлениеИнформационнойБазы.ВыбратьСсылкиДляОбработки(Параметры.Очередь, "Справочник.ВерсииФайлов");
	Если Выборка.Количество() > 0 Тогда
		ПеренестиДвоичныеДанныеФайловВРегистрСведенийДвоичныеДанныеФайлов(Выборка);
	КонецЕсли;
	
	Выборка = ОбновлениеИнформационнойБазы.ВыбратьСсылкиДляОбработки(Параметры.Очередь, "Справочник.Файлы");
	Если Выборка.Количество() > 0 Тогда
		СоздатьНедостающиеВерсииФайлов(Выборка);
	КонецЕсли;
	
	ОбработкаЗавершена = ОбновлениеИнформационнойБазы.ОбработкаДанныхЗавершена(Параметры.Очередь, "Справочник.ВерсииФайлов")
		И ОбновлениеИнформационнойБазы.ОбработкаДанныхЗавершена(Параметры.Очередь, "Справочник.Файлы");
	
	Параметры.ОбработкаЗавершена = ОбработкаЗавершена;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ПеренестиДвоичныеДанныеФайловВРегистрСведенийДвоичныеДанныеФайлов(Выборка)
	
	ОбъектовОбработано = 0;
	ПроблемныхОбъектов = 0;
	
	Пока Выборка.Следующий() Цикл
		
		НачатьТранзакцию();
		Попытка
			
			БлокировкаДанных = Новый БлокировкаДанных;
			ЭлементБлокировкиДанных = БлокировкаДанных.Добавить("РегистрСведений.УдалитьХранимыеФайлыВерсий");
			ЭлементБлокировкиДанных.УстановитьЗначение("ВерсияФайла", Выборка.Ссылка);
			ЭлементБлокировкиДанных.Режим = РежимБлокировкиДанных.Разделяемый;
			БлокировкаДанных.Заблокировать();
			
			МенеджерЗаписиВерсииФайла = РегистрыСведений.УдалитьХранимыеФайлыВерсий.СоздатьМенеджерЗаписи();
			МенеджерЗаписиВерсииФайла.ВерсияФайла = Выборка.Ссылка;
			МенеджерЗаписиВерсииФайла.Прочитать();
			
			ДвоичныеДанные = МенеджерЗаписиВерсииФайла.ХранимыйФайл.Получить();
			
			НаборЗаписей = СоздатьНаборЗаписей();
			НаборЗаписей.Отбор.Файл.Установить(Выборка.Ссылка);
			
			ЗаписьНабора = НаборЗаписей.Добавить();
			ЗаписьНабора.Файл = Выборка.Ссылка;
			ЗаписьНабора.ДвоичныеДанныеФайла = Новый ХранилищеЗначения(ДвоичныеДанные, Новый СжатиеДанных(9));
			ОбновлениеИнформационнойБазы.ЗаписатьНаборЗаписей(НаборЗаписей, Истина);
			
			ОбновлениеИнформационнойБазы.ОтметитьВыполнениеОбработки(Выборка.Ссылка);
			ОбъектовОбработано = ОбъектовОбработано + 1;
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			// Если не удалось обработать какой-либо документ, повторяем попытку снова.
			ПроблемныхОбъектов = ПроблемныхОбъектов + 1;
			
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось обработать версию файла: %1 по причине:
			|%2'"), 
			Выборка.Ссылка, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Предупреждение,
			Выборка.Ссылка.Метаданные(), Выборка.Ссылка, ТекстСообщения);
		КонецПопытки;
		
	КонецЦикла;
	
	Если ОбъектовОбработано = 0 И ПроблемныхОбъектов <> 0 Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Процедуре ПеренестиДвоичныеДанныеФайловВРегистрСведенийДвоичныеДанныеФайлов не удалось обработать некоторые версии файлов (пропущены): %1'"), 
			ПроблемныхОбъектов);
		ВызватьИсключение ТекстСообщения;
	Иначе
		ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Информация,
			Метаданные.НайтиПоПолномуИмени("Справочник.ВерсииФайлов"),,
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Процедура ПеренестиДвоичныеДанныеФайловВРегистрСведенийДвоичныеДанныеФайлов обработала очередную порцию версий: %1'"),
			ОбъектовОбработано));
	КонецЕсли;
	
КонецПроцедуры

Процедура СоздатьНедостающиеВерсииФайлов(Выборка)
	
	ОбъектовОбработано = 0;
	ПроблемныхОбъектов = 0;
	
	Пока Выборка.Следующий() Цикл
		
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("Справочник.Файлы");
		ЭлементБлокировки.УстановитьЗначение("Ссылка", Выборка.Ссылка);
		
		ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.ДвоичныеДанныеФайлов");
		ЭлементБлокировки.УстановитьЗначение("Файл", Выборка.Ссылка);
		
		НачатьТранзакцию();
		Попытка
			Блокировка.Заблокировать();
			
			ФайлОбъект = Выборка.Ссылка.ПолучитьОбъект(); // СправочникОбъект.Файлы
			
			Если ФайлОбъект <> Неопределено Тогда
				
				Версия = Справочники.ВерсииФайлов.СоздатьЭлемент();
				Версия.УстановитьНовыйКод();
				
				НаборСвойств = "Автор,Владелец,ДатаМодификацииУниверсальная,ДатаСоздания,ИндексКартинки,
				|Наименование,ПометкаУдаления, ПутьКФайлу,Размер,Расширение,СтатусИзвлеченияТекста, ТекстХранилище, ТипХраненияФайла, Том";
				
				ЗаполнитьЗначенияСвойств(Версия, ФайлОбъект, НаборСвойств);
				Версия.НомерВерсии = 1;
				Версия.ПолноеНаименование = ФайлОбъект.Наименование;
				Версия.Владелец = Выборка.Ссылка;
				
				ОбновлениеИнформационнойБазы.ЗаписатьОбъект(Версия);
				
				ФайлОбъект.ТекущаяВерсия = Версия.Ссылка;
				ОбновлениеИнформационнойБазы.ЗаписатьОбъект(ФайлОбъект);
				
				ДвоичныеДанныеФайлов = РегистрыСведений.ДвоичныеДанныеФайлов.СоздатьМенеджерЗаписи();
				ДвоичныеДанныеФайлов.Файл = Выборка.Ссылка;
				ДвоичныеДанныеФайлов.Прочитать();
				ДвоичныеДанныеФайлов.Файл = Версия.Ссылка;
				ДвоичныеДанныеФайлов.Записать();
				
			КонецЕсли;
			
			ОбъектовОбработано = ОбъектовОбработано + 1;
			ЗафиксироватьТранзакцию();
		Исключение
			
			ОтменитьТранзакцию();
			// Если не удалось обработать какой-либо файл, повторяем попытку снова.
			ПроблемныхОбъектов = ПроблемныхОбъектов + 1;
			
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось обработать файл: %1 по причине:
				|%2'"), 
			Выборка.Ссылка, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			
			ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Предупреждение,
			Выборка.Ссылка.Метаданные(), Выборка.Ссылка, ТекстСообщения);
			
		КонецПопытки;
		
	КонецЦикла;
	
	Если ОбъектовОбработано = 0 И ПроблемныхОбъектов <> 0 Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Процедуре СоздатьНедостающиеВерсииФайлов не удалось обработать некоторые файлы (пропущены): %1'"), 
			ПроблемныхОбъектов);
		ВызватьИсключение ТекстСообщения;
	Иначе
		ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Информация,
			Метаданные.НайтиПоПолномуИмени("Справочник.ВерсииФайлов"),,
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Процедура СоздатьНедостающиеВерсииФайлов обработала очередную порцию файлов: %1'"),
			ОбъектовОбработано));
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти


#КонецЕсли
