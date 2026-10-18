# NgNumericTextBox — Числовое поле

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Ввод количества или суммы с границами и сохранением последнего корректного значения.

## Поведение и практические правила

Типы различаются: Blazor decimal?, Flutter double?. Пустое необязательное поле соответствует null. Flutter сохраняет некорректный черновик, но не публикует его как число; NgForm.validate блокирует отправку. Во Flutter required: true запрещает пустое значение; в Blazor добавьте Required/Range к модели формы. Step имеется только в Blazor API. Это не форматтер валют и не финансовый движок.

## Blazor: рабочий пример

```razor
<NgNumericTextBox Label="Количество" Min="0" Max="100" Step="1" @bind-Value="quantity"/>
@code { private decimal? quantity=5; }
```

## Flutter: рабочий пример

```dart
double? quantity = 5;
Widget build(BuildContext context) => NgNumericTextBox(label: 'Количество',
  value: quantity, min: 0, max: 100, required: true,
  onChanged: (v) => setState(() => quantity = v));
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `Id` | `string` | "ng-" + Guid.NewGuid().ToString("N") | Уникальный HTML ID; по умолчанию генерируется. |
| `Label` | `string` | "" | Подпись элемента или доступное имя. |
| `Value` | `decimal?` | не задан | Текущее значение; тип и правила описаны выше. |
| `ValueChanged` | `EventCallback<decimal?>` | не задан | Новое значение для родителя; сохраните его в модели. |
| `ValueExpression` | `System.Linq.Expressions.Expression<Func<decimal?>>?` | не задан | Выражение поля модели для валидации. @bind-Value создаёт автоматически; при ручных Value/ValueChanged передайте явно, даже вне формы. |
| `Min` | `decimal?` | не задан | Нижняя включительная граница. |
| `Max` | `decimal?` | не задан | Верхняя включительная граница. |
| `Step` | `decimal` | 1 | Шаг числового ввода. |
| `Disabled` | `bool` | false | true запрещает действия пользователя. |
| `AdditionalAttributes` | `Dictionary<string,object>?` | не задан | Дополнительные HTML/ARIA атрибуты; не используйте для обхода проверок модели. |

## Параметры и события Flutter

`required` в конструкторе означает обязательный аргумент, даже если его тип допускает null. `key` — стандартный Flutter Key. Значения по умолчанию приведены в точной сигнатуре ниже.

| Аргумент | Тип | Назначение |
|---|---|---|
| `label` | `String` | Подпись элемента или доступное имя. |
| `value` | `double?` | Текущее значение; тип и правила описаны выше. |
| `min` | `double?` | Нижняя включительная граница. |
| `max` | `double?` | Верхняя включительная граница. |
| `onChanged` | `ValueChanged<double?>?` | Новое значение для родителя; обновите состояние через setState. |
| `enabled` | `bool` | false запрещает действия пользователя. |
| `required` | `bool` | true требует непустое значение при проверке формы. |

```dart
const NgNumericTextBox({
    super.key,
    required this.label,
    required this.value,
    this.min,
    this.max,
    this.onChanged,
    this.enabled = true,
    this.required = false,
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgNumericTextBox.razor)
- [Flutter](../../packages/nextgen_components/lib/src/components.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
