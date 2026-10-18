# NgDateTimePicker — Дата и время

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Выбор календарной даты или локального времени без автоматической смены часового пояса.

## Поведение и практические правила

Формат ввода: yyyy-MM-dd HH:mm. Min/Max включают граничные значения. Некорректные дни (например, 31 апреля) и время 24:00 не принимаются. Flutter использует DateTime для даты, TimeOfDay для времени; Blazor — DateOnly и TimeOnly. Не смешивайте UTC и локальные значения. Пустое необязательное поле хранит null. Для обязательности используйте валидацию формы; во Flutter также имеется required: true. Полные правила и ограничения ручного ввода см. forms-and-dates.md.

## Blazor: рабочий пример

```razor
<NgDateTimePicker Label="Дата" @bind-Value="value"/>
@code { private DateTime? value=new(2026,10,20,9,30,0); }
```

## Flutter: рабочий пример

```dart
DateTime? value = DateTime(2026,10,20,9,30);
Widget build(BuildContext context) => NgDateTimePicker(value: value,
  onChanged: (v) => setState(() => value = v));
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `Id` | `string` | "ng-"+Guid.NewGuid().ToString("N") | Уникальный HTML ID; по умолчанию генерируется. |
| `Label` | `string` | "Date and time" | Подпись элемента или доступное имя. |
| `Min` | `DateTime?` | не задан | Нижняя включительная граница. |
| `Max` | `DateTime?` | не задан | Верхняя включительная граница. |
| `Disabled` | `bool` | false | true запрещает действия пользователя. |
| `Value` | `DateTime?` | значение модели | Текущее значение поля. |
| `ValueChanged` | `EventCallback<DateTime?>` | — | Изменение значения. |
| `ValueExpression` | `Expression<Func<DateTime?>>` | обязательно | Автоматически создаётся @bind-Value; при ручной привязке передайте явно. |
| `AdditionalAttributes` | словарь HTML-атрибутов | null | Дополнительные HTML/ARIA атрибуты поля. |

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
| `onChanged` | `ValueChanged<DateTime?>?` | Новое значение для родителя; обновите состояние через setState. |

```dart
const NgDateTimePicker({
    super.key,
    this.label = 'Date and time',
    required this.value,
    this.onChanged,
    this.min,
    this.max,
    this.required = false,
    this.enabled = true,
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgDateTimePicker.razor)
- [Flutter](../../packages/nextgen_components/lib/src/dates.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
