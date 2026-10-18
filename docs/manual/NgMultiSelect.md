# NgMultiSelect — Множественный выбор

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Выбор нескольких ключей из NgOption с удалением выбранных элементов.

## Поведение и практические правила

Значение — коллекция ключей, а не подписей. Callback отдаёт новый список; заменяйте коллекцию в родителе. MaxSelected ограничивает добавление, удаление остаётся доступным. Во Flutter required требует хотя бы один вариант; в Blazor задайте правило модели формы. Поле поддерживает поиск по локальным вариантам и не виртуализирует большой список.

## Blazor: рабочий пример

```razor
<NgMultiSelect Label="Услуги" Items="options" MaxSelected="2" @bind-Value="selected"/>
@code { private string[] selected=[]; private NgOption[] options=[new("a","Доставка"),new("b","Сборка")]; }
```

## Flutter: рабочий пример

```dart
List<String> selected = [];
Widget build(BuildContext context) => NgMultiSelect(label: 'Услуги', value: selected,
  items: const [NgOption('a','Доставка'),NgOption('b','Сборка')], maxSelected: 2,
  onChanged: (v) => setState(() => selected = v));
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `Label` | `string` | "Options" | Подпись элемента или доступное имя. |
| `Items` | `IReadOnlyList<NgOption>` | [] | Исходные элементы. Тип модели указан в сигнатуре; заменяйте список при изменениях. |
| `MaxSelected` | `int?` | не задан | Ограничение количества выбранных ключей. |
| `Disabled` | `bool` | false | true запрещает действия пользователя. |
| `Value` | `string[]` | значение модели | Текущее значение поля. |
| `ValueChanged` | `EventCallback<string[]>` | — | Изменение значения. |
| `ValueExpression` | `Expression<Func<string[]>>` | обязательно | Автоматически создаётся @bind-Value; при ручной привязке передайте явно. |
| `AdditionalAttributes` | словарь HTML-атрибутов | null | Дополнительные HTML/ARIA атрибуты поля. |

## Параметры и события Flutter

`required` в конструкторе означает обязательный аргумент, даже если его тип допускает null. `key` — стандартный Flutter Key. Значения по умолчанию приведены в точной сигнатуре ниже.

| Аргумент | Тип | Назначение |
|---|---|---|
| `label` | `String` | Подпись элемента или доступное имя. |
| `value` | `List<String>` | Текущее значение; тип и правила описаны выше. |
| `items` | `List<NgOption>` | Исходные элементы. Тип модели указан в сигнатуре; заменяйте список при изменениях. |
| `onChanged` | `ValueChanged<List<String>>?` | Новое значение для родителя; обновите состояние через setState. |
| `maxSelected` | `int?` | Ограничение количества выбранных ключей. |
| `enabled` | `bool` | false запрещает действия пользователя. |
| `required` | `bool` | true требует непустое значение при проверке формы. |

```dart
const NgMultiSelect({
    super.key,
    this.label = 'Options',
    required this.value,
    required this.items,
    this.onChanged,
    this.maxSelected,
    this.enabled = true,
    this.required = false,
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgMultiSelect.razor)
- [Flutter](../../packages/nextgen_components/lib/src/forms.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
