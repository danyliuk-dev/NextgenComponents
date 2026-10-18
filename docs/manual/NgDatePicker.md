# NgDatePicker — Дата с календарём

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Выбор календарной даты или локального времени без автоматической смены часового пояса.

## Поведение и практические правила

Формат ввода: yyyy-MM-dd. Min/Max включают граничные значения. Некорректные дни (например, 31 апреля) и время 24:00 не принимаются. DisabledDate/disabledDate возвращает true для запрещённого дня. Flutter использует DateTime для даты, TimeOfDay для времени; Blazor — DateOnly и TimeOnly. Не смешивайте UTC и локальные значения. Пустое необязательное поле хранит null. Для обязательности используйте валидацию формы; во Flutter также имеется required: true. Полные правила и ограничения ручного ввода см. forms-and-dates.md.

## Blazor: рабочий пример

```razor
<NgDatePicker Label="Дата" @bind-Value="value"/>
@code { private DateOnly? value=new(2026,10,20); }
```

## Flutter: рабочий пример

```dart
DateTime? value = DateTime(2026,10,20,9,30);
Widget build(BuildContext context) => NgDatePicker(value: value,
  onChanged: (v) => setState(() => value = v));
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `Id` | `string` | "ng-"+Guid.NewGuid().ToString("N") | Уникальный HTML ID; по умолчанию генерируется. |
| `Label` | `string` | "Date" | Подпись элемента или доступное имя. |
| `Value` | `DateOnly?` | не задан | Текущее значение; тип и правила описаны выше. |
| `ValueChanged` | `EventCallback<DateOnly?>` | не задан | Новое значение для родителя; сохраните его в модели. |
| `ValueExpression` | `Expression<Func<DateOnly?>>?` | не задан | Выражение поля модели для валидации. @bind-Value создаёт автоматически; при ручных Value/ValueChanged передайте явно, даже вне формы. |
| `Min` | `DateOnly?` | не задан | Нижняя включительная граница. |
| `Max` | `DateOnly?` | не задан | Верхняя включительная граница. |
| `DisabledDate` | `Func<DateOnly,bool>?` | не задан | Функция возвращает true для запрещённого дня. |
| `Disabled` | `bool` | false | true запрещает действия пользователя. |

## Параметры и события Flutter

`required` в конструкторе означает обязательный аргумент, даже если его тип допускает null. `key` — стандартный Flutter Key. Значения по умолчанию приведены в точной сигнатуре ниже.

| Аргумент | Тип | Назначение |
|---|---|---|
| `label` | `String` | Подпись элемента или доступное имя. |
| `value` | `DateTime?` | Текущее значение; тип и правила описаны выше. |
| `min` | `DateTime?` | Нижняя включительная граница. |
| `max` | `DateTime?` | Верхняя включительная граница. |
| `required` | `bool` | true требует непустое значение при проверке формы. |
| `enabled` | `bool` | false запрещает действия пользователя. |
| `disabledDate` | `bool Function(DateTime)?` | Функция возвращает true для запрещённого дня. |
| `onChanged` | `ValueChanged<DateTime?>?` | Новое значение для родителя; обновите состояние через setState. |

```dart
const NgDatePicker({
    super.key,
    this.label = 'Date',
    required this.value,
    this.onChanged,
    this.min,
    this.max,
    this.required = false,
    this.enabled = true,
    this.disabledDate,
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgDatePicker.razor)
- [Flutter](../../packages/nextgen_components/lib/src/dates.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
