﻿#Область СлужебныйПрограммныйИнтерфейс

#Область ОбщегоНазначения

#Если Не ВебКлиент Тогда

// Загружает содержимое из Интернет по протоколу HTTP(S)
// с использованием методов GET, POST или PUT.
//
// ИнтернетПоддержкаПользователейКлиентСервер.ЗагрузитьСодержимоеИзИнтернет
//
Функция ЗагрузитьСодержимоеИзИнтернет(
	Знач URL,
	Знач Логин = Неопределено,
	Знач Пароль = Неопределено,
	ДопПараметры = Неопределено) Экспорт

	Результат = Новый Структура;
	Результат.Вставить("КодОшибки"         , "");
	Результат.Вставить("СообщениеОбОшибке" , "");
	Результат.Вставить("ИнформацияОбОшибке", "");
	Результат.Вставить("Содержимое"        , Неопределено);
	Результат.Вставить("КодСостояния"      , 0);
	Результат.Вставить("ФорматОтвета"      , 0);

	// Формат ответа: 0 - имя файла ответа, 1 - как строка, 2 - как двоичные данные.
	// Метод: "GET", "POST" или "PUT".
	// ДанныеДляОбработки: данные, передаваемые методом POST.
	// ФорматДанныхДляОбработки: 0 - имя файла, 1 как строка, 2 - как двоичные данные.
	// Заголовки - заголовки запроса.
	ПараметрыПолучения = Новый Структура;
	ПараметрыПолучения.Вставить("ФорматОтвета"            , 0);
	ПараметрыПолучения.Вставить("Метод"                   , "GET");
	ПараметрыПолучения.Вставить("ДанныеДляОбработки"      , Неопределено);
	ПараметрыПолучения.Вставить("ФорматДанныхДляОбработки", 0);
	ПараметрыПолучения.Вставить("Заголовки"               , Неопределено);
	ПараметрыПолучения.Вставить("ИмяФайлаОтвета"          , Неопределено);
	ПараметрыПолучения.Вставить("Таймаут"                 , -1);
	ПараметрыПолучения.Вставить("НастройкиПрокси"         , Неопределено);
	
	Если ДопПараметры <> Неопределено Тогда
		ЗаполнитьЗначенияСвойств(ПараметрыПолучения, ДопПараметры);
	КонецЕсли;
	
	Если ПараметрыПолучения.Таймаут = -1 Тогда
		// Таймаут по умолчанию.
		ПараметрыПолучения.Таймаут = 30;
	КонецЕсли;
	
	Результат.ФорматОтвета = ПараметрыПолучения.ФорматОтвета;
	
	КоличествоПеренаправлений  = 0;
	МаксКолвоПеренаправлений   = 7;
	Перенаправления            = Новый Массив;
	ВыполненныеПеренаправления = Новый Соответствие;
	ПроксиПоСхемам             = Новый Соответствие;
	ЗащищенноеСоединениеКэш    = Неопределено;
	
	URLДляПолучения = URL;
	HTTPЗапрос = Новый HTTPЗапрос;
	Если ПараметрыПолучения.Заголовки <> Неопределено Тогда
		HTTPЗапрос.Заголовки = ПараметрыПолучения.Заголовки;
	КонецЕсли;
	ТелоУстановлено = Ложь;
	Ответ = Неопределено;
	Пока КоличествоПеренаправлений < МаксКолвоПеренаправлений Цикл

		СтруктураURI = ОбщегоНазначенияКлиентСервер.СтруктураURI(URLДляПолучения);
		Если СтруктураURI.Схема <> "https" Тогда
			ЗащищенноеСоединение = Неопределено;
		Иначе
			Если ЗащищенноеСоединениеКэш = Неопределено Тогда
				ЗащищенноеСоединениеКэш = ОбщегоНазначенияКлиентСервер.НовоеЗащищенноеСоединение(
					Неопределено,
					Новый СертификатыУдостоверяющихЦентровОС);
			КонецЕсли;
			ЗащищенноеСоединение = ЗащищенноеСоединениеКэш;
		КонецЕсли;

		Если НЕ ПустаяСтрока(СтруктураURI.Логин) Тогда
			ЛогинДляПолучения  = СтруктураURI.Логин;
			ПарольДляПолучения = СтруктураURI.Пароль;
		Иначе
			ЛогинДляПолучения  = Логин;
			ПарольДляПолучения = Пароль;
		КонецЕсли;

		Если СтруктураURI.Порт = Неопределено ИЛИ ПустаяСтрока(СтруктураURI.Порт) Тогда
			Порт = ?(ЗащищенноеСоединение = Неопределено, 80, 443);
		Иначе
			Порт = Число(СтруктураURI.Порт);
		КонецЕсли;

		Прокси = ПроксиПоСхемам.Получить(СтруктураURI.Схема);
		Если Прокси = Неопределено Тогда
			Если ПараметрыПолучения.НастройкиПрокси = Неопределено Тогда
				Прокси = ПолучениеФайловИзИнтернетаКлиентСервер.ПолучитьПрокси(СтруктураURI.Схема);
			Иначе
				Прокси = СформироватьИнтернетПрокси(ПараметрыПолучения.НастройкиПрокси, СтруктураURI.Схема);
			КонецЕсли;
			ПроксиПоСхемам.Вставить(СтруктураURI.Схема, Прокси);
		КонецЕсли;

		Соединение = Новый HTTPСоединение(
			СтруктураURI.Хост,
			Порт,
			ЛогинДляПолучения,
			ПарольДляПолучения,
			Прокси,
			ПараметрыПолучения.Таймаут,
			ЗащищенноеСоединение);

		Попытка

			HTTPЗапрос.АдресРесурса = СтруктураURI.ПутьНаСервере;

			Если ПараметрыПолучения.Метод = "GET" Тогда
				Ответ = Соединение.Получить(HTTPЗапрос, ПараметрыПолучения.ИмяФайлаОтвета);
			ИначеЕсли ПараметрыПолучения.Метод = "HEAD" Тогда
				Ответ = Соединение.ПолучитьЗаголовки(HTTPЗапрос);
			Иначе
			
				Если НЕ ТелоУстановлено Тогда

					Если ПараметрыПолучения.ДанныеДляОбработки <> Неопределено Тогда

						Если ПараметрыПолучения.ФорматДанныхДляОбработки = 0 Тогда

							HTTPЗапрос.УстановитьИмяФайлаТела(ПараметрыПолучения.ДанныеДляОбработки);

						ИначеЕсли ПараметрыПолучения.ФорматДанныхДляОбработки = 1 Тогда

							HTTPЗапрос.УстановитьТелоИзСтроки(ПараметрыПолучения.ДанныеДляОбработки);

						Иначе

							HTTPЗапрос.УстановитьТелоИзДвоичныхДанных(ПараметрыПолучения.ДанныеДляОбработки);

						КонецЕсли;

					КонецЕсли;

					ТелоУстановлено = Истина;

				КонецЕсли;

				Если ПараметрыПолучения.Метод = "PUT" Тогда
					Ответ = Соединение.Записать(HTTPЗапрос);
				Иначе
					// POST
					Ответ = Соединение.ОтправитьДляОбработки(HTTPЗапрос, ПараметрыПолучения.ИмяФайлаОтвета);
				КонецЕсли;

			КонецЕсли;

		Исключение
			
			ПредставлениеОшибки = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
			ПодробноеОписаниеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось загрузить содержимое (%1). %2'; en = 'Failed to load content (%1). %2'"),
				URL,
				ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			
			// Диагностика соединения с ресурсом.
			Попытка
				
				РезультатДиагностики = ОбщегоНазначенияКлиентСервер.ДиагностикаСоединения(URL);
				ОписаниеРезультатаДиагностики = НСтр("ru = 'Результаты диагностики соединения:'")
					+ Символы.ПС + РезультатДиагностики.ОписаниеОшибки;
				
			Исключение
				
				ОписаниеРезультатаДиагностики = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Не удалось выполнить диагностику соединения. %1'; en = 'Connection diagnostics failed. %1'"),
					ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
				
			КонецПопытки;
			
			УстановитьОписаниеОшибки(
				Результат,
				"ConnectError",
				ПредставлениеОшибки,
				ПодробноеОписаниеОшибки + Символы.ПС + ОписаниеРезультатаДиагностики,
				Перенаправления);
			Возврат Результат;
			
		КонецПопытки;

		Результат.КодСостояния = Ответ.КодСостояния;

		Если Ответ.КодСостояния = 301 // 301 Moved Permanently
			ИЛИ Ответ.КодСостояния = 302 // 302 Found, 302 Moved Temporarily
			ИЛИ Ответ.КодСостояния = 303 // 303 See Other by GET
			ИЛИ Ответ.КодСостояния = 307 Тогда // 307 Temporary Redirect

			КоличествоПеренаправлений = КоличествоПеренаправлений + 1;

			Если КоличествоПеренаправлений > МаксКолвоПеренаправлений Тогда
				УстановитьОписаниеОшибки(
					Результат,
					"ServerError",
					НСтр("ru = 'Превышено количество перенаправлений.'; en = 'The number of redirects has been exceeded.'"),
					СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Ошибка сервера при получении файла (%1). Превышено количество перенаправлений (%2).'; en = 'Server error while receiving a file (%1). Number of redirects exceeded (%2).'"),
						URL,
						МаксКолвоПеренаправлений),
					Перенаправления);
				Возврат Результат;
			Иначе
				Location = Ответ.Заголовки.Получить("Location");
				Если Location = Неопределено Тогда
					УстановитьОписаниеОшибки(
						Результат,
						"ServerError",
						НСтр("ru = 'Некорректное перенаправление.'; en = 'Incorrect redirection.'"),
						СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
							НСтр("ru = 'Ошибка сервера (%1) при получении файла (%2). Некорректное перенаправление, отсутствует HTTP-заголовок ответа ""Location"".'; en = 'Server error (%1) while receiving a file (%2). Incorrect redirection, missing HTTP response header """"Location"""".'"),
							Ответ.КодСостояния,
							URL),
						Перенаправления);
					Возврат Результат;
				Иначе
					Location = СокрЛП(Location);
					Если ПустаяСтрока(Location) Тогда
						УстановитьОписаниеОшибки(
							Результат,
							"ServerError",
							НСтр("ru = 'Некорректное перенаправление.'; en = 'Incorrect redirection.'"),
							СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
								НСтр("ru = 'Ошибка сервера (%1) при получении файла (%2). Некорректное перенаправление, пустой HTTP-заголовок ответа ""Location"".'; en = 'Server error (%1) while receiving a file (%2). Incorrect redirection, empty HTTP response header ""Location"".'"),
								Ответ.КодСостояния,
								URL),
							Перенаправления);
						Возврат Результат;
					КонецЕсли;

					Если ВыполненныеПеренаправления.Получить(Location) <> Неопределено Тогда
						УстановитьОписаниеОшибки(
							Результат,
							"ServerError",
							НСтр("ru = 'Циклическое перенаправление.'; en = 'Cyclic Redirection.'"),
							СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
								НСтр("ru = 'Ошибка сервера (%1) при получении файла (%2). Циклическое перенаправление (%3).'; en = 'Server error (%1) when receiving a file (%2). Cyclic redirection (%3).'"),
								Ответ.КодСостояния,
								URL,
								Location),
							Перенаправления);
						Возврат Результат;
					КонецЕсли;

					ВыполненныеПеренаправления.Вставить(Location, Истина);
					URLДляПолучения = Location;

					Перенаправления.Добавить(Строка(Ответ.КодСостояния) + ": " + Location);

				КонецЕсли;
				
			КонецЕсли;

		Иначе

			Прервать;

		КонецЕсли;

	КонецЦикла;

	Если ПараметрыПолучения.ФорматОтвета = 0 Тогда
		Результат.Содержимое = Ответ.ПолучитьИмяФайлаТела();
	ИначеЕсли ПараметрыПолучения.ФорматОтвета = 1 Тогда
		Результат.Содержимое = Ответ.ПолучитьТелоКакСтроку();
	ИначеЕсли ПараметрыПолучения.ФорматОтвета = 2 Тогда
		Результат.Содержимое = Ответ.ПолучитьТелоКакДвоичныеДанные();
	Иначе
		Результат.Содержимое = Ответ;
	КонецЕсли;
	
	// Обработка ответа
	Если Ответ.КодСостояния < 200 Или Ответ.КодСостояния >= 300 Тогда

		// Анализ ошибки
		Если Ответ.КодСостояния = 407 Тогда

			// Ошибка подключения - не пройдена аутентификация на прокси-сервере.
			УстановитьОписаниеОшибки(
				Результат,
				"ConnectError",
				НСтр("ru = 'Ошибка аутентификации на прокси-сервере.'; en = 'Authentication error on the proxy server.'"),
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Ошибка клиента (%1) при выполнении запроса к ресурсу (%2).
                          |Тело ответа: %3'; en = 'Client error (%1) while making a request to a resource (%2).
                          |Response body: %3'"),
					Ответ.КодСостояния,
					URL,
					Лев(Ответ.ПолучитьТелоКакСтроку(), 5120)),
				Перенаправления);

		ИначеЕсли Ответ.КодСостояния < 200
			ИЛИ Ответ.КодСостояния >= 300
			И Ответ.КодСостояния < 400 Тогда

			// Формат ответа сервера не поддерживается.
			УстановитьОписаниеОшибки(
				Результат,
				"ServerError",
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Некорректный ответ сервера (%1).'; en = 'Incorrect server response (%1).'"),
					Ответ.КодСостояния),
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Ошибка сервера при получении файла (%1). Некорректный (неподдерживаемый) ответ (%2).
                          |Тело ответа: %3'; en = 'Server error while receiving a file (%1). Invalid (unsupported) response (%2).
                          |Response body: %3'"),
					URL,
					Ответ.КодСостояния,
					Лев(Ответ.ПолучитьТелоКакСтроку(), 5120)),
				Перенаправления);

		ИначеЕсли Ответ.КодСостояния >= 400 И Ответ.КодСостояния < 500 Тогда

			// Ошибка клиентской части - некорректный запрос.
			УстановитьОписаниеОшибки(
				Результат,
				"ClientError",
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Ошибка (%1) при выполнении запроса к ресурсу.'; en = 'Error (%1) while executing a resource request.'"),
					Строка(Ответ.КодСостояния)),
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Ошибка клиента (%1) при выполнении запроса к ресурсу (%2).
                          |Тело ответа: %3'; en = 'Client error (%1) while making a request to a resource (%2).
                          |Response body: %3'"),
					Ответ.КодСостояния,
					URL,
					Лев(Ответ.ПолучитьТелоКакСтроку(), 5120)),
				Перенаправления);

		Иначе

			// Ошибка сервера - 5хх
			УстановитьОписаниеОшибки(
				Результат,
				"ServerError",
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Код ошибки: %1.'; en = 'Error code: %1.'"),
					Строка(Ответ.КодСостояния)),
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Ошибка сервера (%1) при обработке запроса к ресурсу (%2).
                          |Тело ответа: %3'; en = 'Server error (%1) while processing a resource request (%2).
                          |Response body: %3'"),
					Ответ.КодСостояния,
					URL,
					Лев(Ответ.ПолучитьТелоКакСтроку(), 5120)),
				Перенаправления);

		КонецЕсли;

		ДобавитьСписокПеренаправленийКИнформацииОбОшибке(
			Результат.ИнформацияОбОшибке,
			Перенаправления);

	КонецЕсли;

	Возврат Результат;

КонецФункции

#КонецЕсли

#КонецОбласти

#Область ПолучениеСодержимогоИзИнтернет

#Если Не ВебКлиент Тогда

Функция НовыйЗащищенноеСоединение()

	Возврат Новый ЗащищенноеСоединениеOpenSSL(, Новый СертификатыУдостоверяющихЦентровОС);

КонецФункции

Процедура УстановитьОписаниеОшибки(Результат, КодОшибки, СообщениеОбОшибке, ИнформацияОбОшибке, Перенаправления)

	Результат.КодОшибки          = КодОшибки;
	Результат.СообщениеОбОшибке  = СообщениеОбОшибке;
	ДопСообщение = "";
	Если КодОшибки = "ConnectError" Тогда
		ДопСообщение = НСтр("ru = 'Ошибка при подключении к серверу.'; en = 'Error when connecting to the server.'; uk = 'Помилка при підключенні до сервера.'");

	ИначеЕсли КодОшибки = "ServerError" Тогда
		ДопСообщение = НСтр("ru = 'На сервере возникла внутренняя ошибка при обработке запроса.'; en = 'An internal error occurred on the server while processing the request.'; uk = 'На сервері виникла внутрішня помилка при обробці запиту.'");

	ИначеЕсли КодОшибки = "ClientError" Тогда
		ДопСообщение = НСтр("ru = 'Некорректный запрос.'; en = 'Incorrect request.'; uk = 'Некоректний запит.'");

	ИначеЕсли КодОшибки = "InternalError" Тогда
		ДопСообщение = НСтр("ru = 'Внутренняя ошибка.'; en = 'Internal error.'; uk = 'Внутрішня помилка.'");

	ИначеЕсли КодОшибки = "LoginError" Тогда
		ДопСообщение = НСтр("ru = 'Ошибка аутентификации на сервере.'; en = 'Authentication error on the server.'; uk = 'Помилка автентифікації на сервері.'");

	КонецЕсли;

	Результат.СообщениеОбОшибке =
		?(ПустаяСтрока(ДопСообщение), "", ДопСообщение + " ")
		+ СообщениеОбОшибке;

	Результат.ИнформацияОбОшибке = ИнформацияОбОшибке;

	Если Перенаправления.Количество() > 0 Тогда
		Результат.ИнформацияОбОшибке = Результат.ИнформацияОбОшибке + Символы.ПС
			+ НСтр("ru = 'Перенаправления:'; en = 'Redirections:'; uk = 'Перенаправлення:'") + Символы.ПС
			+ СтрСоединить(Перенаправления, ", " + Символы.ПС);
	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьСписокПеренаправленийКИнформацииОбОшибке(ИнформацияОбОшибке, Перенаправления)

	Если Перенаправления.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;

	ИнформацияОбОшибке = ИнформацияОбОшибке + Символы.ПС
		+ НСтр("ru='Перенаправления:';uk='Перенаправлення:'") + Символы.ПС
		+ СтрСоединить(Перенаправления, ", " + Символы.ПС);

КонецПроцедуры

Процедура СлужебнаяПроверитьURLДоступен(
	URL,
	Метод,
	ИмяОшибки,
	СообщениеОбОшибке,
	ИнформацияОбОшибке,
	НастройкиПроксиСервера = Неопределено) Экспорт
	
	ДопПараметрыПолученияФайла = Новый Структура("ФорматОтвета, Таймаут", 1, 10);
	ДопПараметрыПолученияФайла.Вставить("НастройкиПрокси", НастройкиПроксиСервера);
	
	Если Метод <> Неопределено Тогда
		ДопПараметрыПолученияФайла.Вставить("Метод", Метод);
	КонецЕсли;
	
	Попытка
		РезультатЗагрузки = ЗагрузитьСодержимоеИзИнтернет(
			URL,
			,
			,
			ДопПараметрыПолученияФайла);
	Исключение
		ИмяОшибки = "Unknown";
		СообщениеОбОшибке = НСтр("ru='Неизвестная ошибка. Подробнее см. в журнале регистрации.';uk='Невідома помилка. Докладніше див. у журналі реєстрації.'");
		ИнформацияОбОшибке = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru='Неизвестная ошибка при проверке доступности URL.
                |%1'
                |;uk='Невідома помилка при перевірці доступності URL.
                |%1'"),
			ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		Возврат;
	КонецПопытки;
	
	Если Не ПустаяСтрока(РезультатЗагрузки.КодОшибки) Тогда
		ИмяОшибки          = РезультатЗагрузки.КодОшибки;
		СообщениеОбОшибке  = РезультатЗагрузки.СообщениеОбОшибке;
		ИнформацияОбОшибке = РезультатЗагрузки.ИнформацияОбОшибке;
	КонецЕсли;
	
КонецПроцедуры

Функция СформироватьИнтернетПрокси(НастройкаПроксиСервера, Протокол)
	
	Если НастройкаПроксиСервера = Неопределено
		Или НастройкаПроксиСервера = "<СистемныеУстановки>" Тогда
		// Системные установки прокси-сервера.
		Возврат Неопределено;
	КонецЕсли;	
	
	ИспользоватьПрокси = НастройкаПроксиСервера.Получить("ИспользоватьПрокси");
	Если Не ИспользоватьПрокси Тогда
		// Не использовать прокси-сервер.
		Возврат Новый ИнтернетПрокси(Ложь);
	КонецЕсли;
	
	ИспользоватьСистемныеНастройки = НастройкаПроксиСервера.Получить("ИспользоватьСистемныеНастройки");
	Если ИспользоватьСистемныеНастройки Тогда
		// Системные настройки прокси-сервера.
		Возврат Новый ИнтернетПрокси(Истина);
	КонецЕсли;
			
	// Настройки прокси-сервера, заданные вручную.
	Прокси = Новый ИнтернетПрокси;
	
	// Определение адреса и порта прокси-сервера.
	ДополнительныеНастройки = НастройкаПроксиСервера.Получить("ДополнительныеНастройкиПрокси");
	ПроксиПоПротоколу = Неопределено;
	Если ТипЗнч(ДополнительныеНастройки) = Тип("Соответствие") Тогда
		ПроксиПоПротоколу = ДополнительныеНастройки.Получить(Протокол);
	КонецЕсли;
	
	ИспользоватьАутентификациюОС = НастройкаПроксиСервера.Получить("ИспользоватьАутентификациюОС");
	ИспользоватьАутентификациюОС = ?(ИспользоватьАутентификациюОС = Истина, Истина, Ложь);
	
	Если ТипЗнч(ПроксиПоПротоколу) = Тип("Структура") Тогда
		Прокси.Установить(Протокол, ПроксиПоПротоколу.Адрес, ПроксиПоПротоколу.Порт,
			НастройкаПроксиСервера["Пользователь"], НастройкаПроксиСервера["Пароль"], ИспользоватьАутентификациюОС);
	Иначе
		Прокси.Установить(Протокол, НастройкаПроксиСервера["Сервер"], НастройкаПроксиСервера["Порт"], 
			НастройкаПроксиСервера["Пользователь"], НастройкаПроксиСервера["Пароль"], ИспользоватьАутентификациюОС);
	КонецЕсли;
	
	Прокси.НеИспользоватьПроксиДляЛокальныхАдресов = НастройкаПроксиСервера["НеИспользоватьПроксиДляЛокальныхАдресов"];
	
	АдресаИсключений = НастройкаПроксиСервера.Получить("НеИспользоватьПроксиДляАдресов");
	Если ТипЗнч(АдресаИсключений) = Тип("Массив") Тогда
		Для каждого АдресИсключения Из АдресаИсключений Цикл
			Прокси.НеИспользоватьПроксиДляАдресов.Добавить(АдресИсключения);
		КонецЦикла;
	КонецЕсли;
	
	Возврат Прокси;
	
КонецФункции

#КонецЕсли

#КонецОбласти

#КонецОбласти
