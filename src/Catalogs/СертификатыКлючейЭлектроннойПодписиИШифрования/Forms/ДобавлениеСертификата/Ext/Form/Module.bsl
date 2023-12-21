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
	
	Если ЭлектроннаяПодпись.ОбщиеНастройки().ЗаявлениеНаВыпускСертификатаДоступно
	   И Не Параметры.СкрытьЗаявление Тогда
		
		СпособДобавленияСертификата = "ЗаявлениеНаВыпускСертификата";
		Если Не ЭлектроннаяПодпись.ИспользоватьШифрование() Тогда
			Элементы.Страницы.ТекущаяСтраница = Элементы.СтраницаСпособДобавленияСертификатаБезШифрования;
		КонецЕсли;
	Иначе
		Элементы.СтраницаСпособДобавленияСертификата.Видимость = Ложь;
		Элементы.СтраницаСпособДобавленияСертификатаБезШифрования.Видимость = Ложь;
	КонецЕсли;
	
	Назначение = "ДляПодписанияШифрованияИРасшифровки";
	Если Не ЗначениеЗаполнено(СпособДобавленияСертификата) Тогда
		Элементы.Страницы.ТекущаяСтраница = Элементы.СтраницаНазначение;
	КонецЕсли;
	
	Если Не ЭлектроннаяПодпись.ИспользоватьЭлектронныеПодписи() Тогда
		Назначение = "ДляШифрованияИРасшифровки";
		Если Не ЗначениеЗаполнено(СпособДобавленияСертификата) Тогда
			Элементы.Страницы.ТекущаяСтраница = Элементы.СтраницаНазначениеБезЭлектроннойПодписи;
		КонецЕсли;
		
	ИначеЕсли Не ЭлектроннаяПодпись.ИспользоватьШифрование()
	        И Не ЗначениеЗаполнено(СпособДобавленияСертификата) Тогда
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	УстановитьСоставКомандТолькоДляШифрования(ЭтотОбъект);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура СпособДобавленияСертификатаПриИзменении(Элемент)
	
	УстановитьСоставКомандПриИзмененииСпособаДобавленияСертификата();
	
КонецПроцедуры

&НаКлиенте
Процедура НазначениеПриИзменении(Элемент)
	
	УстановитьСоставКомандТолькоДляШифрования(ЭтотОбъект);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Добавить(Команда)
	
	Если Элементы.Страницы.ТекущаяСтраница = Элементы.СтраницаСпособДобавленияСертификата
	 Или Элементы.Страницы.ТекущаяСтраница = Элементы.СтраницаСпособДобавленияСертификатаБезШифрования Тогда
		
		Закрыть(СпособДобавленияСертификата);
	Иначе
		Закрыть(Назначение);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Далее(Команда)
	
	Если ЭлектроннаяПодписьКлиент.ИспользоватьЭлектронныеПодписи() Тогда
		Элементы.Страницы.ТекущаяСтраница = Элементы.СтраницаНазначение;
		Назначение = "ДляПодписанияШифрованияИРасшифровки";
	Иначе
		Элементы.Страницы.ТекущаяСтраница = Элементы.СтраницаНазначениеБезЭлектроннойПодписи;
		Назначение = "ДляШифрованияИРасшифровки";
	КонецЕсли;
	
	Элементы.ФормаДобавить.Видимость = Истина;
	Элементы.ФормаДалее.Видимость = Ложь;
	Элементы.ФормаНазад.Видимость = Истина;
	Элементы.ФормаДобавить.КнопкаПоУмолчанию = Истина;
	
	УстановитьСоставКомандТолькоДляШифрования(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура Назад(Команда)
	
	Элементы.Страницы.ТекущаяСтраница = Элементы.СтраницаСпособДобавленияСертификата;
	Элементы.ФормаНазад.Видимость = Ложь;
	
	УстановитьСоставКомандПриИзмененииСпособаДобавленияСертификата();
	
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьИзФайла(Команда)
	
	Закрыть("ТолькоДляШифрованияИзФайла");
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура УстановитьСоставКомандПриИзмененииСпособаДобавленияСертификата()
	
	ДобавитьЗаявку = СпособДобавленияСертификата = "ЗаявлениеНаВыпускСертификата";
	
	Элементы.ФормаДобавить.Видимость = ДобавитьЗаявку;
	Элементы.ФормаДалее.Видимость = Не ДобавитьЗаявку;
	Элементы.ФормаДобавить.КнопкаПоУмолчанию = ДобавитьЗаявку;
	Элементы.ФормаДалее.КнопкаПоУмолчанию = Не ДобавитьЗаявку;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьСоставКомандТолькоДляШифрования(Форма)
	
	Элементы = Форма.Элементы;
	ИзФайла = Форма.Назначение = "ТолькоДляШифрования";
	
	Элементы.ДобавитьИзФайла1.Видимость = ИзФайла;
	Элементы.ДобавитьИзФайла2.Видимость = ИзФайла;
	
КонецПроцедуры

#КонецОбласти
