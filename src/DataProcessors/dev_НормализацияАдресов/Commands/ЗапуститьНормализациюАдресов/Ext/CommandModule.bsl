﻿
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	ЗапуститьНормализациюАдресовНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ЗапуститьНормализациюАдресовНаСервере()
	
	Об = Обработки.dev_НормализацияАдресов.Создать();
	Об.ЗапуститьВыполнение();
	
КонецПроцедуры
