﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	УстановитьПараметрыДинамическихСписков();
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	УстановитьПараметрыДинамическихСписков();
	
КонецПроцедуры

&НаСервере
Процедура УстановитьПараметрыДинамическихСписков()
	
	ОбщегоНазначенияКлиентСервер.УстановитьПараметрДинамическогоСписка(СписокАдреса, "Контрагент", Объект.Ссылка, Истина);
	ОбщегоНазначенияКлиентСервер.УстановитьПараметрДинамическогоСписка(СписокАдресаНормализированные, "Контрагент", Объект.Ссылка, Истина);
	
КонецПроцедуры

