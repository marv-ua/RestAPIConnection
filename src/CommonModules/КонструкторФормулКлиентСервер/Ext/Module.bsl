﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

Функция ЭлементыФормулы(Знач Формула) Экспорт

	ВсеЭлементы = Новый Массив;
	ОперандыИФункции = Новый Соответствие;
	
	ЛогическиеОператоры = СтрРазделить("И,ИЛИ,НЕ", ",", Ложь);
	
	Разделители = "()/*-+%=<>, " + Символы.Таб + Символы.ПС;
	ОткрывающихСкобок = 0;
	ЭтоСтрокаВКавычках = Ложь;
	
	Операнд = "";
	
	Для Индекс = 1 По СтрДлина(Формула) Цикл

		Символ = Сред(Формула, Индекс, 1);
		ЭтоРазделитель = СтрНайти(Разделители, Символ) > 0;
		
		Если ОткрывающихСкобок = 0 И Символ = """" Тогда
			ЭтоСтрокаВКавычках = Не ЭтоСтрокаВКавычках;
			ВсеЭлементы.Добавить(Символ);
			Продолжить;
		КонецЕсли;
		
		Если ЭтоСтрокаВКавычках Тогда
			ВсеЭлементы.Добавить(Символ);
			Продолжить;
		КонецЕсли;

		Если Символ = "[" Тогда
			ОткрывающихСкобок = ОткрывающихСкобок + 1;
		КонецЕсли;
		
		Если Символ = "]" И ОткрывающихСкобок > 0 Тогда
			ОткрывающихСкобок = ОткрывающихСкобок - 1;
		КонецЕсли;
		
		Если ЭтоРазделитель И ОткрывающихСкобок = 0 Тогда
			Если ЗначениеЗаполнено(Операнд) Тогда
				ЭтоФункция = Ложь;
				Если Символ = "(" И СтрНайти(Операнд, ".") = 0
					Или ЛогическиеОператоры.Найти(ВРег(Операнд)) <> Неопределено Тогда
					ЭтоФункция = Истина;
				КонецЕсли;
				
				Если ЭтоФункция Или Не ОбщегоНазначенияКлиентСервер.ЭтоЧисло(Операнд) Тогда
					ОперандыИФункции.Вставить(ВсеЭлементы.ВГраница() + 1, ЭтоФункция);
				КонецЕсли;
				
				ВсеЭлементы.Добавить(Операнд);
				Операнд = "";
			КонецЕсли;
			ВсеЭлементы.Добавить(Символ);
		Иначе
			Операнд = Операнд + Символ;
		КонецЕсли;
	КонецЦикла;
	
	Если ЗначениеЗаполнено(Операнд) И Не ОбщегоНазначенияКлиентСервер.ЭтоЧисло(Операнд) Тогда
		ОперандыИФункции.Вставить(ВсеЭлементы.ВГраница() + 1, Ложь);
	КонецЕсли;
	
	ВсеЭлементы.Добавить(Операнд);
	
	Результат = Новый Структура;
	Результат.Вставить("ВсеЭлементы", ВсеЭлементы);
	Результат.Вставить("ОперандыИФункции", ОперандыИФункции);
	
	Возврат Результат;
	
КонецФункции

Функция НастройкиСпискаПолей(Форма, ИмяСпискаПолей) Экспорт
	
	Отбор = Новый Структура("ИмяСпискаПолей", ИмяСпискаПолей);
	Для Каждого СписокПолей Из Форма.ПодключенныеСпискиПолей.НайтиСтроки(Отбор) Цикл
		Возврат СписокПолей;
	КонецЦикла;
	
	Возврат Неопределено;
	
КонецФункции

Функция ПараметрыРедактированияФормулы() Экспорт
	
	Параметры = Новый Структура;
	Параметры.Вставить("Формула");
	Параметры.Вставить("Операнды");
	Параметры.Вставить("Операторы");
	Параметры.Вставить("ИмяКоллекцииСКДОперандов");
	Параметры.Вставить("ИмяКоллекцииСКДОператоров");
	Параметры.Вставить("Наименование");
	Параметры.Вставить("ДляЗапроса");
	
	Возврат Параметры;
	
КонецФункции

#КонецОбласти