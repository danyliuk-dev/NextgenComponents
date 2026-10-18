# NgDateRangePicker — Диапазон дат

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Связанная пара начала и конца с проверкой порядка.

## Поведение и практические правила

NgDateRange хранит Start/End в Blazor и start/end во Flutter. Конец раньше начала вызывает ошибку. Min/Max ограничивают обе границы. Callback обновляет диапазон целиком. Не отправляйте прежнее корректное значение, пока пользователь видит ошибку черновика: сохранение должно проходить через NgForm. Это диапазон календарных дат, не интервал часовых поясов.

## Blazor: рабочий пример

```razor
<NgDateRangePicker Label="Период" @bind-Value="range"/>
@code { private NgDateRange? range=new(new(2026,10,20),new(2026,10,23)); }
```

## Flutter: рабочий пример

```dart
NgDateRange? range = NgDateRange(DateTime(2026,10,20), DateTime(2026,10,23));
Widget build(BuildContext context) => NgDateRangePicker(label: 'Период', value: range,
  required: true, onChanged: (v) => setState(() => range = v));
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `Label` | `string` | "Date range" | Подпись элемента или доступное имя. |
| `Value` | `NgDateRange?` | не задан | Текущее значение; тип и правила описаны выше. |
| `ValueChanged` | `EventCallback<NgDateRange?>` | не задан | Новое значение для родителя; сохраните его в модели. |
| `ValueExpression` | `Expression<Func<NgDateRange?>>?` | не задан | Выражение поля модели для валидации. @bind-Value создаёт автоматически; при ручных Value/ValueChanged передайте явно, даже вне формы. |
| `Min` | `DateOnly?` | не задан | Нижняя включительная граница. |
| `Max` | `DateOnly?` | не задан | Верхняя включительная граница. |
| `Disabled` | `bool` | false | true запрещает действия пользователя. |

## Параметры и события Flutter

`required` в конструкторе означает обязательный аргумент, даже если его тип допускает null. `key` — стандартный Flutter Key. Значения по умолчанию приведены в точной сигнатуре ниже.

| Аргумент | Тип | Назначение |
|---|---|---|
| `label` | `String` | Подпись элемента или доступное имя. |
| `value` | `NgDateRange?` | Текущее значение; тип и правила описаны выше. |
| `min` | `DateTime?` | Нижняя включительная граница. |
| `max` | `DateTime?` | Верхняя включительная граница. |
| `enabled` | `bool` | false запрещает действия пользователя. |
| `required` | `bool` | true требует непустое значение при проверке формы. |
| `onChanged` | `ValueChanged<NgDateRange?>?` | Новое значение для родителя; обновите состояние через setState. |

```dart
const NgDateRangePicker({
    super.key,
    this.label = 'Date range',
    required this.value,
    this.onChanged,
    this.min,
    this.max,
    this.enabled = true,
    this.required = false,
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgDateRangePicker.razor)
- [Flutter](../../packages/nextgen_components/lib/src/dates.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
