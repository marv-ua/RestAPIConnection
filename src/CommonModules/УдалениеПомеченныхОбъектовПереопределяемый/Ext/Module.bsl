﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Определить объекты метаданных, в формах списков которых
// будет выведена команда показать помеченные и перейти к помеченным на удаление.
// см. УдалениеПомеченныхОбъектовКлиент.ПоказатьПомеченныеНаУдаление и УдалениеПомеченныхОбъектовКлиент.ПерейтиКПомеченнымНаУдаление. 
//
// Параметры:
//  Объекты - Массив из ОбъектМетаданных - объекты метаданных, в формы списка которых будут добавлены команды скрытия
//                                         помеченных на удаления.
//
// Пример:
//	Объекты.Добавить(Метаданные.Справочники._ДемоНоменклатура);
//	Объекты.Добавить(Метаданные.Справочники._ДемоПартнеры);
//
Процедура ПриОпределенииОбъектовСКомандойПоказатьПомеченные(Объекты) Экспорт
	
КонецПроцедуры

#Область УстаревшиеПроцедурыИФункции

// Устарела. Вызывается перед поиском объектов, помеченных на удаление.
// В этом обработчике можно организовать удаление устаревших ключей аналитик и любых других объектов информационной
// базы, ставших более не нужными.
// 
// Вместо процедуры следует использовать либо событие ПередУдалением удаляемых объектов, либо определить ПодчиненныеОбъекты 
// (см. ОбщегоНазначения.ПодчиненныеОбъекты)
//
// Параметры:
//   Параметры - Структура:
//     * Интерактивное - Булево - Истина, если удаление помеченных объектов запущено пользователем;
//                                Ложь, если удаление запущено по расписанию регламентного задания.
//
Процедура ПередПоискомПомеченныхНаУдаление(Параметры) Экспорт
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти
