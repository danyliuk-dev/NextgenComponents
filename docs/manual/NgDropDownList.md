# NgDropDownList — Выпадающий список

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Выбор одного значения из набора NgOption; Value/value содержит ключ, Label/label — отображаемую подпись.

## Поведение и практические правила

Ключи вариантов должны быть уникальны. Disabled у NgOption исключает выбор этого пункта. Родитель обязан принять callback и передать новое value обратно. Не передавайте ключ, отсутствующий в Items. RadioGroup подходит для небольшого числа одновременно видимых вариантов. Локальный список; удалённый поиск, виртуализация и группировка не реализованы.

## Blazor: рабочий пример

```razor
<NgDropDownList Label="Команда" Items="options" @bind-Value="team"/>
@code { private string team="design"; private NgOption[] options=[new("design","Дизайн"),new("dev","Разработка"),new("locked","Недоступно",true)]; }
```

## Flutter: рабочий пример

```dart
String? team = 'design';
Widget build(BuildContext context) => NgDropDownList(label: 'Команда', value: team,
  items: const [NgOption('design','Дизайн'), NgOption('dev','Разработка'),
    NgOption('locked','Недоступно', disabled: true)],
  onChanged: (v) => setState(() => team = v));
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `Id` | `string` | "ng-" + Guid.NewGuid().ToString("N") | Уникальный HTML ID; по умолчанию генерируется. |
| `Label` | `string` | "" | Подпись элемента или доступное имя. |
| `Placeholder` | `string?` | не задан | Подсказка внутри пустого поля. |
| `Items` | `IReadOnlyList<NgOption>` | [] | Исходные элементы. Тип модели указан в сигнатуре; заменяйте список при изменениях. |
| `Value` | `string` | "" | Текущее значение; тип и правила описаны выше. |
| `ValueChanged` | `EventCallback<string>` | не задан | Новое значение для родителя; сохраните его в модели. |
| `ValueExpression` | `System.Linq.Expressions.Expression<Func<string>>?` | не задан | Выражение поля модели для валидации. @bind-Value создаёт автоматически; при ручных Value/ValueChanged передайте явно, даже вне формы. |
| `Disabled` | `bool` | false | true запрещает действия пользователя. |
| `AdditionalAttributes` | `Dictionary<string,object>?` | не задан | Дополнительные HTML/ARIA атрибуты; не используйте для обхода проверок модели. |

## Параметры и события Flutter

`required` в конструкторе означает обязательный аргумент, даже если его тип допускает null. `key` — стандартный Flutter Key. Значения по умолчанию приведены в точной сигнатуре ниже.

| Аргумент | Тип | Назначение |
|---|---|---|
| `label` | `String` | Подпись элемента или доступное имя. |
| `value` | `String?` | Текущее значение; тип и правила описаны выше. |
| `items` | `List<NgOption>` | Исходные элементы. Тип модели указан в сигнатуре; заменяйте список при изменениях. |
| `onChanged` | `ValueChanged<String?>?` | Новое значение для родителя; обновите состояние через setState. |
| `validator` | `FormFieldValidator<String>?` | Проверка поля: null при успехе, строка с ошибкой при отказе. |

```dart
const NgDropDownList({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.validator,
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgDropDownList.razor)
- [Flutter](../../packages/nextgen_components/lib/src/components.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
